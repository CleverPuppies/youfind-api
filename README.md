# YouFind

With YouFind, you can find words mentioned in YouTube videos.

## Resources

- Video
- Caption

## Elements

- videos
    - video id
- captions
    - caption id
    - last updated
    - track kind
    - language

## Entities

- YouTube video
- Captions

# Language of YouFind

## Youtube related words

- Video: represents all the information Youtube links to a particular video
- video id: the id that youtube gives to a video: can be found in the end of the video url
- Captions: the captions decomposed in small parts with timestamps
- caption id: the id which references the captions of a video in Youtube API

## Requests

Functions which only purpose is to make an http call should be named based on the method they use:
- get_*: for get methods
- post_*: for post methods
- and so on for delete, patch...


