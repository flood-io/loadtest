# About

This is a simple nginx image which provides a loadtest target at https://flooded.io

# Reasons

Load testing, is the simulation of demand on a target application or system, which you then measure for performance. This repository is a collection of different types of performance tests, which can be executed against an example application which is fronted by nginx.

You can see the target application at https://flooded.io or you can build it, and run it locally with the make file:

        $ make build
        $ make run
        $ curl -s https://localhost:8080/api/v2
