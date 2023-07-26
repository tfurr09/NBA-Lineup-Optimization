#!/usr/bin/env python
# coding: utf-8

# In[1]:


import pandas as pd
import numpy as np
import seaborn as sns
import matplotlib.pyplot as plt

pd.set_option('display.max_columns', None)


# In[2]:


data = pd.read_csv("optprojectdata.csv", encoding='latin1')
data.head()


# In[3]:


data.rename(columns = {'X2022_23':'Salary'}, inplace = True)


# In[4]:


data.isna().sum()


# In[39]:


data.iloc[:,:-5].describe()


# In[14]:


plt.hist(data.Pos)
plt.show()


# In[9]:


num_rows = 5
num_cols = 4

# Create subplots for histograms
fig, axes = plt.subplots(num_rows, num_cols, figsize=(15, 10))

# Generate histograms for all variables
for i, column in enumerate(data.columns[5:25]):
    ax = axes[i // num_cols, i % num_cols]  # Get the appropriate subplot
    ax.hist(data[column])
    ax.set_xlabel(column)
    ax.set_ylabel('Frequency')

# Adjust spacing between subplots
fig.tight_layout()

# Display the plot
plt.show()


# In[11]:


num_rows = 3
num_cols = 3

# Create subplots for histograms
fig, axes = plt.subplots(num_rows, num_cols, figsize=(15, 10))

# Generate histograms for all variables
for i, column in enumerate(data.columns[25:]):
    ax = axes[i // num_cols, i % num_cols]  # Get the appropriate subplot
    ax.hist(data[column])
    ax.set_xlabel(column)
    ax.set_ylabel('Frequency')

# Adjust spacing between subplots
fig.tight_layout()

# Display the plot
plt.show()


# In[13]:


plt.hist(data.Pos)
plt.show()


# In[ ]:





# In[ ]:




