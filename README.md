# **Story Maker** 📖
This R Shiny application utilizes the [Gradio Python client](https://www.gradio.app/guides/getting-started-with-the-python-client) to call the API of an image-to-text [Gradio](https://www.gradio.app/docs) application currentlty hosted and running as a space on [Hugging Face](https://huggingface.co/). 
Thanks to the [reticulate](https://rstudio.github.io/reticulate/) R package, which provides the interface between R and Python, you can install and load Python modules in your R environment and use them in your R projects.

Here is an example of how to install, import, and use the Gradio Python client to call the API of an image classification Python application in R.

```
library(reticulate)

# install the gradio client module
py_install("gradio_client",pip = TRUE)

# import gradio client
gr_client <- import("gradio_client")

# set environment variable
Sys.setenv(HUGGINGFACE_TOKEN = "your Hugging Face token")

# read image
fox <- gr_client$handle_file("fox.jpg")

# instantiate the client by passing the name of the Hugging Face space and your Hugging Face token
what_client <- gr_client$Client(src = "Ifeanyi/tellme.ai",
                                hf_token = Sys.getenv("HUGGINGFACE_TOKEN"),
                                verbose = F)

# classify the image
class <- what_client$predict(param_0 = fox,
                             api_name = "/predict")

print(class$confidences[[1]])

$label
[1] "red fox, Vulpes vulpes"

$confidence
[1] 0.9360319
```
It is that simple. :smiley:
