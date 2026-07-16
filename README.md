# SSA-CSA: Search Space Aware Crow Search Algorithm

![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)
![MATLAB](https://img.shields.io/badge/Language-MATLAB-orange.svg)
[![arXiv](https://img.shields.io/badge/arXiv-2604.06246-b31b1b.svg)](https://arxiv.org/abs/2604.06246)

<p align="center">
  <img src="https://raw.githubusercontent.com/Pooryamn/SSA-CSA/refs/heads/master/Overview.jpg" alt="SSA-CSA overview" width="1200">
</p>

**SSA-CSA** is a metaheuristic optimization algorithm that automatically tunes the hyperparameters of iterative reconstruction algorithms for Cone-Beam Computed Tomography (CBCT). It is a search-space-aware version of the Crow Search Algorithm (CSA), built to find good reconstruction parameters **without needing a reference image**.

This repository contains the official MATLAB implementation used in our paper.

---

## Table of Contents

- [About](#about)
- [The Paper](#the-paper)
- [Key Features](#key-features)
- [How It Works](#how-it-works)
- [Repository Structure](#repository-structure)
- [Requirements](#requirements)
- [Getting Started](#getting-started)
- [Available Options](#available-options)
- [Related Tools](#related-tools)
- [Citation](#citation)
- [License](#license)
- [Contact](#contact)

---

## About

Iterative reconstruction algorithms (like ASD-POCS or PICCS) can produce high-quality CT images from fewer projections. This helps lower the radiation dose given to patients. But these algorithms have several hyperparameters that must be tuned carefully. Doing this by hand takes time and requires expert knowledge.

SSA-CSA solves this problem by searching for good hyperparameters automatically. It uses a modified Crow Search Algorithm with a "search-space-aware" strategy, which means the algorithm learns which regions of the parameter space are promising and focuses its search there.

## The Paper

This code was developed for the following paper:

> **No-reference based automatic parameter optimization for iterative reconstruction using a novel search space aware crow search algorithm**
> Poorya MohammadiNasab, Ander Biguri, Philipp Steininger, Peter Keuschnigg, Lukas Lamminger, Agnieszka Lach, S M Ragib Shahriar Islam, Anna Breger, Clemens Karner, Carola-Bibiane Schönlieb, Wolfgang Birkfellner, Sepideh Hatamikia
> 📄 [arXiv:2604.06246](https://arxiv.org/abs/2604.06246)

The paper introduces a framework that can tune the full set of hyperparameters of a CBCT iterative reconstruction algorithm at once, using only no-reference image quality metrics. The method is tested on data from three different imaging machines and four real datasets.

## Key Features

- **Fully automatic tuning** — no reference (ground-truth) image is required.
- **Works with several TIGRE reconstruction algorithms**: ASD-POCS, OS-ASD-POCS, PICCS, PCSD, and AwPCSD.
- **Search-space-aware global search** — a weight map learns which parameter regions are promising and guides the search there.
- **Multiple population initialization strategies**, including random, Latin Hypercube Sampling, and chaos-based methods.
- **Pareto-front-based selection** to pick the best "pioneer" solutions during the search.
- **Ablation variants** of the standard Crow Search Algorithm included, for direct comparison.
- **A range of image quality metrics**, covering reference-based, region-based, and no-reference options.

## How It Works

The algorithm treats each candidate parameter set as a "crow" that searches for the best "hiding spot" (i.e., the best combination of parameters). At each step, SSA-CSA does the following:

1. **Fitness Evaluation** — each candidate parameter set is used to reconstruct an image, which is then scored with an image quality metric.
2. **Pioneer Selection** — the most promising candidates are selected using Pareto-front analysis.
3. **Search-Space Learning** — a weight map is updated to mark which regions of the parameter space look promising.
4. **Position Update** — strong candidates search locally around the best solutions, while weaker candidates explore new regions using weighted sampling guided by the weight map.

A chaotic map (Sine, Chebyshev, or Tent) is used to add controlled randomness and improve diversity during the search.

## Repository Structure

```
SSA-CSA/
├── Algorithms/
│   ├── SSACSA.m                       # Main proposed algorithm
│   └── Ablation/                      # Baseline CSA variants, used for comparison
│       ├── CSA.m
│       ├── CSA_Balance.m
│       ├── CSA_SearchSpaceAware.m
│       ├── CSA_SearchSpaceAware_SuperiorSet.m
│       └── CSA_SuperiorSet.m
├── Chaos_maps/                        # Chaotic sequence generators
│   ├── Chebyshev_Map.m
│   ├── Sin_Map.m
│   └── Tent_Map.m
├── init_methods/                      # Population initialization strategies
│   ├── RND_init.m
│   ├── LHS_init.m
│   ├── DLU_init.m
│   ├── CLHS_init.m
│   ├── Chaotic_init.m
│   ├── CDLU_init.m
│   └── weighted_init.m
├── metrics/                           # Image quality metrics
│   ├── CNR.m / GCNR.m                 # Region-based metrics
│   ├── SNR.m / SNR_FREQ.m / ...       # No-reference metrics
│   ├── CorrCoef.m                     # Reference-based metric
│   └── Frequency_energy.m, Tenengrad.m, Laplacian_Variance.m
├── utilities/
│   ├── mat2tiff.py                    # Converts .mat image volumes to TIFF stacks
│   ├── utils_Individuals/             # Checks and repairs candidate solutions
│   ├── utils_SuperiorSet/             # Pareto-front tools
│   └── utils_WeightMap/               # Search-space-aware weight map tools
├── main.m                             # Example script to run the optimizer
├── objective.m                        # Fitness function (reconstruction + quality metric)
└── LICENSE
```

## Requirements

- **MATLAB** (tested with recent releases).
- **[TIGRE](https://github.com/CERN/TIGRE)** toolbox, added to your MATLAB path. TIGRE provides the reconstruction algorithms (ASD-POCS, PICCS, etc.) that SSA-CSA optimizes.
- **Python 3** with `scipy` and `imageio`, only if you want to use the `mat2tiff.py` helper script.
- Your own CBCT projection data (geometry, projections, and angles) in a format compatible with TIGRE.

## Getting Started

1. Install and set up [TIGRE](https://github.com/CERN/TIGRE) in MATLAB.
2. Clone this repository:
   ```bash
   git clone https://github.com/Pooryamn/SSA-CSA.git
   ```
3. Prepare your dataset. `main.m` expects projection, angle, and geometry `.mat` files (the example script uses the SophiaBeads dataset as a sample).
4. Open `main.m` and set your optimization settings:
   - `flock_size` — number of candidate solutions.
   - `Max_iter` — number of optimization iterations.
   - `Recon_algorithm` — which TIGRE algorithm to tune (e.g., `"ASD_POCS"`).
   - `Parameter_names` and `parameter_bounds` — which hyperparameters to optimize, and their search ranges.
   - `metric` — which image quality metric to use as the fitness function.
5. Run `main.m`. The script will return:
   - `solution` — the best parameter set found.
   - `score` — the best fitness value achieved.

## Available Options

**Initialization methods** (`init_methods/`)

| Method | Description |
|---|---|
| `RND_init` | Random initialization |
| `LHS_init` | Latin Hypercube Sampling |
| `DLU_init` | Distributed Linear Uniform initialization |
| `CLHS_init` | Chaotic Latin Hypercube Sampling |
| `Chaotic_init` | Chaotic sampling |
| `CDLU_init` | Chaotic Distributed Linear Uniform initialization (used by default in `main.m`) |
| `weighted_init` | Weighted sampling, guided by the search-space weight map |

**Optimization algorithms** (`Algorithms/`)

| Algorithm | Description |
|---|---|
| `SSACSA` | The proposed method — search-space-aware CSA with Pareto-based pioneer selection |
| `CSA` | Standard Crow Search Algorithm (baseline) |
| `CSA_Balance` | CSA with a modified local/global search balance |
| `CSA_SuperiorSet` | CSA with Pareto-front-based pioneer selection |
| `CSA_SearchSpaceAware` | CSA with the search-space weight map, without Pareto selection |
| `CSA_SearchSpaceAware_SuperiorSet` | Combines search-space awareness and Pareto selection |

**Image quality metrics** (`metrics/`)

| Type | Metrics |
|---|---|
| Reference-based (needs a reference image) | RMSE, CC, SSIM, PSNR |
| Region-based (needs a foreground/background region) | CNR, GCNR |
| No-reference | SNR, SNR_HFER, SNR_Tenegrad, SNR_Laplac, HFER, Laplac |

## Related Tools

This project builds on two open-source tools:

- **[TIGRE](https://github.com/CERN/TIGRE)** — Tomographic Iterative GPU-based Reconstruction toolbox, developed by CERN and the University of Bath. TIGRE is a MATLAB/Python toolbox for fast, GPU-accelerated CT and CBCT reconstruction. It provides the iterative reconstruction algorithms (such as ASD-POCS and PICCS) that SSA-CSA tunes.

- **[LDCTIQAC2023](https://github.com/Ewha-AI/LDCTIQAC2023)** — code from the Low-dose Computed Tomography Perceptual Image Quality Assessment Challenge 2023. It contains deep learning models that predict perceptual image quality scores for low-dose CT images, trained to match ratings given by radiologists. This can be useful as an additional, learning-based image quality metric.

## Citation

If you use this code in your research, please cite:

```bibtex
@article{mohammadinasab2026ssacsa,
  title   = {No-reference based automatic parameter optimization for iterative
             reconstruction using a novel search space aware crow search algorithm},
  author  = {MohammadiNasab, Poorya and Biguri, Ander and Steininger, Philipp and
             Keuschnigg, Peter and Lamminger, Lukas and Lach, Agnieszka and
             Islam, S M Ragib Shahriar and Breger, Anna and Karner, Clemens and
             Sch{\"o}nlieb, Carola-Bibiane and Birkfellner, Wolfgang and
             Hatamikia, Sepideh},
  journal = {arXiv preprint arXiv:2604.06246},
  year    = {2026}
}
```

## License

This project is released under the [MIT License](LICENSE).

## Contact

Developed by **Poorya MohammadiNasab** ([GitHub](https://github.com/Pooryamn)).
For questions or issues, please open an [issue](https://github.com/Pooryamn/SSA-CSA/issues) on this repository.
