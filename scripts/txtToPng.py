from PIL import Image
import numpy as np

def txt_to_png(txt_file, png_file):
    with open(txt_file, 'r') as f:
        lines = [line.strip().split() for line in f if line.strip()]
    
    array = np.array([[int(x) for x in row] for row in lines], dtype=np.uint8)

    img = Image.fromarray(array, mode='L')  # 'L' = 8-bit grayscale
    img.save(png_file)

# Example usage:
txt_to_png('ofmap.txt', 'ofmap.png')
