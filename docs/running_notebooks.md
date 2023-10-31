# Running example notebooks in this repository
You can either download or clone this repository to your local machine if you want to run the example notebooks included here. Below we include some instructions on how to set up you machine before you can successfully run the example notebooks.  
  
## Setting up your machine

After making this repository available locally by either cloning or downloading it from GitHub, you need to ensure all packages used in this repository are installed in your local machine before running any notebooks. If any packages are not installed in your machine, you will not be able to run the example notebooks.
  
The good news is that you will not need to go through every notebook checking the libraries you need. We are providing some files that will automate this process for you whether you use `R`, `Python`, or both.  

**Note:** You will only need to complete the set up steps once per machine. This should be done prior to running the notebooks for the first time. Also note that if you plan to use notebooks in one language, either `R` or `Python`, there is no need to follow the set up steps for the programming language that you do NOT need.
  
<details>
<summary><b> Instructions for R users </b></summary>

If you are using the `R` notebooks, run the following two lines in the `RStudio` console:  
```R
  source("R_based_scripts/Installing_R_libraries.R")  
  checking_libraries()
```  
The lines above will run a function that automatically checks if any `R` libraries used in this repository are not installed in your machine. If any libraries are missing, it will install them automatically. Bear in mind that these notebooks were developed in `R` version 4.3.1, so you may need to upgrade your `R` version if you encounter any problems during package installation.
</details>

<details>
<summary><b> Instructions for Python users </b></summary>
We are also including an `requirements.txt` file under the `Python_based_scripts` folder, which contains all `Python` packages used in the notebooks above. You can use this file to create a [`conda` environment](https://docs.conda.io/projects/conda/en/latest/user-guide/concepts/environments.html) with all the required packages. To do so, run the following command in the Anaconda Prompt (Windows) or in your terminal (MacOS, Linux):  
  
```bash
conda env create -f requirements.txt -n rimrep
```
  
where `rimrep` is the name of the environment. You can change this name to whatever you want. **Note**: If you are not in the directory where the `requirements.txt` file is located, the code above will not work. You will need to specify the path to the `requirements.txt` file. For example, if your terminal window is in the `rimrep-examples` folder, you will need to specify the full path to the `requirements.txt` file as follows:  
  
```bash
conda env create -f Python_based_scripts/requirements.txt -n rimrep
```
    
Finally, you will need to activate this environment before you are able to run the `Python` notebooks included here. To do so, run the following command in your terminal window:  
  
```bash
conda activate rimrep
```
  
When you are done running the notebooks, you can deactivate the environment by running `conda deactivate` in the terminal window.
activate.  
</details>
  
[Home](../README.md)