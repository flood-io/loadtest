# About

Load testing, is the simulation of demand on a target application or system, which you then measure for performance. This repository is a collection of different types of performance tests, which can be executed against an example application which is fronted by nginx.

You can see the target application at https://flooded.io or you can build it, and run it locally with the make file:

        $ make build
        $ make run
        $ curl -s https://localhost:8080/api/v2

# 🍐 PEARS 🍐

*PEARS* is a mmemonic that I like to use, to think about the characteristics of a system under test that I am interested in, when performance testing. It stands for Performance, Elasticity, Availability, Reliability and Scalabaility.

It's not always about response time, or concurrency for example, as the following dimensions describe.

## Performance

Measuring performance, is typically done by monitoring metrics such as response time, concurrent users, throughput and passed or failed counts. Many performance metrics are expressed as a unit of time, for example, the average time that it takes for a transaction to complete. Others are expressed as a count, for example, the total number of requests which have passed or failed. While others are expressed as a rate, such as network throughput as measured by bits per second. In isolation, these metrics are not as rich in information, as when they are viewed together. For example, an increasing in response time with a decreasing transaction rate, might indicate some form of performance bottleneck. Load testing platforms, such as Tricentis Flood help you observe these metrics in real time in order to make informed observations around performance.

## Elasticity