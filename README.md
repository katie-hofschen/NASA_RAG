# NASA_RAG
A Retrieval Augmented Generation for the latest NASA news.      
A project to learn as you go.     

## Theoretical background
### LLMs in short
LLMs are essentially trained to predict the next word in a sentence. 
One way to do this is to reformat text and split sentences into n-grams (the first n-words of a sentence are the input and the next word the target).

For example given the sentences:    
"Whether Chaos brought life and substance out of nothing or whether Chaos yawned life up or dreamed it up, or conjured it up in some other way, I don’t know.     
I wasn’t there. Nor were you. And yet in a way we were, because all the bits that make us were there." (from Mythos, Stephen Fry because it's just a great book)

Ngrams of the first sentence with their -> target would be:
Whether -> Chaos   
Whether Chaos -> brought   
Whether Chaos brought -> life    
Whether Chaos brought life -> and    
...
Whether Chaos brought life and substance out of nothing or whether Chaos yawned life up or dreamed it up, or conjured it up in some other way, I don’t -> know.

One type of neural network architecture that LLMs are trained with is called a Transformer which will learn how to keep refining their predictions as more words are added until a sentence's context is complete or it has reached a pre-set limit. 

LLMs should then be fine tuned to help them understand tasks (eg. given x query y answer would be expected), and interact in a non-toxic way (this is especially important when training on internet content that may not have been comprehensivly screened, we all know why...).


[<img src="https://miro.medium.com/v2/resize:fit:2000/format:webp/0*2FIDOD-IRWOqalw8">](https://medium.com/@thefrankfire/building-basic-intuition-for-large-language-models-llms-91f7ca92dfe7)


Some limitations of LLMs are:
- Hallucinations
- No sources

### A bit of background on RAGs
Some reasons we would want RAG vs basic LLMs:
- LLMs 