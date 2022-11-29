+++
categories = ['References']
date = '2022-11-25'
subtitle = 'Getting behind the scenes with OpenSpiel and GDB'
slug = 'debugging-python-c-extensions'
title = 'Debugging Python C/C++ Extensions'
+++

Over the past few weeks I've been using OpenSpiel, an RL framework for research on games. Like a lot of popular Python frameworks built for speed, OpenSpiel is also written in C++ with functionality exposed in Python through C++ bindings[^python-bindings]. Although the framework has documentation available, it's not possible to document everything and besides, nothing beats stepping through the code in a debugger like the built-in [pdb](https://docs.python.org/3/library/pdb.html) or the TUI based [pudb](https://pypi.org/project/pudb/) (which happens to be my favourite). The fact that the core functionality of OpenSpiel is written in a compiled language makes it difficult to steer through complex code and understand what is happening under the hood. But fear not, I spent quite some time figuring out exactly this and through the little wisdom that I have gained during the process, allow me to share my take on how to navigate this problem.

[^python-bindings]: Python bindings are a way to call functions written in other languages from within Python. I'm not the best person to explain what they are, so let me point you to [the official python docs](https://docs.python.org/3/extending/extending.html) or [this excellent article](https://realpython.com/python-bindings-overview) about Python bindings from realpython.org 

The first thing to understand is that it is possible to step through code written in C/C++. In fact, this has been possible for a long time using GDB. To do so, however, your C++ code must be compiled with debugging symbols enabled. If you use `gcc` to compile your code, I'm talking about the `-g` flag. For a better debugging experience, it is also recommended to disable all compiler optimizations using the `-O0` flag. 

The next thing you need to know is that you can invoke Python scripts through GDB. And if there's C++ code executing in the background, you can step through it provided the code is compiled with debug symbols enabled. In the following section, I'll explain how to build OpenSpiel in debug mode, but in reality you can extrapolate the same principles to any other library using Python C/C++ bindings.

# Building OpenSpiel in Debug mode
---
In most cases, you would have installed OpenSpiel using `pip install open_spiel`, and pip must have downloaded a pre-compiled version of the library for your platform. But as you can imagine, production releases of software are optimized for performance, and so is OpenSpiel. So if you need a debug build you will have to manually do that for your machine. If you're on unix based systems, you can follow [these instructions](https://github.com/deepmind/open_spiel/blob/master/docs/install.md) from GitHub. I followed a slightly different route using `conda` for system dependencies to avoid `sudo` access.

1. First, you will need to install the build dependencies. I prefer creating a separate `conda` environment. I'll use the community based `conda-forge` channel and install some basic dependencies.
```console
$ # create a new conda environment
$ conda create -n spiel -c conda-forge python cmake clangxx gxx numpy scipy absl-py attrs
$ # and activate it using conda activate spiel
```

2. Next, we (obviously) need the source code for OpenSpiel.
```console
$ git clone https://github.com/deepmind/open_spiel
$ # now cd into open_spiel (hereafter called root directory)
```

3. At this point you can build and install OpenSpiel using `pip install .`, but doing so will not include debug symbols. To do so, you need to disable all optimizations using `-O0` and direct cmake to build the debug version. You will need to make changes to `open_spiel/CMakeLists.txt` and `setup.py`. The `-g` flag is already taken care of. Here's what running a `git diff` from the root directory looks like:

```diff
diff --git a/open_spiel/CMakeLists.txt b/open_spiel/CMakeLists.txt
index 880a9365..023161a1 100644
--- a/open_spiel/CMakeLists.txt
+++ b/open_spiel/CMakeLists.txt
@@ -43,7 +43,7 @@ message("${BoldYellow}Current build type is: ${BUILD_TYPE}${ColourReset}")
 if(${BUILD_TYPE} STREQUAL "Debug")
   # Basic build for debugging (default).
   # -Og enables optimizations that do not interfere with debugging.
-  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -g -Og")
+  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -g -O0")
 endif()
 
 if(${BUILD_TYPE} STREQUAL "Testing")
```

```diff
diff --git a/setup.py b/setup.py
index cc29bcc2..990583c3 100644
--- a/setup.py
+++ b/setup.py
@@ -84,6 +84,7 @@ class BuildExt(build_ext):
         f"-DPython3_EXECUTABLE={sys.executable}",
         f"-DCMAKE_CXX_COMPILER={cxx}",
         f"-DCMAKE_LIBRARY_OUTPUT_DIRECTORY={extension_dir}",
+        f"-DBUILD_TYPE=Debug",
     ]
     if not os.path.exists(self.build_temp):
       os.makedirs(self.build_temp)
```

4. There are some more dependencies like `pybind11` and `abseil-cpp` which need to be downloaded manually. The easiest way to do so is to run `install.sh` from the root directory. But that script also installs system-wide dependencies, which we already installed while creating the conda environment. So we'll edit the script and only run it halfway through. Here's one way to do it:
```diff
diff --git a/open_spiel/scripts/install.sh b/open_spiel/scripts/install.sh
index b789a18c..87d19310 100755
--- a/open_spiel/scripts/install.sh
+++ b/open_spiel/scripts/install.sh
@@ -190,6 +190,7 @@ if [[ ${OPEN_SPIEL_BUILD_WITH_ORTOOLS:-"ON"} == "ON" ]] && [[ ! -d ${DIR} ]]; th
   tar -xzf "${DOWNLOAD_FILE}" --strip 1 -C "$DIR"
 fi
 
+exit 0
 # 2. Install other required system-wide dependencies
 
 # Install Julia if required and not present already.
```
```console
$ bash install.sh
```

5. Finally, we can build and install the extension using pip.
```console
$ # run this from the root directory
$ pip install -v .
```

At this point you should see output from `cmake`
```console
...
Building wheels for collected packages: open-spiel
...
[  0%] Building CXX object abseil-cpp/absl/base/CMakeFiles/absl_log_severity.dir/log_severity.cc.o
...
[100%] Building CXX object python/CMakeFiles/pyspiel.dir/pybind11/utils.cc.o
...
Successfully built open-spiel
...
Successfully installed open-spiel-1.2
```

If you see that last line, well, congratulations! You have successfully built and installed OpenSpiel with debug symbols. In the next section, we'll see an example of stepping into C++ code called from within Python. As a final check, you can launch the `python` interpreter and try `import pyspiel` to check if it's installed successfully.

# Debugging C++ extensions using GDB
---
Let's say we want to figure out how OpenSpiel produces the information state tensor for 2-player Leduc Poker. Here's a toy script that we would be working with. Let's name this script `play.py`. To debug Python extensions using GDB, of course we're going to need GDB. You can install it with `conda install -c conda-forge gdb`

```py {linenos=true}
# play.py
import pyspiel

game = pyspiel.load_game("leduc_poker", {"players": 2})
state = game.new_initial_state()
state.apply_action(0)
state.apply_action(1)
state.information_state_tensor()
```

Before going ahead, I think it's a good idea to browse through the source code for OpenSpiel. You'll see that the code unique to each game is located in [`open_spiel/games`](https://github.com/deepmind/open_spiel/tree/607bacb6d88d46a4449c8cab97d159cf976a9765/open_spiel/games). For Leduc Poker, the code happens to be in [`leduc_poker.cc`](https://github.com/deepmind/open_spiel/blob/607bacb6d88d46a4449c8cab97d159cf976a9765/open_spiel/games/leduc_poker.cc) and its corresponding header file [`leduc_poker.h`](https://github.com/deepmind/open_spiel/blob/607bacb6d88d46a4449c8cab97d159cf976a9765/open_spiel/games/leduc_poker.h). If you scroll through the code in `leduc_poker.cc`, you will find the definition of [`InformationStateTensor`](https://github.com/deepmind/open_spiel/blob/607bacb6d88d46a4449c8cab97d159cf976a9765/open_spiel/games/leduc_poker.cc#L528-L533) on line `528`:

```cpp {linenos=true, linenostart=528}
void LeducState::InformationStateTensor(Player player,
                                        absl::Span<float> values) const {
  ContiguousAllocator allocator(values);
  const LeducGame& game = open_spiel::down_cast<const LeducGame&>(*game_);
  game.info_state_observer_->WriteTensor(*this, player, &allocator);
}
```

This piece of code further calls [`WriteTensor`](https://github.com/deepmind/open_spiel/blob/607bacb6d88d46a4449c8cab97d159cf976a9765/open_spiel/games/leduc_poker.cc#L176-L198) on line `532`, which is defined in the same file.

```cpp {linenos=true, linenostart=176}
  void WriteTensor(const State& observed_state, int player,
                   Allocator* allocator) const override {
    auto& state = open_spiel::down_cast<const LeducState&>(observed_state);
    SPIEL_CHECK_GE(player, 0);
    SPIEL_CHECK_LT(player, state.num_players_);

    // Observing player.
    WriteObservingPlayer(state, player, allocator);

    // Private card(s).
    if (iig_obs_type_.private_info == PrivateInfoType::kSinglePlayer) {
      WriteSinglePlayerCard(state, player, allocator);
    } else if (iig_obs_type_.private_info == PrivateInfoType::kAllPlayers) {
      WriteAllPlayerCards(state, allocator);
    }

    // Public information.
    if (iig_obs_type_.public_info) {
      WriteCommunityCard(state, allocator);
      iig_obs_type_.perfect_recall ? WriteBettingSequence(state, allocator)
                                   : WritePotContribution(state, allocator);
    }
  }
```

Reading through the code, it looks like the information state tensor is made up of multiple parts. The first is the observing player, and the rest of the code flow depends on `iig_obs_type_`. Let's fire up GDB and check what's happening. First, we'll instruct GDB to run our Python script using the 


```console
$ gdb --args python play.py 
GNU gdb (GDB) 12.1
Copyright (C) 2022 Free Software Foundation, Inc.
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.
Type "show copying" and "show warranty" for details.
This GDB was configured as "x86_64-conda-linux-gnu".
Type "show configuration" for configuration details.
For bug reporting instructions, please see:
<https://www.gnu.org/software/gdb/bugs/>.
Find the GDB manual and other documentation resources online at:
    <http://www.gnu.org/software/gdb/documentation/>.

For help, type "help".
Type "apropos word" to search for commands related to "word"...
Reading symbols from python...
```

We'll now set a `breakpoint` on `leduc_poker.cc` line `183` to stop right before `WriteObservingPlayer`.
```cpp
(gdb) break leduc_poker.cc:183
No source file named leduc_poker.cc.
Make breakpoint pending on future shared library load? (y or [n]) yes
Breakpoint 1 (leduc_poker.cc:183) pending.
```

Finally, we'll `run` the script and wait until we hit the breakpoint.

```cpp
(gdb) run
Starting program: /ext3/miniconda3/envs/spiel/bin/python play.py
[Thread debugging using libthread_db enabled]
Using host libthread_db library "/lib/x86_64-linux-gnu/libthread_db.so.1".

Breakpoint 1, open_spiel::leduc_poker::LeducObserver::WriteTensor 
    (this=0x555555b26390, observed_state=..., player=0, allocator=0x7fffffffc0a0) 
    at open_spiel/open_spiel/games/leduc_poker.cc:183
183         WriteObservingPlayer(state, player, allocator);
```

Now let's see what's `iig_obs_type_`, using the `print` command.

```cpp
(gdb) print iig_obs_type_
$1 = {public_info = true, perfect_recall = true, 
      private_info = open_spiel::PrivateInfoType::kSinglePlayer}
```

Okay, so following the code for `WriteTensor` now we know that the information state is a combination of the observing player, followed by their private cards, the community card and finally the betting sequence.

And that's a simple example of using GDB's debugging capabilities with Python C/C++ extensions.

# Diving deeper into the internals with Abseil
---
GDB can do much more than what's shown in the example above. Let's say we want to understand how `WriteObservingPlayer` works. GDB is already at line `183`, so we'll just step into the function and look around.

```cpp
(gdb) step
open_spiel::leduc_poker::LeducObserver::WriteObservingPlayer 
    (state=..., player=0, allocator=0x7fffffffc0a0) at 
    open_spiel/open_spiel/games/leduc_poker.cc:111
111         auto out = allocator->Get("player", {state.num_players_});
(gdb) list
106       //
107
108       // Identity of the observing player. One-hot vector of size num_players.
109       static void WriteObservingPlayer(const LeducState& state, int player,
110                                        Allocator* allocator) {
111         auto out = allocator->Get("player", {state.num_players_});
112         out.at(player) = 1;
113       }
114
115       // Private card of the observing player. One-hot vector of size num_cards.
(gdb) next
112         out.at(player) = 1;
```

From the comments, it looks like `out` is a one-hot vector. Let's inspect it using the `ptype` command.

```cpp
(gdb) ptype out
type = class open_spiel::SpanTensor {
  private:
    open_spiel::SpanTensorInfo info_;
    absl::lts_20211102::Span<float> data_;

  public:
    SpanTensor(open_spiel::SpanTensorInfo, absl::lts_20211102::Span<float>);
    const open_spiel::SpanTensorInfo & info(void) const;
    absl::lts_20211102::Span<float> data(void) const;
    std::string DebugString(void) const;
    float & at(void) const;
    float & at(int) const;
    float & at(int, int) const;
    float & at(int, int, int) const;
    float & at(int, int, int, int) const;
}
```

So `out` is indeed a `SpanTensor` with a `.data()` method producing an object of type `absl::Span`. So what exactly is `absl`? Turns out it's Google's [library](https://abseil.io/) with a bunch of abstractions on top of C++. Much of the documentation about `absl::Span` can be found in the [source code](https://github.com/abseil/abseil-cpp/blob/bb7be494b385975ebdeaac3a8ee10894405641e4/absl/types/span.h#L288) itself. Let's print `out.data()`.

```cpp
(gdb) print out.data()
$1 = {static npos = 18446744073709551615, ptr_ = 0x555555c2d990, len_ = 2}
```

Reading through [`span.h`](https://github.com/abseil/abseil-cpp/blob/13708db87b1ab69f4f2b3214f3f51e986546f282/absl/types/span.h), it looks like `absl::Span` is a better way of storing references to existing arrays with a bunch of features built in. In this case, the `Span` represented by `out.data()` starts at `0x555555c2d990`, and has `2` elements. We can have a look at the elements of the array using the `.at()` method.

```cpp
(gdb) print out.data().at(0)
$2 = (float &) @0x555555c2d990: 0
(gdb) print out.data().at(1)
$3 = (float &) @0x555555c2d994: 0
```

As you can see, `out` is simply an array with two zeros. On line `112`, we set `out.at(player) = 1`.

```cpp
(gdb) list
107
108       // Identity of the observing player. One-hot vector of size num_players.
109       static void WriteObservingPlayer(const LeducState& state, int player,
110                                        Allocator* allocator) {
111         auto out = allocator->Get("player", {state.num_players_});
112         out.at(player) = 1;
113       }
114
115       // Private card of the observing player. One-hot vector of size num_cards.
116       static void WriteSinglePlayerCard(const LeducState& state, int player,
(gdb) next
113       }
```

In this case, `player = 0` so we set the first element of the array to `1`.

```cpp
(gdb) print player
$4 = 0
(gdb) print out.data().at(0)
$5 = (float &) @0x555555c2d990: 1
```

And that's how we get the first two elements of the information state tensor. The other functions like [`WriteSinglePlayerCard`](https://github.com/deepmind/open_spiel/blob/607bacb6d88d46a4449c8cab97d159cf976a9765/open_spiel/games/leduc_poker.cc#L116-L121), [`WriteCommunityCard`](https://github.com/deepmind/open_spiel/blob/607bacb6d88d46a4449c8cab97d159cf976a9765/open_spiel/games/leduc_poker.cc#L135-L141), etc. can be inspected similarly. 

# Further Resources
---
This post tries to bring together a bunch of different topics and of course it's not possible to do justice to each one of them. So here's a list of resources you might find worth looking at:
* [The Abseil Project](https://abseil.io/)
* [GDB's Python Support](https://sourceware.org/gdb/onlinedocs/gdb/Python.html)
* [DeepMind OpenSpiel](https://github.com/deepmind/open_spiel)
* [Alex Dzyoba: How to point GDB to your sources](https://alex.dzyoba.com/blog/gdb-source-path/)
* [RedHat Developers: Debugging Python C extensions with GDB](https://developers.redhat.com/articles/2021/09/08/debugging-python-c-extensions-gdb)

# Bonus Tip: Python Debug Builds
---
If you need a debug build of Python and don't have sudo access, check out [#597](https://github.com/conda-forge/python-feedstock/pull/597) on the [python-feedstock](https://github.com/conda-forge/python-feedstock) repository. Once merged, you should be able to install debug builds using `conda install python -c conda-forge/label/python_debug`. While this PR is still in progress, I've published debug builds for linux on [my channel](https://anaconda.org/nikhilweee/python) in the meanwhile. You're free to install them using `conda install python -c nikhilweee`. 