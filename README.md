# 🧠 PVP Development Project

Statistical analysis and modeling of white matter development in tracts connecting the ventral and dorsal visual streams. Developed in collaboration with **Professor Sophia Vinci-Booher** ([svincibo](https://github.com/svincibo)) as part of ongoing work at the Learning and NeuroDevelopment Lab (LaND Lab) at Vanderbilt University.

This codebase was used for statistical analysis and figure generation in:

**Arif, Z., Ren, X., Pestilli, F., & Vinci-Booher, S.**  
*White Matter Tracts Connecting Ventral and Dorsal Visual Streams Have Distinct Microstructural Profiles and Developmental Trajectories*  
*Manuscript in progress*

---

## 📁 Repository Contents

- `importData.m` – imports diffusion metrics downloaded from Brainlife for each subject (update `mainpath` to local path of tractography)
- `tractProfile.m` – generates tract profiles based on dMRI metrics
- `Lebel2010Model.m` – implements the Poisson regression model from Lebel et al. (2010) for developmental trajectory fitting
- `Lebel2008Model.m` – implements the exponential growth model from Lebel et al. (2008)
- `inflectionPointTest{x}.m` – test scripts for the inflection point estimation method

---

## 🎯 Project Goals

- Characterize the developmental trajectories of diffusion metrics (FA, MD, ODI, NDI) across key white matter tracts  
- Compare microstructural differences between tracts connecting dorsal vs. ventral visual pathways  
- Evaluate growth curves using established models (Poisson, exponential)  
- Identify inflection points in development using custom testing methods  
- Generate figures for manuscript publication

---

## 🛠 Tools & Environment

- **MATLAB** (R2023a or compatible)  
- MATLAB Statistics and Machine Learning Toolbox  
- Brainlife.io (data source and expected upload platform)

---

## 🚀 Getting Started

1. Clone this repository  
2. Open MATLAB and add all project folders to your path  
3. Modify the `mainpath` variable in `importData.m` to point to your local data directory  
4. Run scripts in the following order:
   - `importData.m`
   - `tractProfile.m`
   - `Lebel2008Model.m` or `Lebel2010Model.m`
   - `inflectionPointTest*.m` (optional)

---

## 📈 Outputs

- Modeled developmental trajectories of dMRI metrics across tracts  
- Inflection point estimates for age-related transitions  
- Publication-quality plots for group-level comparisons

---

## 🧪 Data Availability

Final data will be made available through a public **Brainlife.io** project after publication.

---

## 🧵 Citation

If you use or reference this code, please cite the forthcoming paper:

> Arif, Z., Ren, X., Pestilli, F., & Vinci-Booher, S. (in progress). *White Matter Tracts Connecting Ventral and Dorsal Visual Streams Have Distinct Microstructural Profiles and Developmental Trajectories.*


