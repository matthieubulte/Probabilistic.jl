
probabilistic.jl is a small project attempting to embed a simple probabilistic modeling language in Julia.

Models are written in quoted expressions using an extended version of Julia's syntax, and a the library then compiles these models to Julia functions intrumented to be able to run, condition and sample from these models.

Example:

```
blah
```



NOTE: this is a toy project, and doesn't have the ambition to be more than that.