# Prolog Logic Puzzles & Data Analysis

> **Disclaimer:** This repository contains an academic project developed for the Logic for Programming (LP) course at Instituto Superior Técnico (IST). It is shared for portfolio purposes only. Current students should adhere to academic integrity guidelines.

## Overview

This repository showcases the use of Prolog (Declarative Programming) to solve complex logical problems, handle data correlation, and build constraint satisfaction algorithms. Instead of telling the computer *how* to solve a problem step-by-step, this project defines the *rules* and lets the Prolog inference engine find the valid solutions.

## Core Modules

1. **Data Inference Engine** — Analyzes a demographic database of students to extract statistical metrics. Calculates averages and probabilities of specific conditions (e.g., screen time vs. grades), and implements the Pearson correlation coefficient from scratch using recursive list operations (`correlacao/3`).

2. **Wordaily / Wordle Game Logic** — Implements the core hint-generation logic for a word-guessing game, with predicates (`pista1`, `pista2`, `pista3`) that evaluate exact matches, characters present in the wrong position, and missing characters between a guessed word and a secret word.

3. **Constraint Satisfaction Problem (CSP)** — Solves a scheduling problem for a 7-movie marathon (`maratonaFilmes/3`). Given dynamic constraints such as "horror movies can only play after 20h", "movie A must precede movie B", or "movie C cannot play in slot 2", the solver uses permutations to recursively search and filter for all valid scheduling sequences.

## Tech Stack

- **Prolog** (SWI-Prolog)
- **Paradigm:** Declarative and Logic Programming
