# The influence of temperature and body size on embryo packaging and developmental success of the exploited gastropod *Concholepas concholepas*

This repository contains scripts and workflows used to analyze embryo packing, oxygen availability, developmental asynchrony, and capsule traits in *Concholepas concholepas*.

The project integrates:
- Image-based embryo counting (Python + OpenCV / ImageJ)
- Data cleaning and outlier removal
- Statistical analyses (linear models, beta regression, quasi-binomial models)
- Figure generation for manuscript

---

## Repository structure

- `R/`: Data cleaning, statistical analyses, and figure generation
- `python/`: Image processing and embryo counting scripts
- `imagej/`: Macro for preprocessing images
- `data_dictionary/`: Variable definitions
- `data_example/`: Minimal dataset to test workflows
- `figs/`: Output figures (optional)

---

## Data availability

Full datasets are available in Zenodo:

[ADD ZENODO DOI HERE]

This repository does **not include full datasets** to keep it lightweight and ensure data integrity.

---

## Workflow overview

### 1. Image processing (optional)
- Binary images processed using OpenCV watershed segmentation
- Output: embryo counts per image (CSV)

### 2. Data cleaning
Run:
```r
1_cleaning_outliers.R
```
- Removes outliers using IQR criteria
- Generates:
  - `data_base_outliers_clean.rds`
  - `.xlsx` version for inspection

### 3. Statistical analysis
Run:
```r
2_data_analysis.R
```
Includes:
- Linear models (LM)
- Beta regression (proportional data)
- Quasi-binomial models

### 4. Regressions and scaling relationships
Run:
```r
4_regressions.R
```
Includes:
- Embryo number vs length
- Power-law scaling (area, volume)
- Standardized metrics

### 5. Capsule traits analysis
Run:
```r
6_capsule_analysis.R
```

### 6. Figures for manuscript
Run:
```r
3_figures_ms.R
7_figures_capsule.R
```

---

## Main variables

Key response variables include:

- `emb_estd_mm2`: Embryo density (number per mm²)
- `disp_o2`: Oxygen availability (% air saturation)
- `porc_inviables`: Percentage of non-viable embryos
- `porcentaje_asincronia`: Developmental asynchrony (%)
- `grosor_cap`: Capsule thickness (mm)
- `peso_area`: Dry weight per capsule area

See full definitions in:
`data_dictionary/data_dictionary.md`

---

## Requirements

R packages:
```
tidyverse
cowplot
janitor
emmeans
betareg
sjlabelled
ggpmisc
segmented
here
writexl
ragg
```

Python:
```
opencv-python
numpy
pandas
```

---

## Notes

- Missing values (`NA`) are expected due to different capsule types having different response variables.
- Some analyses subset data depending on:
  - capsule type (`capsula`)
  - developmental stage (`estadio`)
  - experimental temperature

---

## License

Specify your license here (recommended: MIT or GPL-3).

---

## Citation

See `CITATION.cff` for citation details.
