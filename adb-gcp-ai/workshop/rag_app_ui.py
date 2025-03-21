from dotenv import load_dotenv
from PyPDF2 import PdfReader
from langchain.text_splitter import CharacterTextSplitter
from langchain_core.prompts import PromptTemplate
from langchain_core.runnables import RunnablePassthrough
from langchain_core.output_parsers import StrOutputParser
#from fastembed import TextEmbedding
from langchain_community.embeddings import HuggingFaceEmbeddings
from langchain_community.vectorstores import oraclevs
from langchain_community.vectorstores.oraclevs import OracleVS
from langchain_community.vectorstores.utils import DistanceStrategy
from langchain_core.documents import BaseDocumentTransformer, Document
from langchain_core.messages import AIMessage, HumanMessage, SystemMessage
from langchain_huggingface import HuggingFaceEmbeddings
from tqdm import tqdm, trange
# Utils
from langchain.schema import HumanMessage, SystemMessage
from pydantic import BaseModel
from langchain_community.chat_models import ChatVertexAI
from langchain_community.embeddings import VertexAIEmbeddings
from langchain_community.llms import VertexAI
from langchain_google_vertexai import VertexAI
from google.cloud import aiplatform

import oracledb
import sys
#from sentence_transformers import CrossEncoder
import array
import time
import oci
import streamlit as st
import os
import vertexai
import time
import langchain

def chunks_to_docs_wrapper(row: dict) -> Document:
    """
    Converts a row from a DataFrame into a Document object suitable for ingestion into Oracle Vector Store.
    - row (dict): A dictionary representing a row of data with keys for 'id', 'link', and 'text'.
    """
    metadata = {'id': str(row['id']), 'link': row['link']}
    return Document(page_content=row['text'], metadata=metadata)

def main():
    load_dotenv()

    st.set_page_config(page_title="ask question based on pdf")
    st.info("Oracle Database@Google Cloud and Google Vertex AI")
    st.header(" Ask your question to get answers based on your pdf " )

    un = "username" # Enter Username
    pw = "password" # Enter Password
    dsn = 'connection String' # Enter Connection String
    wpwd = "wallet password" # Enter Wallet Password

    connection = oracledb.connect(
        config_dir = '../wallet', 
        user=un, 
        password=pw, 
        dsn=dsn,
        wallet_location = '../wallet',
        wallet_password = wpwd)
    
    #upload the file
    pdf = st.file_uploader("upload your pdf",type="pdf")

    #extract the text
    if pdf is not None:
      pdf_reader = PdfReader(pdf)

      text=""
      for page in pdf_reader.pages:
        text += page.extract_text()

      # split the text
      text_splitter = CharacterTextSplitter(separator="\n",chunk_size=1000,chunk_overlap=200,length_function=len)
      chunks = text_splitter.split_text(text)

      # Create documents using wrapper
      docs = [chunks_to_docs_wrapper({'id': page_num, 'link': f'Page {page_num}', 'text': text}) for page_num, text in enumerate(chunks)]

      s1time = time.time()

      #create knowledge base in Oracle.
      # Initialize model
      model_4db = HuggingFaceEmbeddings(model_name="sentence-transformers/all-MiniLM-L6-v2")

      # Create vector store
      #knowledge_base = OracleVS.from_documents(docs, model_4db, client=conn23c, table_name="MY_DEMO4", distance_strategy=DistanceStrategy.DOT_PRODUCT)
      #knowledge_base = OracleVS.from_documents(docs, model_4db, client=conn23c, table_name="MY_DEMO4", distance_strategy=DistanceStrategy.MAX_INNER_PRODUCT)
      knowledge_base = OracleVS.from_documents(docs, model_4db, client=connection, table_name="MY_DEMO4", distance_strategy=DistanceStrategy.COSINE)

      s2time =  time.time()

    PROJECT_ID = "Google Cloud Project ID"  # @param {type:"string"}
    REGION = "Google Cloud Region"  # @param {type:"string"}

    # Initialize Vertex AI SDK
    vertexai.init(project=PROJECT_ID, location=REGION)

        # Create embeddings
        # Choice 1, Set the OCI GenAI LLM

      # set the LLM to get response
      # set docks to LLM and get answers
      # set the LLM to get response
    llm = VertexAI(
        model_name="gemini-1.5-flash-002",
        max_output_tokens=8192,
        temperature=1,
        top_p=0.8,
        top_k=40,
        verbose=True,
    )
      
      # ask a question
    user_question = st.text_input("Ask a question about your pdf")
    if user_question:
      s3time =  time.time()
      result_chunks=knowledge_base.similarity_search(user_question,5)
      s4time = time.time()
      # Define context and question dictionary
      template = """Answer the question based only on the  following context:
                 {context} Question: {question} """
      prompt = PromptTemplate.from_template(template)
      retriever = knowledge_base.as_retriever(search_kwargs={"k": 10})
      context_and_question = {"context": retriever, "question": user_question}

      chain = (
        {"context": retriever, "question": RunnablePassthrough()}
           | prompt
           | llm
           | StrOutputParser()
      )
      response = chain.invoke(user_question)

      print(user_question)
      s5time = time.time()
      st.write(response)
      print( f" vectorixing and inserting chunks duration: {round(s2time - s1time, 1)} sec.")
      st1 = " vectorizing and inserting chunks duration:  "+str(round(s2time - s1time, 1)) +"sec."
      st.caption( ':blue[' +st1+']' )
      print( f" search user_question and return chunks duration: {round(s4time - s3time, 1)} sec.")
      st1 = " :search user_question,vector search  and return chunks duration  "+str(round(s4time - s3time, 1)) +"sec."
      st.caption( ':blue[' +st1+']' )
      print( f" send user_question and ranked chunks to LLM and get answer duration: {round(s5time - s4time, 1)} sec.")
      st1 = "  send user_question and ranked chunks to LLM and get answer duration: "+str(round(s5time - s4time, 1)) +"sec."
      st.caption( ':blue[' +st1+']' )

if __name__ == '__main__':
    main()

