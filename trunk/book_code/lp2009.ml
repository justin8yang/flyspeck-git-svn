(*
Linear Programming Inequalities for 2009 proof.


******************
variables:

azim[dart]
ln[dart]     // =L[yn[dart]/2]
lnazim[dart]  // =ln[dart]*azim[dart]
yn[dart]
ye[dart]
sol[dart]
tau[dart]

******************

optional variables for later versions:
diag[dart,dart]  // diagonals.
azimdiag

*******************
invariance relations:
yn[dart] depends only on the node
ln[dart] depends only on the node
ye[dart] depends only on the edge
sol[dart] depends only on the face
tau[dart] depends only on the face

*******************
equality relations:
SUM of azim around each node is 2Pi.
SUM of lnazim around each node is 2Pi*ln
SUM of azim around each face is sol + (n-2)*Pi, where n = CARD(face).
ln[dart] = linear interpolation in yn[dart] of {2,1}, {2.52,0}.
  =   2*(2.52 - yn)/0.52
tau[face] = sol[face](1+delta0/Pi) - (delta0/Pi) SUM lnazim[dart],
   (sum over darts in the face)

*********************
consequences (do not enter directly into LP):

SUM of sol over faces is 4 Pi.
SUM of tau over faces is less than tgt

*********************
variable bounds:

0 <= azim <= Pi
0 <= ln <= 1.
0 <= lnazim <= Pi
2 <= yn <= 2.52
2 <= ye <= 2.52
0 <= sol <= 4*Pi
0 <= tau <= tgt (squander target)

******************
MAIN INEQUALITY:

SUM of ln over all nodes is >= 12.

******************
predicate:

face-has-card

******************

inequalities (new J-series):

******************
azim inequalities:

face-has-card 3 ==> 
  azim >= 0.852

******************
lnazim inequalities (including lnazim-azim):



******************
sol inequalities:

face-has-card 3 ==>  XX.
******************
tau inequalities:

face-has-card 3 ==> tau >= 0
face-has-card 4 ==> tau >= 0.206
face-has-card 5 ==> tau >= 0.483
face-has-card 6 ==> tau >= 0.760

face-has-card 3 ==>    // checked in cfsqp.
  tau + 0.626 azim - 0.77 >=0
  tau - 0.259 azim + 0.32 >=0
  tau - 0.507 azim + 0.724 >=0.
  tau + 0.001 - 0.18 (y1+y2+y3-6) - 0.125 (y4+y5+y6-6) >= 0.

face-has-card 4 ==>  // checked in cfsqp.
  tau + 4.72 azim - 6.248 >= 0.
  tau + 0.972 azim - 1.707 >= 0.
  tau + 0.7573 azim - 1.4333 >= 0.
  tau - 0.453 azim + 0.777 >= 0.


*)
