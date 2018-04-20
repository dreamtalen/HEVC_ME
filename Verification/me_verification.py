from PIL import Image

cur_file = Image.open('cur.bmp')
cur_x, cur_y = cur_file.size

x = cur_x/2 - 32
y = cur_y/2 - 32
w = 64
h = 64

cur_center = cur_file.crop((x, y, x+w, y+h))
cur_center.save('cur_center.bmp')

ref_file = Image.open('ref.bmp')
ref_x, ref_y = ref_file.size

x = ref_x/2 - 96
y = ref_y/2 - 96
w = 192
h = 192

ref_center = ref_file.crop((x, y, x+w, y+h))
ref_center.save('ref_center.bmp')

# print cur_center.getpixel((0,0))