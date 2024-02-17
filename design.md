# Pat - A REST API toolkit
Pat is a toolkit for developing REST APIs.
It allows its users to do the following:
1. Develop REST APIs by providing an interface to call an HTTP endpoint and see its response
2. Test REST APIs by running multiple requests and comparing their response with an assert/expectation/reference

## Problem
(1) A developer can express an HTTP request which when requested to a target server, responds with a response.
(2) A developer can specify invariants about this response which should be evaluated and reported.
(3) A developer can do the (1) and (2) for multiple requests and organize them.

## Design
### Goals
1.  Lean: Users should be able to only install software that they have a user for. This means that if this project grows in scope, it will need to be done in a modular manner.
2.  Powerful: The tool should be able to solve 80% of user problems. But, it should be powerful enough with extension to solve the 0ther 20% of their problems.
3.  Intuitive:  Use of the tool is extremely intuitive and does not involve a steep learning curve
4.  Minimal: Users should not need to install 100s of dependencies to make the tool work. The tool should simply work.
5.  Collaborative: The artifacts produced by or created from use of the tool should be easy to organize and version.

#### Audience
Developers of all kinds, experience and abilities.
To operate the tool, developers should only know the mechanics of REST APIs,
operation of the command line, and nothing more.

### Blueprint
The major problem areas can be split into the following sub-problems:
1.  **Expr**: Expressing an HTTP request
2.  **Run**: Evalutating the HTTP request and requesting a server
3.  **Match**: Matching the request against a user-specified expectation


### Decisions
1.  Build on what they already have:
        The tool will make use of existing tools that are already installed on one's system if they do similar kind of work.
        There are pre-existing for each of the problem areas:
        1. Expr: HTTP plaintext, A DSL to specify them
        2. Run: curl, telnet, etc
        3. Match: jq for JSON, awk for text, sql for csv?
        The tool should not opine about the tools users can use
2. Use bash:
        The tool should be as lean as possible. The best way to use system tools is through bash.
        Using system tools from programming languages leaves involves a lot more work and is harder to prototype.

### Use
There are multiple ways of using this tool. Let's examine each of them.
To examine each use, we make not of the following:
1. Objective: Why the user is using the tool in the specified way
2. Context: What information the user needs to get to the objective
3. Result: What the user is grapsing at to complete their objective

#### Exploration
In this mode, the user is trying to look at the HTTP request and trying to understand
the response or experiment with different HTTP headers or body.

Objective: Understand how the request affects the response
Context:
1.  The HTTP request
2.  The parameters accepted by the HTTP endpoint
Result: A correlation between HTTP request parameters like headers or data and the returned response

#### Testing
In this mode, the user is trying to run a set or subset of tests to look at whether
the HTTP endpoint responds with what they expect.

Objective: Look for deviations from expectations
Context:
1.  A set/subset of HTTP requests
2.  A query that runs on the response for each HTTP request
3.  An expectation of the result of the query that runs on the HTTP response
Result: Whether there are any deviations from expectations.
In most cases, users will also want to see what exactly are the deviations from their expectations.
