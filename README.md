# NASA Retrieval Augmented Generator
A Retrieval Augmented Generation for the latest NASA news.      
A project to learn as you go.     

## Using this repository
Assuming that python and jupyter notebook are already installed.    

### Running everything locally (without GPU - very slow)
1. Run pip install -r requirements.txt to install the necessary packages
3. Run create_VectorDB.ipynb
4. Run local_RAG.ipynb (If you have a GPU you can load an optimized pretrained model; with just CPU it can take up to 25 min)
5. Play around with questions to the NASA RAG.

### Using Terraform to spin up an AWS Sagemaker Endpoint hosting the model
Prerequisites: 
- Setup Terraform if not installed yet [Guide](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
- Setup awscli with your credentials (with v2 you can use `aws configure sso`) [Setup with IAM profile](https://docs.aws.amazon.com/cli/latest/userguide/sso-configure-profile-token.html#sso-configure-profile-token-auto-sso)

1. Install python libraries from the requirements.txt
2. Login to awscli, I use `aws sso login --profile [your-profile-name]`
4. Open terminal in nasa_terraform/ folder and run `terraform init` (only the first time you start everything up), to see what changes would be applied `terraform plan` and to spin everything up `terraform apply`.
5. Invoke the endpoint in invoke_endpoint.ipynb
6. When you're done run `terraform destroy` to shut down the created infrastructure.


Future work:
- Either use a huggingface [endpoint](https://huggingface.co/docs/inference-endpoints/index) or deploy a model on [aws](https://www.youtube.com/watch?v=a2A_CxrH3Ts) with lambda to improve response times. Do this using [terraform module sagemaker-huggingface](https://registry.terraform.io/modules/philschmid/sagemaker-huggingface/aws/latest) or from [scratch with terraform](https://aws.plainenglish.io/creating-a-serverless-endpoint-in-amazon-sagemaker-for-hugging-face-models-using-terraform-ff2113e65abc)
- Play around with more advanced RAG methods.
- Make outputs to questions prettier and easier to read.
- Possibly simple UI for questions and answers.

## Theoretical background
### LLMs in short
LLMs are essentially trained to predict the next word in a sentence. 
One way to do this is to reformat text and split sentences into n-grams (the first n-words of a sentence are the input and the next word the target).

For example given the sentences:    
"Whether Chaos brought life and substance out of nothing or whether Chaos yawned life up or dreamed it up, or conjured it up in some other way, I don’t know.
I wasn’t there. Nor were you. And yet in a way we were, because all the bits that make us were there."      
(from Mythos, Stephen Fry because it's just a great book)

Ngrams of the first sentence with their -> target would be:      
Whether -> Chaos   
Whether Chaos -> brought   
Whether Chaos brought -> life    
Whether Chaos brought life -> and    
...     
Whether Chaos brought life and substance out of nothing or whether Chaos yawned life up or dreamed it up, or conjured it up in some other way, I don’t -> know.

One type of neural network architecture that LLMs are trained with is called a Transformer which will learn how to keep refining their predictions as more words are added until a sentence's context is complete or it has reached a pre-set limit. 

LLMs should then be fine tuned to help them understand tasks (eg. given x query y answer would be expected), and interact in a non-toxic way (this is especially important when training on internet content that may not have been comprehensivly screened, we all know why...).

A bit of context on the development of LLMs:
[<img src="https://miro.medium.com/v2/resize:fit:2000/format:webp/0*2FIDOD-IRWOqalw8">](https://medium.com/@thefrankfire/building-basic-intuition-for-large-language-models-llms-91f7ca92dfe7)

Some limitations of LLMs are:
- Hallucinations
- Sources of information not provided

### A bit of background on RAGs
RAGs use an information source to retrieve relevant information and provide answers that are contextual to a use case. Like in this case we are providing a number of articles from NASA as the information source for the model to reference when it is asked a question.      
This is partially attractive because rather than retrain an LLM (very expensive and time intensive), we can update our information source to help the RAG give up to date and accurate answers.

#### Embeddings
An embedding is a numerical representation of a piece of information, for example, text, documents, images, audio, etc. The representation captures the semantic meaning of what is being embedded, making it robust for many industry applications.

#### Naive RAG
To do this our information source is split into equal size chunks of text (this allows us to extract the relevant paragraphs rather than an entire document). These chunks are then vectorized and stored in a vector database. When a query is submitted, we vectorize it and try to find the top k most relevant chunks of our information source. The query and the relevant chunks are then passed to an LLM to create a coherent answer. [Huggingface Tutorial for simple RAG](https://huggingface.co/learn/cookbook/en/rag_zephyr_langchain)

#### Agent RAG
An agent is more or less an tool that helps LLMs give more accurate answers. For example a calculator for math, search tool for the web, knowledge base searcher and summarizer and more. [Langchain agents](https://www.pinecone.io/learn/series/langchain/langchain-agents/)     
Common types of agents are:     
* Zero Shot ReAct (the agent considers one single interaction with the agent — it will have no memory.)
* Conversational ReAct (agent same as the same as Zero Shot ReAct agent, but with conversational memory.)
* ReAct Docstore (explicitly built for information search and lookup using a LangChain docstore.)
* Self-Ask With Search (when connecting an LLM with a search engine: it will perform searches and ask follow-up questions as often as required to get a final answer.)

#### Guardrails RAG
Guardrails can be described as classifiers of user intent. When a user asks a question, the guardrails identify this intent and trigger the RAG pipeline.
The categories of user intent are called "canonical forms". For example, define: user asks technical question, define: user asks about space etc.
Then they are defined by providing example queries (utterances) that belong to a canonical form. For example, How can I automate my house?, or Why haven't we gotten a response from life beyond earth?     
All utterances are vectorized and so is the user query. If the query is similar to some utterances their canonical form is triggered.  
(Can be a compromise in speed and accuracy between naive and agent RAG)


Idea: Start with simple RAG     
(maybe with pre and post processing):
1. Use an LLM to summarize the query and then embed the resulting summary to compare to chunks.
2. Ask an LLM to chose the most applicable answer to the orignial user query.

[Advanced RAG tutorial from Huggingface](https://huggingface.co/learn/cookbook/en/advanced_rag)