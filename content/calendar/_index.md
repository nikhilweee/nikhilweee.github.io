+++
layout = 'resume'
title = 'Calendar'

+++

Here's my calendar in case you want to find a time to chat. Feel free to [email](mailto:nikhilweee@gmail.com) me with your suggested time and I'll get back to you as soon as I can.

{{<rawhtml>}}
<div style="aspect-ratio: 1/1.414">
    <iframe src="https://calendar.google.com/calendar/embed?wkst=1&bgcolor=%23ffffff&ctz=America%2FNew_York&showTitle=1&showNav=1&showDate=1&showTabs=1&showCalendars=0&showTz=1&title=Nikhil's%20Calendar&mode=WEEK&src=bmlraGlsd2VlZUBnbWFpbC5jb20&src=bnYyMDk5QG55dS5lZHU&src=Y19ob2luOWJjNjlmamQwNzJhOHZlbHRyNXNkY0Bncm91cC5jYWxlbmRhci5nb29nbGUuY29t&color=%238E24AA&color=%23039BE5&color=%238E24AA" style="border-width:0" width="100%" height="100%" frameborder="0" scrolling="no"></iframe>
</div>
<script>
    var width = document.documentElement.clientWidth;
    var iframe = document.querySelector("div>iframe");
    var url = new URL(iframe.src);
    if (width < 800) {
        url.searchParams.set('showDate', 0);
        iframe.src = url.toString();
    }
</script>
{{</rawhtml>}}
