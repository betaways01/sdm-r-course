#!/bin/bash

# Render the book
Rscript -e "bookdown::render_book('index.Rmd', output_format = 'bookdown::bs4_book')"
# Copy new rendered files to docs
cp -r _book/* docs/

# Output success message
echo "Book rendered and updated in the docs folder successfully!"

