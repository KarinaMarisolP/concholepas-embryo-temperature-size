
---

# 📘 data_dictionary.md (basado en tu CSV + scripts)

```markdown
# Data Dictionary – Concholepas embryo study

## General structure

Each row represents a capsule observation associated with a female under specific experimental conditions.

---

## Identification variables

| Variable | Description |
|----------|------------|
| especie | Species name |
| tipo_parche | Experimental patch type |
| id | Unique sample ID |
| id_compuesto | Composite identifier |

---

## Experimental conditions

| Variable | Description |
|----------|------------|
| categoria_talla_hembra | Female size category (mm) |
| temp_incubacion_procedencia_hembra | Temperature associated with female origin |
| temp_incubacion_parche | Experimental incubation temperature |
| estadio | Developmental stage (e.g., Early, Late) |
| capsula | Capsule type (Emp_Inv, Asinc, DispO2) |

---

## Capsule morphology

| Variable | Description |
|----------|------------|
| largo_mm | Capsule length (mm) |
| ancho_promedio | Capsule width (mm) |
| area_capsula | Capsule area (mm²) |

---

## Embryo metrics

| Variable | Description |
|----------|------------|
| embriones_totales | Total number of embryos |
| emb_estd_mm2 | Standardized embryo density (embryos per mm²) |

Derived variables (computed in scripts):

| Variable | Description |
|----------|------------|
| volumen_capsula_mm3 | Capsule volume (mm³) |
| embriones_por_volumen | Embryo density per volume |
| embriones_por_vol_estd | Standardized embryo density using scaling exponent |

---

## Viability

| Variable | Description |
|----------|------------|
| inviables_totales | Number of non-viable embryos |
| porc_inviables | Percentage of non-viable embryos |

---

## Asynchrony

| Variable | Description |
|----------|------------|
| n_total_asinc | Total embryos evaluated |
| n_retrasadas_asinc | Delayed embryos |
| porcentaje_asincronia | Percentage of asynchrony |
| no_retrasados | Derived: non-delayed embryos |

---

## Oxygen availability

| Variable | Description |
|----------|------------|
| disp_o2 | Oxygen availability (% air saturation) |

---

## Capsule traits dataset (separate)

| Variable | Description |
|----------|------------|
| grosor_cap | Capsule thickness (mm) |
| peso_area | Dry weight per capsule area (mg mm⁻²) |
| talla | Female size category |

---

## Notes

- Some variables are only present for specific capsule types.
- Missing values (`NA`) are expected and reflect experimental design.
- Outliers were removed using IQR-based filtering.
