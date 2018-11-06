from vpython import *
import csv

scene.height=800
scene.width=800
scene.range=10
box(pos=vector(0,0,0), size=vector(300,300,300), color = color.green, opacity=0.3)
ball = sphere(pos = vector(-150,0,0), radius=5, color=color.red)

text(text="CAM1", pos=vector(0.774, -2.1147, 0.5267), color=color.blue, height=0.3)
sphere(pos=vector(0.774, -2.1147, 0.5267), radius=0.1, color=color.blue)

text(text="CAM2", pos=vector(-0.7103, -2.0883, 0.5037), color=color.blue, height=0.3)
sphere(pos=vector(-0.7103, -2.0883, 0.5037), radius=0.1, color=color.blue)

text(text="CAM3", pos=vector(-0.0901, 1.9924, 1.2094), color=color.blue, height=0.3)
sphere(pos=vector(-0.0901, 1.9924, 1.2094), radius=0.1, color=color.blue)


def animate():
	with open('s1.csv', newline='') as csvfile:
		r = csv.reader(csvfile, delimiter=',', quotechar='|')
		for row in r:
			print(row)
			sphere(pos=vector(float(row[0]), float(row[1]), float(row[2])), radius=0.1, color=color.white)
			rate(50)


scene.bind('click', animate)


