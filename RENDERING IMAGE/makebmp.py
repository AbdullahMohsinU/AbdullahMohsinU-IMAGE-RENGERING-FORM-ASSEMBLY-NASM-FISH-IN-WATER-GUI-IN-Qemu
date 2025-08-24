from PIL import Image, ImagePalette, ImageEnhance
import os

# Input / Output
input_file = "/mnt/data/fish.jpg"
output_file = "/mnt/data/fish_clear.bmp"

# Open JPG
img = Image.open(input_file)

# Resize with high-quality resampling
img = img.resize((320, 200), Image.LANCZOS)

# Boost sharpness + contrast for clearer image
img = ImageEnhance.Sharpness(img).enhance(1.5)
img = ImageEnhance.Contrast(img).enhance(1.2)

# Convert to 8-bit indexed palette with dithering
img = img.convert("P", palette=Image.Palette.ADAPTIVE, colors=256, dither=Image.FLOYDSTEINBERG)

# Save BMP
img.save(output_file, format="BMP")

# Verify file size
size = os.path.getsize(output_file)
size
