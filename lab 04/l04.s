.data
v1:	.double	1, 2, 3, 4, 5, 6, 7, 8
		.double 9, 10, 11, 12, 13, 14, 16
  	.double 16, 17, 18, 19, 20
v2:	.double 1, 2, 3, 4, 5, 6, 7, 8
		.double 9, 10, 11, 12, 13, 14, 16
  	.double 16, 17, 18, 19, 20
v3: .double 1, 2, 3, 4, 5, 6, 7, 8
		.double 9, 10, 11, 12, 13, 14, 16
  	.double 16, 17, 18, 19, 20
v4: .double 1, 2, 3, 4, 5, 6, 7, 8
		.double 9, 10, 11, 12, 13, 14, 16
  	.double 16, 17, 18, 19, 20
v5: .double 0, 0, 0, 0, 0, 0, 0, 0
		.double 0, 0, 0, 0, 0, 0, 0, 0
  	.double 0, 0, 0, 0



.text
main: daddui r1,r0,0
      daddui r2,r0,10
loop: l.d  f1,v1(r1)
      l.d  f2,v2(r1)
      mul.d  f5,f1,f2
      l.d  f3,v3(r1)
      l.d  f4,v4(r1)
      div.d f6, f3, f4
      sub.d  f5,f5,f6
      s.d  f5,v5(r1)
      daddui  r1,r1,8
      daddi  r2,r2,-1
      bnez  r2,loop
      halt
