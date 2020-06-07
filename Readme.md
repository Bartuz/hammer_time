Do you have annoying trolls on your twitch channel?

Visit https://ban-hammer-time.herokuapp.com/ban and ban them all

It will ban EVERYONE from your current viewers on twitch that created account in specified day (date argument)

Example request:

 https://ban-hammer-time.herokuapp.com/ban?oauth=XXX&day=2018-12-13&channel_id=487312410&channel_name=wian__

Required parameter:

* oauth - Your oauth token
* day - Filter for `created_at` field for users in your twitch stream 
* channel_id - Id of your channel 
* channel_name - your channel name (eg. wian__)

If you don't know how to get your oauth token you can run in browser console:

```
function getCookie(name) {
  const value = `; ${document.cookie}`;
  const parts = value.split(`; ${name}=`);
  if (parts.length === 2) return parts.pop().split(';').shift();
}
getCookie('api_token')
```

oauth IS NOT stored anywhere (project is opensourced, you can check it on your own :))

Returned value is your oauth token
