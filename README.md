## RunloopTest test project
### Setup
To setup project simply clone repository and open **.xcworspace* file. All dependencies are commited to the repo to simplify project setup. However in real life example I would prefer to gitignore pods.

### Features

* I tried to follow *MVVM* architecture with usage of **ReactiveCocoa**
* The only complex algorithm that I can see here is concatenating responses from two RSS feeds. This was made with ReactiveCocoa, and can be scaled to concating as much feeds as needed, however I have left one FIXME mark there cause we need to keep order of topics, I've done this with sorting but it should be done in cleaner way with proper cocncatenation.

### What this app can do:

* get and show RSS feeds & details
* show current time
* show last viewed RSS item


