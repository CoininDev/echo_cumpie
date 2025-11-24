# Echo Compiler
> [!WARNING]
> WIP: It is still in development, keep expectation low!

This is a simple compiler made for the echo language!

## Echo language
This is a simple high level message-oriented scripting language. We have functions that passes and return just messages! And the received message determines it's behaviour:
```echo
func MyFunction ~
  // Always executed
  x = 5 + 5

  // Pattern: add two numbers
  when add:[a]:[b]
    if not IsNumber<-a or not IsNumber<-b then
      <- error:"a and b must be numbers!" // this is how you return a message
    else
      <- result:{a + b}
    end

  // Pattern: literal match
  when say:hello:to:world
    IO <- message:"Hello World!"
    <- ok

  // Pattern: greeting with name capture
  when say:hello:to:[name]
    IO <- message:{"Hello " + name + "!"}
    <- ok

  // Fallback when no pattern matches
  // ?show means "show a message when no pattern matches"
  ok?show
end

// the entry point
func Main ~
  // Calling a function
  result = MyFunction <- add:4:5
  IO <- message:{result}   // "result:9"

  // Taking a specific value from a message
  second = Take <- 2:{result}

  // Capturing values
  result:[a] = result
  IO <- message:{a}        // "9"

  // Produces an error message
  result = MyFunction <- add:4:"string"

  // Would throw without an alternative
  // result:[a] = result

  // Use alternative value
  result:[a] = result or result:0

  // Use handler block
  result:[a] = result or do
    IO <- error:"Error during calculation."
  end
end
```
