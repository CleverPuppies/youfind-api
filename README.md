# YouFind

YouFind aims to solve one simple problem, find in a YouTube video the precise moment you want to listen again. Based on a smart word search we will give you all the captions where the topic you input is present. Then we send you to youtube at the exact moment when your choosen caption was pronounced.

## ER Diagram

<img width="594" alt="Screen Shot 2022-11-06 at 1 47 38 PM" src="https://user-images.githubusercontent.com/50112902/200156545-1795a615-77e5-4b72-80c6-70b9c2720fc1.png">

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
- list_*: for get methods with any specific id
- retrieve_*: for get methods including query arguments such ids
- create_*: for post methods
- update_*: for put methods
- partial_update_*: for patch methods
- destroy_*: for delete methods


