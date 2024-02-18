# `pat` - An HTTP API development tool
Pat is a simple bare-bones HTTP development tool that helps you:  
1.  Explore and Develop your HTTP API from the command line 
2.  Test your HTTP API using requests and assertions as files

Pat is designed with developers in mind. 
Pat is intended to help you develop your APIs without leaving the comfort   
of your editor and command line.

## Installing
There is only one hard dependency - `curl`. 
We also use `jq` as the default formatter and query language for responses. But, you are free to switch this out with the `RESP_FMT` variable. For more, look at the help message. 

1.  Clone the repo with `git clone git@github.com:ttanay/pat.git`
2.  `cd pat` 
3.  `./configure` 

## Usage 
Requests are expressed in a format called `curlf` which stands for "curl flags". 
These are essentially arguments and flags that you would pass on to curl, but, without the `curl` prefix. 
Eg: ``-X GET "http://localhost:5000/person/0"`` 

You can run this request and explore the returned response `pat -p <filepath>`

If it is the first time you're running the request, you can save the response to a file with 
`pat -pS <filename>` 
This saves the response to a `.ref` file. 
You an subsequently run tests on this saved response with `pat -t <filename>` 

Pat runs all requests in the specified filepath. 

## Design Goals 
The design goals of pat are the following:
1. **Built for developers**: It is designed to be optimally used from tools used often by developers - editors and command line. 
2. **Minimal**: It is designed to include the minimal set of features one would need. Pat is anti-bloat. 
3. **Users in control**: It is designed so that users can switch out components and use whatever is suitable for them. The formatter for the response, the query language for responses, and the terminal pager are all intended to be switchable. 
4. **Collaborative**: All artefacts produced for use with pat are files so they can be organized in version control and collaborated upon where the code for an API already is. 
5. **Extensible**: It should be easily extensible by developers from all language communities. Hence, it is written in bash. 

## Contributing 
Please feel free to open an issue for problems you encounter, questions, or feedback. 
PRs are always appreciated! :)
