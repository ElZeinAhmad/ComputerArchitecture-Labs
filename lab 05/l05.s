.data

v1: .double 1, 2, 3, 4, 5, 6, 7, 8
	.double 1, 2, 3, 4, 5, 6, 7, 8
	.double 1, 2, 3, 4, 5, 6, 7, 8
	.double 1, 2, 3, 4, 5, 6

v2: .double 1, 2, 3, 4, 5, 6, 7, 8
	.double 1, 2, 3, 4, 5, 6, 7, 8
	.double 1, 2, 3, 4, 5, 6, 7, 8
	.double 1, 2, 3, 4, 5, 6

v3: .double 1, 2, 3, 4, 5, 6, 7, 8
	.double 1, 2, 3, 4, 5, 6, 7, 8
	.double 1, 2, 3, 4, 5, 6, 7, 8
	.double 1, 2, 3, 4, 5, 6

v4: .double 1, 2, 3, 4, 5, 6, 7, 8
	.double 1, 2, 3, 4, 5, 6, 7, 8
	.double 1, 2, 3, 4, 5, 6, 7, 8
	.double 1, 2, 3, 4, 5, 6

v5: .space 240
v6: .space 240


.text
	daddui r2,r0,0;
	daddui r1,r0,30;

cycle: 	l.d f3,v1(r2);
	   		l.d f4,v2(r2);
	   		l.d f5,v3(r2);
	   		l.d f6,v4(r2);
	   		mul.d f3,f3,f4;
	   		mul.d f7,f5,f6;
	   		daddi r1,r1,-1;
	   		add.d f4,f5,f3;
	   		div.d f7,f7,f4;
	   		s.d f4,v5(r2);
	   		s.d f7,v6(r2);
	  		daddui r2,r2,8;
	  		bnez r1,cycle;

ending: halt;

;1232 cc
