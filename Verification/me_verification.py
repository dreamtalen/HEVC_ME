from PIL import Image

def main():
	cur_file = Image.open('cur.bmp').convert('L')
	cur_x, cur_y = cur_file.size

	x = cur_x/2 - 32
	y = cur_y/2 - 32
	w = 64
	h = 64

	cur_center = cur_file.crop((x, y, x+w, y+h))
	cur_center.save('cur_center.bmp')

	ref_file = Image.open('ref.bmp').convert('L')
	ref_x, ref_y = ref_file.size

	x = ref_x/2 - 96
	y = ref_y/2 - 96
	w = 192
	h = 192

	ref_center = ref_file.crop((x, y, x+w, y+h))
	ref_center.save('ref_center.bmp')

	# print cur_center.getpixel((0,0))
	def calculate_abs(x_start, y_start, sub_area):
		print 'ref_x_start:', x_start,'ref_y_start:', y_start
		sad_sum = 0
		for x in range(x_start, x_start + 32):
			for y in range(y_start, y_start + 32):
				ref_pixel = ref_center.getpixel((x+32*((sub_area-1)/2), y+32*((sub_area-1)%2)))
				cur_pixel = cur_center.getpixel(( x-x_start+32*((sub_area-1)/2), y-y_start+32*((sub_area-1)%2)))
				sad_sum += abs(ref_pixel-cur_pixel)
				# print x, y, sad_sum
		print sad_sum

	search_column = input('Enter search column: ')
	search_row = input('Enter search row: ')
	sub_area = input('Enter sub area: ')

	print 'search_column:', search_column, 'search_row:', search_row, 'sub_area:', sub_area

	if search_column < 8:
		# search area 1
		calculate_abs(8*(search_column-1), 8*(search_row-1), sub_area)
	elif search_column in (8, 16, 24):
		# search area 2
		if search_row < 8:
			calculate_abs(8*(search_column-1), 8*(search_row-1), sub_area)
		elif 8 <= search_row <= 24:
			calculate_abs(8*(search_column-1), 56+search_row-8, sub_area)
		else:
			calculate_abs(8*(search_column-1), 72+8*(search_row-24), sub_area)
	elif 8 < search_column < 24:
		# search area 3
		calculate_abs(48+search_column, 55+search_row, sub_area)
	else:
		# search area 1
		calculate_abs(8*(search_column-15), 8*(search_row-1), sub_area)

if __name__ == '__main__':
	main()


