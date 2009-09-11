(* DIEPKY 	   
(* Formal Spec of Blueprint Chapter  on Trigonometry *)
	   

	   
needs "Multivariate/flyspeck.ml";;
needs "sphere.hl";;
needs "thales_tactic.ml";;

prioritize_real();;


(* sin and cos have already been defined in HOL Light.
   Here are several relevant theorems from HOL Light.  *)
	   
sin;;
cos;;

SIN_0;; (* sin(0) = 0 *)
COS_0;; (* cos(0) =1 *)
SIN_CIRCLE;; (* blueprint/lemma:circle *)

SIN_ADD;; (* blueprint/lemma:sin-add *)
COS_ADD;; (* blueprint/lemma:sin-add *)

COS_NEG;; (* blueprint/lemma:cos-neg *)
SIN_NEG;; (* blueprint/lemma:cos-neg *)

SIN_PI2;; (* blueprint/lemma:sin-pi2 *)
COS_SIN;; (* blueprint/lemma:cos-sin *)

tan;; (* blueprint/def:tan *)
TAN_ADD;; (* blueprint/lemma:tan-add *)
TAN_PI4;; (* blueprint/tan-pi4 *)

atn;; (* blueprint/def:arctan *)
acs;; (* blueprint/def:acs *)
asn;; (* blueprint/def:arcsin *)

(* arctan2 function *)
atn2;;  (* definitions_kepler.ml *)

(* This is close to CIRCLE_SINCOS *)

let atn2_spec_t = `!x y. ?r. ((-- pi < atn2(x, y)) /\ (atn2(x,y) <= pi) /\
     (x = r* (cos(atn2(x,y)))) /\ (y = r* (sin (atn2( x, y)))) /\ 
     (&0 <= r))`;;

(* lemma:sin-arccos *)

SIN_ACS;;

(* lemma:arccos-arctan *)

let acs_atn2_t = `!y. (-- &1 <= y /\ y <=  &1) ==> (acs y = pi/(&2) - atn2(sqrt(&1 - y pow 2),y))`;;


(* Jordan/metric_spaces.ml:cauchy_schwartz  cauchy_schwartz *)
(* Jordan/metric_spaces.ml:norm_triangle    triangle inequality *)

(* affine geometry definitions are in definitions_kepler.ml *)

let arcVarc_t = `!u v w:real^3. ~(u=v) /\ ~(u=w) ==> arcV u v w = arclength (dist( u, v)) (dist( u, w)) (dist( v, w))`;;

let law_of_cosines_t = `!a b c. (&0 < a) /\ (&0 < b) /\ (&0 <= c) /\ (c <= a + b) /\ (a <= b + c) /\ (b <= c + a) ==>
   ((c pow 2) = (a pow 2) + (b pow 2) - &2 * a * b * (cos(arclength a b c)))`;;

let law_of_sines_t = `!a b c. (&0 < a) /\ (&0 < b) /\ (&0 <= c) /\ (c <= a + b) /\ (a <= b + c) /\ (b <= c + a) ==>
   (&2 * a * b * sin (arclength a b c) = sqrt(ups_x (a pow 2) (b pow 2) (c pow 2)))`;;

let cross_mag_t = `!u v. norm (u cross v) = (norm u) * (norm v) * sin(arcV (vec 0) u v)`;;

let cross_skew_t = `!u v. (u cross v) = -- (v cross u)`;;

let cross_triple_t = `!u v w.  (u cross v) dot w =  (v cross w) dot u`;;


(* law of cosines *)

let spherical_loc_t = `!v0 va vb vc:real^3.
  ~(collinear {v0,va,vc}) /\ ~(collinear {v0,vb,vc}) ==>
        (
    let gamma = dihV v0 vc va vb in
    let a = arcV v0 vb vc in
    let b = arcV v0 va vc in
    let c = arcV v0 va vb in
      (cos(gamma) = (cos(c) - cos(a)*cos(b))/(sin(a)*sin(b))))`;;

let spherical_loc2_t = `!v0 va vb vc:real^3.
 ~(collinear {v0,va,vc}) /\ ~(collinear {v0,vb,vc}) ==>
        (
    let alpha = dihV v0 va vb vc in
    let beta = dihV v0 vb va vc in
    let gamma = dihV v0 vc vb va in
    let c = arcV v0 va vb in
      (cos(c) = (cos(gamma) + cos(alpha)*cos(beta))/(sin(alpha)*sin(beta))))`;;

let dih_formula_t = `!v0 v1 v2 v3:real^3. 
   ~(collinear {v0,v1,v2}) /\ ~(collinear {v0,v1,v3}) ==>
   (
   let (x1,x2,x3,x4,x5,x6) = xlist v0 v1 v2 v3 in
    (dihV v0 v1 v2 v3  = dih_x x1 x2 x3 x4 x5 x6)
   )`;;

let dih_x_acs_t = `!x1 x2 x3 x4 x5 x6.
   (&0 < ups_x x1 x2 x6) /\ (&0 < ups_x x1 x3 x5) /\ (&0 <= delta_x x1 x2 x3 x4 x5 x6) /\ (&0 <= x1) ==>
   dih_x x1 x2 x3 x4 x5 x6 = acs ((delta_x4 x1 x2 x3 x4 x5 x6)/
  ((sqrt (ups_x x1 x2 x6)) * (sqrt (ups_x x1 x3 x5))))`;;

let beta_cone_t = `!v0 v1 v2 v3:real^3.
    ~(collinear {v0,v1,v2}) /\ ~(collinear {v0,v1,v3}) /\ 
    (dihV v0 v3 v1 v2 = pi/(&2)) ==>
    (dihV v0 v1 v2 v3 = beta (arcV v0 v1 v3) (arcV v0 v1 v2))`;;

let euler_triangle_t = `!v0 v1 v2 v3:real^3. 
    let p = euler_p v0 v1 v2 v3 in
    let (x1,x2,x3,x4,x5,x6) = xlist v0 v1 v2 v3 in
    let alpha1 = dihV v0 v1 v2 v3 in
    let alpha2 = dihV v0 v2 v3 v1 in
    let alpha3 = dihV v0 v3 v1 v2 in
    let d = delta_x x1 x2 x3 x4 x5 x6 in
    ((&0 < d) ==>
      (alpha1 + alpha2 + alpha3 - pi = pi - &2 * atn2(sqrt(d), (&2 * p))))`;;

let polar_coords_t = `!x y. (x = (radius (x,y))*(cos(polar_angle x y))) /\
     (y = (radius (x, y))*(sin(polar_angle x y)))`;;

let polar_cycle_rotate_t = `!V psi u f.
       (!x y. f (x,y) = (x*cos psi + y*sin psi, -- x*sin psi + y*cos psi)) /\
       FINITE V  /\ V u ==>
       (polar_cycle (IMAGE f V) (f u) =  f (polar_cycle V u))`;;

let thetaij_t = `!theta1 theta2 k12 k21 theta12 theta21.
     (&0 <= theta1) /\ (theta1 < &2 * pi) /\ (&0 <= theta2) /\ (theta2 < &2 * pi) /\
     (theta12 = theta2 - theta1 + &2 * pi * (&k12)) /\
     (theta21 = theta1 - theta2 + &2 * pi * (&k21)) /\
     (&0 <= theta12) /\ (theta12 < &2 * pi) /\
     (&0 <= theta21) /\ (theta21 < &2 * pi) ==>
     ((theta12+theta21) = (if (theta1=theta2) then (&0) else (&2 * pi)))`;;


let thetapq_wind_t = `!W n thetapq kpq. 
    (!x y. (W (x,y) ==> (~(x= &0) /\ ~(y = &0)))) /\
    (W HAS_SIZE n) /\
    (!u v. W u /\ W v ==> 
       ((thetapq u v = polar_angle (FST v) (SND v) -  polar_angle (FST u) (SND u) + &2 * pi * kpq u v) /\  (&0 <= thetapq u v) /\ (thetapq u v < &2 * pi)))
    ==>
    ((!u i j. (W u /\ (0 <= i) /\ (i <= j) /\ (j < n)) ==>
        thetapq u (iter i (polar_cycle W) u) + thetapq (iter i (polar_cycle W) u) (iter j (polar_cycle W) u) = thetapq u (iter j (polar_cycle W) u)) /\
    ((!u v.  (W u /\ W v) ==> (polar_angle (FST u) (SND u) = polar_angle (FST v) (SND v))) \/
     (!u. (W u)  ==> (sum(0 .. n-1) (\i. thetapq (iter i (polar_cycle W) u) (iter (SUC i) (polar_cycle W) u))  = &2 * pi)) ))`;;

let zenith_t = `!u v w:real^3.  ~(u=v) /\ ~(w = v)  ==>
   (?u' r phi e3.
        (phi = arcV v u w) /\ (r = dist( u, v)) /\ ((dist( w, v)) % e3 = (w-v)) /\
  ( u' dot e3 = &0) /\ (u = v + u' + (r*cos(phi)) % e3))`;;

let spherical_coord_t = `!u v w u' e1 e2 e3 r phi theta.
        ~(collinear {v,w,u}) /\ ~(collinear {v,w,u'}) /\
       orthonormal e1 e2 e3 /\ ((dist( v, w)) % e3 = (v-w)) /\
  (aff_gt {v,w} {u} e1) /\ (e2 = e3 cross e1) /\
  (r = dist( v, u')) /\ (phi = arcV v u' w) /\ (theta = azim v w u u') ==>
  (u' = u + (r*cos(theta)*sin(phi)) % e1 + (r*sin(theta)*sin(phi)) % e2 
      + (r * cos(phi)) % e3)`;;

let polar_coord_zenith_t = `!u v w u' n.
  ~(collinear {u,v,w}) /\ (aff {u,v,w} u') /\ ~(u' = v) /\
  (n = (w - v) cross (u - v)) ==>
   (arcV v (v + n) u' = pi/ (&2))`;;

let azim_pair_t = `!v w w1 w2.
    let a1 = azim v w w1 w2 in
    let a2 = azim v w w2 w1 in
    (cyclic_set {w1,w2} v w) ==> 
      (a1 + a2 = (if (a1 = &0) then (&0) else (&2 * pi)))`;;
  
	   

   (cyclic_set W v w) /\
   (W HAS_SIZE n) ==>
   (!p i j. (W p /\ (0 <= i) /\ (i <= j) /\ (j < n)) ==> 
       ((!q.  W q ==> (azim v w p q = &0) ) \/
       (sum(0 .. n-1) (\i. azim v w (iter i (azim_cycle W v w) p) (iter (SUC i) (azim_cycle W v w) p)) = &2 * pi   )))`;;

let dih_azim_t = `!v w v1 v2. 
   ~(collinear {v,w,v1}) /\ ~(collinear {v,w,v2}) ==>
  (cos(azim v w v1 v2) = cos(dihV v w v1 v2))`;;

let sph_triangle_ineq_t = `!p u v w:real^3.
   ~(collinear {p,u,w}) /\ ~(collinear {p,u,v}) /\ ~(collinear {p,v,w}) ==>
  (arcV p u w <= arcV p u v + arcV p v w)`;;

let sph_triangle_ineq_sum_t = `!p:real^3 u r.
   (!i. (i < r) ==> ~(collinear {p,u i, u (SUC i)})) /\
   ~(collinear {p,u 0, u r}) ==>
   (arcV p (u 0) (u r) <= sum(0 .. r-1) (\i. arcV p (u i) (u (SUC i))))`;;

(* obligations created by definition by specification, to make them useable. *)

(* [deprecated]
let aff_insert_sym_t = `aff_insert_sym`;;
let aff_sgn_insert_sym_gt_t = `aff_sgn_insert_sym (\t. &0 < t)`;;
let aff_sgn_insert_sym_ge_t = `aff_sgn_insert_sym (\t. &0 <= t)`;;
let aff_sgn_insert_sym_lt_t = `aff_sgn_insert_sym (\t. t < &0)`;;
let aff_sgn_insert_sym_le_t = `aff_sgn_insert_sym (\t. t <= &0)`;;
*)

let azim_hyp_t = `azim_hyp`;;
let azim_cycle_hyp_t = `azim_cycle_hyp`;;

(* definitions without obligations *)

(* [deprecated]
let aff_t = `(aff {} = {}) /\
         (!v S.
              FINITE S
              ==> aff (v INSERT S) =
                  (if v IN S then aff S else aff_insert v (aff S)))`;;

let aff_gt_t = `!S1.
          (aff_gt S1 {} = aff S1) /\
             (!v S.
                  FINITE S
                  ==> aff_gt S1 (v INSERT S) =
                      (if v IN S
                       then aff_gt S1 S
                       else aff_sgn_insert (\t. &0 < t) v (aff_gt S1 S)))`;;

let aff_ge_t = `!S1.
          (aff_ge S1 {} = aff S1) /\
             (!v S.
                  FINITE S
                  ==> aff_ge S1 (v INSERT S) =
                      (if v IN S
                       then aff_ge S1 S
                       else aff_sgn_insert (\t. &0 <= t) v (aff_ge S1 S)))`;;

let aff_lt_t = `!S1.
          (aff_lt S1 {} = aff S1) /\
             (!v S.
                  FINITE S
                  ==> aff_lt S1 (v INSERT S) =
                      (if v IN S
                       then aff_lt S1 S
                       else aff_sgn_insert (\t. t < &0) v (aff_lt S1 S)))`;;

let aff_le_t = `!S1.
          (aff_le S1 {} = aff S1) /\
             (!v S.
                  FINITE S
                  ==> aff_le S1 (v INSERT S) =
                      (if v IN S
                       then aff_le S1 S
                       else aff_sgn_insert (\t. t <= &0) v (aff_le S1 S)))`;;
*)

let azim_t = `!v w w1 w2 e1 e2 e3.
         ?psi h1 h2 r1 r2.
                 ~collinear {v, w, w1} /\
                 ~collinear {v, w, w2} /\
                 orthonormal e1 e2 e3 /\
                 (dist( w, v) % e3 = w - v)
             ==> &0 <= azim v w w1 w2 /\
                 azim v w w1 w2 < &2 * pi /\
                 &0 < r1 /\
                 &0 < r2 /\
                 w1 =
                 (r1 * cos psi) % e1 + (r1 * sin psi) % e2 + h1 % (w - v) /\
                 (w2 =
                 (r2 * cos (psi + azim v w w1 w2)) % e1 +
                 (r2 * sin (psi + azim v w w1 w2)) % e2 +
                 h2 % (w - v))`;;

let azim_cycle_t = `!W proj v w e1 e2 e3 p.
             W p /\
             cyclic_set W v w /\
             (dist( v, w) % e3 = w - v) /\
             orthonormal e1 e2 e3 /\
             (!u x y.
                  proj u = x,y <=> (?h. u = v + x % e1 + y % e2 + h % e3))
         ==> (proj (azim_cycle W v w p) = polar_cycle (IMAGE proj W) (proj p))`;;


(* signature for trig theorems.
   This is the list of theorems that should be provided by
   an implementation of the blueprint on trig.
   The signature can be extended, but care needs to made
   in removing anything, because it may create incompatibilities
   with other pieces of code. *)

(* In every case, there is a term giving the precise theorem to
   be proved *)

module type Trigsig = sig
  val atn2_spec : thm (* atn2_spec_t  *)
  val acs_atn2: thm  (* acs_atn2_t *)
  val arcVarc : thm (*  arcVarc_t *)
  val law_of_cosines : thm (*  law_of_cosines_t *)
  val law_of_sines : thm (*  law_of_sines_t *)
  val cross_mag : thm (*  cross_mag_t *)
  val cross_skew : thm (*  cross_skew_t *)
  val cross_triple : thm (*  cross_triple_t *)
  val spherical_loc : thm (*  spherical_loc_t *)
  val spherical_loc2 : thm (*  spherical_loc2_t *)
  val dih_formula : thm (*  dih_formula_t *)
  val dih_x_acs : thm (*  dih_x_acs_t *)
  val beta_cone : thm (*  beta_cone_t *)
  val euler_triangle : thm (*  euler_triangle_t *)
  val polar_coords : thm (*  polar_coords_t *)
  val polar_cycle_rotate : thm (*  polar_cycle_rotate_t *)
  val thetaij : thm (*  thetaij_t *)
  val thetapq_wind : thm (*  thetapq_wind_t *)
  val zenith : thm (*  zenith_t *)
  val spherical_coord : thm (*  spherical_coord_t *)
  val polar_coord_zenith : thm (*  polar_coord_zenith_t *)
  val azim_pair : thm (*  azim_pair_t *)
  val azim_cycle_sum : thm (*  azim_cycle_sum_t *)
  val dih_azim : thm (*  dih_azim_t *)
  val sph_triangle_ineq : thm (*  sph_triangle_ineq_t *)
  val sph_triangle_ineq_sum : thm (*  sph_triangle_ineq_sum_t *)
(* [deprecated]
  val aff_insert_sym : thm (*  aff_insert_sym_t *)  
  val aff_sgn_insert_sym_gt : thm (*  aff_sgn_insert_sym_gt_t *)
  val aff_sgn_insert_sym_ge : thm (*  aff_sgn_insert_sym_ge_t *)
  val aff_sgn_insert_sym_lt : thm (*  aff_sgn_insert_sym_lt_t *)
  val aff_sgn_insert_sym_le : thm (*  aff_sgn_insert_sym_le_t *)
*)
  val azim_hyp : thm (*  azim_hyp_t *)
  val azim_cycle_hyp : thm (*  azim_cycle_hyp_t *)
(* [deprecated]
  val aff : thm (* aff_t *)
  val aff_gt : thm (*  aff_gt_t   *)
  val aff_ge : thm (*  aff_ge_t   *)
  val aff_lt : thm (*  aff_lt_t   *)
  val aff_le : thm (*  aff_le_t   *)
*)
  val azim : thm (*  azim_t   *)
  val azim_cycle : thm (*  azim_cycle_t   *)
end;;

(* Here is a single axiom that permits a quick implementation of the
   module with the given signature.
   The axiom can be used so that the proofs in different chapters can
   proceed independently.  *)

let trig_axiom_list = new_definition (mk_eq (`trig_axiom:bool`, (list_mk_conj
   [
  atn2_spec_t  ;
  acs_atn2_t ;
  arcVarc_t ;
  law_of_cosines_t ;
  law_of_sines_t ;
  cross_mag_t ;
  cross_skew_t ;
  cross_triple_t ;
  spherical_loc_t ;
  spherical_loc2_t ;
  dih_formula_t ;
  dih_x_acs_t ;
  beta_cone_t ;
  euler_triangle_t ;
  polar_coords_t ;
  polar_cycle_rotate_t ;
  thetaij_t ;
  thetapq_wind_t ;
  zenith_t ;
  spherical_coord_t ;
  polar_coord_zenith_t ;
  azim_pair_t ;
  azim_cycle_sum_t ;
  dih_azim_t ;
  sph_triangle_ineq_t ;
  sph_triangle_ineq_sum_t ;
(* [deprecated]
  aff_insert_sym_t ;
  aff_sgn_insert_sym_gt_t ;
  aff_sgn_insert_sym_ge_t ;
  aff_sgn_insert_sym_lt_t ;
  aff_sgn_insert_sym_le_t ;
*)
  azim_hyp_t ;
  azim_cycle_hyp_t ;
(* [deprecated]
  aff_t;
  aff_gt_t;
  aff_ge_t;
  aff_lt_t;
  aff_le_t;
*)
  azim_t;
  azim_cycle_t;
   ])));;

	   


let trig_axiom = new_axiom `trig_axiom`;; 



  let trigAxiomProofA a_t = prove(a_t,
      (MP_TAC trig_axiom) THEN (REWRITE_TAC[trig_axiom_list]) THEN 
      (DISCH_THEN (fun t-> ASM_REWRITE_TAC[t]))
      )
  let trigAxiomProofB a_t = prove(a_t,
      (MP_TAC trig_axiom) THEN (REWRITE_TAC[trig_axiom_list]) THEN 
      (REPEAT STRIP_TAC)
      )
  
  (* ---------------------------------------------------------------------- *)
  (* These are theorems proved in HOL Light, but not in the                 *)
        (* Multivariate files.  Unless noted, all proofs by John Harrison.        *)
  (* ---------------------------------------------------------------------- *)
        
        (* REAL_LE_POW_2 is in HOL-Light Examples/transc.ml.  *)
        (* Also called REAL_LE_SQUARE_POW in Examples/analysis.ml. *)


  let REAL_LE_POW_2 = prove
   (`!x. &0 <= x pow 2`,
    REWRITE_TAC[REAL_POW_2; REAL_LE_SQUARE]);;

  (* REAL_DIV_MUL2 is in HOL-Light Examples/analysis.ml.  *)
  (* Proof in now trivial *)
        
        let REAL_DIV_MUL2 = REAL_FIELD
    `!x z. ~(x = &0) /\ ~(z = &0) ==> !y. y / z = (x * y) / (x * z)`;;
        
  (* ---------------------------------------------------------------------- *)
  (* Useful theorems about real numbers.                                    *)
  (* ---------------------------------------------------------------------- *)
  
  let REAL_LT_MUL_3 = prove
   (`!x y z. &0 < x /\ &0 < y /\ &0 < z ==> &0 < x * y * z`,
    REPEAT STRIP_TAC THEN MATCH_MP_TAC REAL_LT_MUL THEN ASM_REWRITE_TAC [] THEN
    MATCH_MP_TAC REAL_LT_MUL THEN ASM_REWRITE_TAC []);;

  let SQRT_MUL_L = prove
   (`!x y. &0 <= x /\ &0 <= y ==> x * sqrt y = sqrt(x pow 2 * y)`,
    REPEAT STRIP_TAC THEN ASM_SIMP_TAC [REAL_LE_POW_2; SQRT_MUL; POW_2_SQRT]);;

  let SQRT_MUL_R = prove
   (`!x y. &0 <= x /\ &0 <= y ==> sqrt x * y = sqrt(x * y pow 2)`,
    REPEAT STRIP_TAC THEN ASM_SIMP_TAC [REAL_LE_POW_2; SQRT_MUL; POW_2_SQRT]);;
  
  (* ---------------------------------------------------------------------- *)
  (* Basic trig results not included in Examples/transc.ml                  *)
  (* ---------------------------------------------------------------------- *)

  (* Next two proofs similar to TAN_PERIODIC_NPI in *)
  (* Examples/transc.ml by John Harrison *)
  (* They are no longer needed, but may be useful later. *)
        
  let SIN_PERIODIC_N2PI = prove
   (`!x n. sin(x + &n * (&2 * pi)) = sin(x)`,
    GEN_TAC THEN INDUCT_TAC THEN REWRITE_TAC[REAL_MUL_LZERO; REAL_ADD_RID] THEN
    REWRITE_TAC[GSYM REAL_OF_NUM_SUC; REAL_ADD_RDISTRIB; REAL_MUL_LID] THEN
    ASM_REWRITE_TAC[REAL_ADD_ASSOC; SIN_PERIODIC]);;
  
  let COS_PERIODIC_N2PI = prove
   (`!x n. cos(x + &n * (&2 * pi)) = cos(x)`,
    GEN_TAC THEN INDUCT_TAC THEN REWRITE_TAC[REAL_MUL_LZERO; REAL_ADD_RID] THEN
    REWRITE_TAC[GSYM REAL_OF_NUM_SUC; REAL_ADD_RDISTRIB; REAL_MUL_LID] THEN
    ASM_REWRITE_TAC[REAL_ADD_ASSOC; COS_PERIODIC]);;

  let CIRCLE_SINCOS_PI = prove
   (`!x y. (x pow 2 + y pow 2 = &1) ==> 
       ?t. (--pi < t /\ t <= pi) /\ ((x = cos(t)) /\ (y = sin(t)))`,
                ASM_MESON_TAC [CIRCLE_SINCOS; SINCOS_PRINCIPAL_VALUE]);;

  let SIN_NEGPOS_PI = prove 
   (`!x. (--pi < x /\ x <= pi) ==>
         (sin x < &0 <=> --pi < x /\ x < &0) /\
         (sin x = &0 <=> (x = &0 \/ x = pi)) /\
         (&0 < sin x <=> &0 < x /\ x < pi)`,
    STRIP_TAC THEN STRIP_TAC THEN SUBGOAL_THEN
      `if (sin x < &0) then (sin x < &0 <=> --pi < x /\ x < &0) else
       if (sin x = &0) then (sin x = &0 <=> (x = &0 \/ x = pi)) else
       (&0 < sin x <=> &0 < x /\ x < pi)` MP_TAC THENL
    [ SUBGOAL_TAC "a" `--pi < x /\ x < &0 ==> sin x < &0`
      [ MP_TAC (REWRITE_RULE [SIN_NEG] (SPEC `--x:real` SIN_POS_PI)) THEN
        REAL_ARITH_TAC ] THEN
      SUBGOAL_TAC "b" `x = &0 ==> sin x = &0`
      [ STRIP_TAC THEN ASM_REWRITE_TAC [SIN_0] ] THEN
      SUBGOAL_TAC "c" `x = pi ==> sin x = &0`
      [ STRIP_TAC THEN ASM_REWRITE_TAC [SIN_PI] ] THEN
      LABEL_TAC "d" (SPEC `x:real` SIN_POS_PI) THEN
      REPEAT (POP_ASSUM MP_TAC) THEN REAL_ARITH_TAC;
      REPEAT (POP_ASSUM MP_TAC) THEN REAL_ARITH_TAC ]);;

  let COS_NEGPOS_PI = prove
   (`!x. (--pi < x /\ x <= pi) ==>
         (cos x < &0 <=> (--pi < x /\ x < --(pi / &2)) \/ 
                         (pi / &2 < x /\ x <= pi)) /\
         (cos x = &0 <=> (x = --(pi / &2) \/ x = pi / &2)) /\
         (&0 < cos x <=> --(pi / &2) < x /\ x < pi / &2)`,
    STRIP_TAC THEN STRIP_TAC THEN SUBGOAL_THEN
      `if (cos x < &0) then (cos x < &0 <=> (--pi < x /\ x < --(pi / &2)) \/ 
                            (pi / &2 < x /\ x <= pi)) else
       if (cos x = &0) then 
       (cos x = &0 <=> (x = --(pi / &2) \/ x = pi / &2)) else
       (&0 < cos x <=> --(pi / &2) < x /\ x < pi / &2)` MP_TAC THENL
    [ SUBGOAL_TAC "a" `--pi < x /\ x < --(pi / &2) ==> cos x < &0`
      [ MP_TAC (REWRITE_RULE [COS_PERIODIC_PI] 
               (SPEC `x + pi:real` COS_POS_PI2)) THEN
        REAL_ARITH_TAC ] THEN
      SUBGOAL_TAC "b" `pi / &2 < x /\ x <= pi ==> cos x < &0`
      [ MP_TAC (REWRITE_RULE [SIN_NEG; GSYM COS_SIN] 
               (SPEC `--(pi / &2 - x)` SIN_POS_PI2)) THEN
        SUBGOAL_TAC "b1" `x = pi ==> cos x < &0` 
        [ STRIP_TAC THEN ASM_REWRITE_TAC [COS_PI; REAL_ARITH `&0 < &1`] THEN
          REAL_ARITH_TAC ] THEN
        POP_ASSUM MP_TAC THEN REAL_ARITH_TAC ] THEN
      SUBGOAL_TAC "c" `x = --(pi / &2) ==> cos x = &0`
      [ STRIP_TAC THEN ASM_REWRITE_TAC [COS_NEG; COS_PI2] ] THEN
      SUBGOAL_TAC "d" `x = pi / &2 ==> cos x = &0`
      [ STRIP_TAC THEN ASM_REWRITE_TAC [COS_PI2] ] THEN
      LABEL_TAC "e" (SPEC `x:real` COS_POS_PI) THEN
      REPEAT (POP_ASSUM MP_TAC) THEN REAL_ARITH_TAC;
      REPEAT (POP_ASSUM MP_TAC) THEN REAL_ARITH_TAC ]);;

  
  (* ----------------------------------------------------------------------- *)
  (* Theory of atan_2 function. See sphere.hl for the definiton. *)
  (* ----------------------------------------------------------------------- *)
  
  (* lemma:atn2_spec *)
   
  let dist_lemma = prove
   (`!x y. ~(x = &0) \/ ~(y = &0) ==> 
      (x / sqrt(x pow 2 + y pow 2)) pow 2 +
      (y / sqrt(x pow 2 + y pow 2)) pow 2 = &1 /\
      &0 < sqrt(x pow 2 + y pow 2)`,
    STRIP_TAC THEN STRIP_TAC THEN STRIP_TAC THEN
    SUBGOAL_TAC "sum_pos" `&0 < x pow 2 + y pow 2 /\ &0 <= x pow 2 + y pow 2`
    [ MP_TAC (SPEC `x:real` REAL_LE_POW_2) THEN 
      MP_TAC (SPEC `y:real` REAL_LE_POW_2) THEN
      IMP_RES_THEN MP_TAC (SPECL [`x:real`; `2`] REAL_POW_NZ) THEN 
      IMP_RES_THEN MP_TAC (SPECL [`y:real`; `2`] REAL_POW_NZ) THEN 
      REAL_ARITH_TAC ] THEN
    POP_ASSUM MP_TAC THEN STRIP_TAC THEN 
    ASM_SIMP_TAC [REAL_POW_DIV; SQRT_POW_2; SQRT_POS_LT] THEN
    POP_ASSUM MP_TAC THEN POP_ASSUM MP_TAC THEN
    CONV_TAC REAL_FIELD);;
  
  let ATAN2_EXISTS = prove 
   (`!x y. ?t. (--pi < t /\ t <= pi) /\
         x = sqrt(x pow 2 + y pow 2) * cos t /\
         y = sqrt(x pow 2 + y pow 2) * sin t`,
    REPEAT STRIP_TAC THEN ASM_CASES_TAC `(x = &0) /\ (y = &0)` THENL
    [ ASM_REWRITE_TAC [(SPEC `2` REAL_POW_ZERO)] THEN 
      NUM_REDUCE_TAC THEN CONV_TAC REAL_RAT_REDUCE_CONV THEN 
      REWRITE_TAC [SQRT_0] THEN EXISTS_TAC `pi` THEN MP_TAC PI_POS THEN
      REAL_ARITH_TAC ;
      IMP_RES_THEN STRIP_ASSUME_TAC 
      (REWRITE_RULE [TAUT `(~A \/ ~B) <=> ~(A /\ B)`] dist_lemma) THEN
      IMP_RES_THEN STRIP_ASSUME_TAC CIRCLE_SINCOS_PI THEN 
      POP_ASSUM (MP_TAC o GSYM) THEN POP_ASSUM (MP_TAC o GSYM) THEN
      STRIP_TAC THEN STRIP_TAC THEN EXISTS_TAC `t:real` THEN 
      ASM_REWRITE_TAC [] THEN
      POP_ASSUM (K ALL_TAC) THEN POP_ASSUM (K ALL_TAC) THEN 
      POP_ASSUM (K ALL_TAC) THEN POP_ASSUM (K ALL_TAC) THEN
      POP_ASSUM MP_TAC THEN CONV_TAC REAL_FIELD ]);;
  
  (* The official Kepler definition (atn2) is different, but it was easier  *)
  (* to start with this one and prove it is equivalent.                      *)
  
  let ATAN2_TEMP_DEF = new_definition
    `atan2_temp (x,y) = if (x = &0 /\ y = &0) 
                        then pi 
                        else @t. (--pi < t /\ t <= pi) /\
                                 x = sqrt(x pow 2 + y pow 2) * cos t /\
                                 y = sqrt(x pow 2 + y pow 2) * sin t`;;
                     
  let ATAN2_TEMP = prove
   (`!x y. (--pi < atan2_temp (x,y) /\ atan2_temp (x,y) <= pi) /\
           x = sqrt(x pow 2 + y pow 2) * cos (atan2_temp (x,y)) /\
           y = sqrt(x pow 2 + y pow 2) * sin (atan2_temp (x,y))`,
    STRIP_TAC THEN STRIP_TAC THEN REWRITE_TAC [ATAN2_TEMP_DEF] THEN
    COND_CASES_TAC THENL
    [ ASM_REWRITE_TAC [(SPEC `2` REAL_POW_ZERO)] THEN 
      NUM_REDUCE_TAC THEN CONV_TAC REAL_RAT_REDUCE_CONV THEN 
      REWRITE_TAC [SQRT_0] THEN MP_TAC PI_POS THEN
      REAL_ARITH_TAC ; 
      REWRITE_TAC [(SELECT_RULE (SPECL [`x:real`;`y:real`] ATAN2_EXISTS))]]);;

  let ATAN2_TEMP_SPEC = prove
   (`!x y. ?r. ((-- pi < atan2_temp(x, y)) /\ (atan2_temp(x,y) <= pi) /\
       (x = r* (cos(atan2_temp(x,y)))) /\ (y = r* (sin (atan2_temp( x, y)))) /\ 
       (&0 <= r))`,
    STRIP_TAC THEN STRIP_TAC THEN EXISTS_TAC `sqrt(x pow 2 + y pow 2)` THEN
    REWRITE_TAC [ATAN2_TEMP] THEN SUBGOAL_TAC "sum_pos" `&0 <= x pow 2 + y pow 2`
    [ MP_TAC (SPEC `x:real` REAL_LE_POW_2) THEN 
      MP_TAC (SPEC `y:real` REAL_LE_POW_2) THEN
      IMP_RES_THEN MP_TAC (SPECL [`x:real`; `2`] REAL_POW_NZ) THEN 
      IMP_RES_THEN MP_TAC (SPECL [`y:real`; `2`] REAL_POW_NZ) THEN 
      REAL_ARITH_TAC ] THEN
    MP_TAC (SPEC `x pow 2 + y pow 2` SQRT_POS_LE) THEN POP_ASSUM MP_TAC THEN
    REAL_ARITH_TAC);;
      
  let ATAN2_TEMP_BREAKDOWN = prove
   (`!x y. (&0 < x ==> atan2_temp(x,y) = atn(y / x)) /\
           (&0 < y ==> atan2_temp(x,y) = pi / &2 - atn(x / y)) /\
           (y < &0 ==> atan2_temp(x,y) = --(pi / &2) - atn(x / y)) /\
           (y = &0 /\ x <= &0 ==> atan2_temp(x,y) = pi)`,
    REPEAT GEN_TAC THEN REPEAT CONJ_TAC THENL
    [ STRIP_ASSUME_TAC (SPECL [`x:real`;`y:real`] ATAN2_TEMP) THEN
      ABBREV_TAC `t = atan2_temp (x,y)` THEN 
      ABBREV_TAC `r = sqrt (x pow 2 + y pow 2)` THEN STRIP_TAC THEN
      SUBGOAL_TAC "r_pos" `&0 < r` 
      [ EXPAND_TAC "r" THEN MP_TAC (SPECL [`x:real`;`y:real`] dist_lemma) THEN
        POP_ASSUM MP_TAC THEN REAL_ARITH_TAC] THEN
      SUBGOAL_TAC "tan" `(r * sin t) / (r * cos t) = tan t`
      [ REWRITE_TAC [tan] THEN POP_ASSUM MP_TAC THEN CONV_TAC REAL_FIELD ] THEN
      ASM_REWRITE_TAC [] THEN MATCH_MP_TAC (GSYM TAN_ATN) THEN 
      POP_ASSUM (K ALL_TAC) THEN 
      POP_ASSUM (fun th -> POP_ASSUM MP_TAC THEN ASSUME_TAC th) THEN
      ASM_SIMP_TAC [GSYM COS_NEGPOS_PI; REAL_LT_MUL_EQ] THEN REAL_ARITH_TAC ;
  
	   

      ABBREV_TAC `t = atan2_temp (x,y)` THEN 
      ABBREV_TAC `r = sqrt (x pow 2 + y pow 2)` THEN STRIP_TAC THEN
      SUBGOAL_TAC "r_pos" `&0 < r` 
      [ EXPAND_TAC "r" THEN MP_TAC (SPECL [`x:real`;`y:real`] dist_lemma) THEN
        POP_ASSUM MP_TAC THEN REAL_ARITH_TAC] THEN
      SUBGOAL_TAC "tan" `(r * cos t) / (r * sin t) = inv (tan t)`
      [ REWRITE_TAC [tan] THEN POP_ASSUM MP_TAC THEN 
        CONV_TAC REAL_FIELD ] THEN
      ASM_REWRITE_TAC [GSYM TAN_COT] THEN
      SUBGOAL_THEN `pi / &2 - t = atn (tan (pi / &2 - t))` 
                   (fun th -> REWRITE_TAC [GSYM th] THEN REAL_ARITH_TAC) THEN
      MATCH_MP_TAC (GSYM TAN_ATN) THEN 
      SUBGOAL_THEN `&0 < t /\ t < pi` 
                   (fun th -> MP_TAC th THEN REAL_ARITH_TAC) THEN
      POP_ASSUM (K ALL_TAC) THEN 
      POP_ASSUM (fun th -> POP_ASSUM MP_TAC THEN ASSUME_TAC th) THEN
      ASM_SIMP_TAC [GSYM SIN_NEGPOS_PI; REAL_LT_MUL_EQ] THEN REAL_ARITH_TAC ;
    
      STRIP_ASSUME_TAC (SPECL [`x:real`;`y:real`] ATAN2_TEMP) THEN
      ABBREV_TAC `t = atan2_temp (x,y)` THEN 
      ABBREV_TAC `r = sqrt (x pow 2 + y pow 2)` THEN STRIP_TAC THEN
      SUBGOAL_TAC "r_pos" `&0 < r` 
      [ EXPAND_TAC "r" THEN MP_TAC (SPECL [`x:real`;`y:real`] dist_lemma) THEN
        POP_ASSUM MP_TAC THEN REAL_ARITH_TAC] THEN
      SUBGOAL_TAC "tan" `(r * cos t) / (r * sin t) = --inv (tan (--t))`
      [ REWRITE_TAC [TAN_NEG; REAL_INV_NEG] THEN 
        REWRITE_TAC [tan; REAL_NEG_NEG] THEN 
        POP_ASSUM MP_TAC THEN CONV_TAC REAL_FIELD ] THEN
      ASM_REWRITE_TAC [GSYM TAN_COT; ATN_NEG] THEN
      SUBGOAL_THEN `pi / &2 + t = atn (tan (pi / &2 + t))` 
        (fun th -> REWRITE_TAC [REAL_ARITH `pi / &2 - --t = pi / &2 + t`;GSYM th] 
                   THEN REAL_ARITH_TAC) THEN
      MATCH_MP_TAC (GSYM TAN_ATN) THEN 
      SUBGOAL_THEN `--pi < t /\ t < &0` 
                   (fun th -> MP_TAC th THEN REAL_ARITH_TAC) THEN
      POP_ASSUM (K ALL_TAC) THEN
      POP_ASSUM (fun th -> POP_ASSUM (MP_TAC o (REWRITE_RULE [GSYM REAL_NEG_GT0]))
                           THEN ASSUME_TAC th) THEN
      ASM_SIMP_TAC [GSYM SIN_NEGPOS_PI; REAL_LT_MUL_EQ; REAL_NEG_RMUL] THEN 
      REAL_ARITH_TAC ;
    
      ASM_CASES_TAC `x = &0` THENL
    [ STRIP_TAC THEN ASM_REWRITE_TAC [ATAN2_TEMP_DEF];
      ALL_TAC] THEN
    STRIP_ASSUME_TAC (SPECL [`x:real`;`y:real`] ATAN2_TEMP) THEN
    ABBREV_TAC `t = atan2_temp (x,y)` THEN 
    ABBREV_TAC `r = sqrt (x pow 2 + y pow 2)` THEN STRIP_TAC THEN
    SUBGOAL_TAC "r_pos" `&0 < r` 
    [ EXPAND_TAC "r" THEN MP_TAC (SPECL [`x:real`;`y:real`] dist_lemma) THEN
      POP_ASSUM MP_TAC THEN FIND_ASSUM MP_TAC `~(x = &0)` THEN 
      REAL_ARITH_TAC ] THEN
    SUBGOAL_TAC "sin_cos" `sin t = &0 /\ cos t < &0 ==> t = pi`
    [ ASM_SIMP_TAC [SIN_NEGPOS_PI; COS_NEGPOS_PI] THEN MP_TAC PI_POS THEN
      REAL_ARITH_TAC ] THEN
    POP_ASSUM MATCH_MP_TAC THEN 
    SUBGOAL_TAC "x_pos" `&0 < --x` 
    [ FIND_ASSUM MP_TAC `x <= &0` THEN FIND_ASSUM MP_TAC `~(x = &0)` THEN
      REAL_ARITH_TAC ] THEN
    POP_ASSUM MP_TAC THEN   
    POP_ASSUM (fun th -> POP_ASSUM (K ALL_TAC) THEN POP_ASSUM MP_TAC THEN 
                         ASSUME_TAC th) THEN
    ASM_SIMP_TAC [REAL_LT_MUL_EQ; REAL_NEG_RMUL] THEN POP_ASSUM MP_TAC THEN
    CONV_TAC REAL_FIELD]);;
    
  let ATAN2_TEMP_ALT = prove
   (`!x y. atan2_temp (x,y) = 
     if ( abs y < x ) then atn(y / x) else
     (if (&0 < y) then ((pi / &2) - atn(x / y)) else
     (if (y < &0) then (-- (pi/ &2) - atn (x / y)) else (  pi )))`,
    STRIP_TAC THEN STRIP_TAC THEN COND_CASES_TAC THENL 
    [ SUBGOAL_THEN `&0 < x` 
                  (fun th -> SIMP_TAC [th; ATAN2_TEMP_BREAKDOWN]) THEN
      POP_ASSUM MP_TAC THEN REAL_ARITH_TAC;
      COND_CASES_TAC THENL
      [ SUBGOAL_THEN `&0 < y` 
                     (fun th -> SIMP_TAC [th; ATAN2_TEMP_BREAKDOWN]) THEN
        POP_ASSUM MP_TAC THEN REAL_ARITH_TAC;
        COND_CASES_TAC THENL
        [ SUBGOAL_THEN `y < &0` 
                      (fun th -> SIMP_TAC [th; ATAN2_TEMP_BREAKDOWN]) THEN
          POP_ASSUM MP_TAC THEN REAL_ARITH_TAC;
          SUBGOAL_THEN `y = &0` 
            (fun th -> POP_ASSUM (K ALL_TAC) THEN POP_ASSUM (K ALL_TAC) THEN
                       ASSUME_TAC th) THENL
          [ POP_ASSUM MP_TAC THEN POP_ASSUM MP_TAC THEN REAL_ARITH_TAC ;
            SUBGOAL_THEN `x <= &0` 
                        (fun th -> ASM_SIMP_TAC [th; ATAN2_TEMP_BREAKDOWN]) THEN
            POP_ASSUM MP_TAC THEN POP_ASSUM MP_TAC THEN REAL_ARITH_TAC ]]]]);;  
  
  (* Show that the working def and the official def are equivalent. *)
  
  let ATAN_TEMP_ATN2 = prove
   (`atn2 = atan2_temp`,
    REWRITE_TAC [FORALL_PAIR_THM; FUN_EQ_THM; atn2; ATAN2_TEMP_ALT]);;

  (* These three and the definition should suffice as the basic *)
  (* specifications for atn2. No more need for atan2_temp.*)
  
  let atn2_spec = prove
   (atn2_spec_t,
    REWRITE_TAC [ATAN_TEMP_ATN2; ATAN2_TEMP_SPEC]);; 
  
  let ATN2_BREAKDOWN = prove
   (`!x y. (&0 < x ==> atn2 (x,y) = atn(y / x)) /\
           (&0 < y ==> atn2 (x,y) = pi / &2 - atn(x / y)) /\
           (y < &0 ==> atn2 (x,y) = --(pi / &2) - atn(x / y)) /\
           (y = &0 /\ x <= &0 ==> atn2(x,y) = pi)`,
    REWRITE_TAC [ATAN_TEMP_ATN2; ATAN2_TEMP_BREAKDOWN]);;
    
  let ATN2_CIRCLE = prove
   (`!x y. (--pi < atan2_temp (x,y) /\ atan2_temp (x,y) <= pi) /\
           x = sqrt(x pow 2 + y pow 2) * cos (atan2_temp (x,y)) /\
           y = sqrt(x pow 2 + y pow 2) * sin (atan2_temp (x,y))`,
    REWRITE_TAC [ATAN_TEMP_ATN2; ATAN2_TEMP]);;

  (* Useful properties of atn2. *)
  
  let ATN2_0_1 = prove
   (`atn2 (&0, &1) = pi / &2`,
    ASSUME_TAC (REAL_ARITH `&0 < &1`) THEN 
    ASM_SIMP_TAC [ATN2_BREAKDOWN] THEN CONV_TAC REAL_RAT_REDUCE_CONV THEN
    REWRITE_TAC [ATN_0] THEN REAL_ARITH_TAC);;
    
  let ATN2_0_NEG_1 = prove
   (`atn2 (&0, --(&1)) = --(pi / &2)`,
    ASSUME_TAC (REAL_ARITH `--(&1) < &0`) THEN 
    ASM_SIMP_TAC [ATN2_BREAKDOWN] THEN CONV_TAC REAL_RAT_REDUCE_CONV THEN
    REWRITE_TAC [ATN_0] THEN REAL_ARITH_TAC);;
                          
  let ATN2_LMUL_EQ = prove
   (`!a x y. &0 < a ==> atn2(a * x, a * y) = atn2 (x, y)`,
    REPEAT STRIP_TAC THEN STRIP_ASSUME_TAC 
      (REAL_ARITH `&0 < x \/ &0 < y \/ y < &0 \/ (y = &0 /\ x <= &0)`) THENL
    [ SUBGOAL_TAC "pos_x" `&0 < a * x` 
      [ let th = SPECL [`&0`;`x:real`;`a:real`] REAL_LT_LMUL_EQ in
        let th2 = REWRITE_RULE [REAL_MUL_RZERO] th in
        ASM_SIMP_TAC [th2] ] ;
      SUBGOAL_TAC "pos_y" `&0 < a * y` 
      [ let th = SPECL [`&0`;`y:real`;`a:real`] REAL_LT_LMUL_EQ in
        let th2 = REWRITE_RULE [REAL_MUL_RZERO] th in
        ASM_SIMP_TAC [th2] ] ;
       SUBGOAL_TAC "neg_y" `a * y < &0` 
      [ let th = SPECL [`y:real`;`&0`;`a:real`] REAL_LT_LMUL_EQ in
        let th2 = REWRITE_RULE [REAL_MUL_RZERO] th in
        ASM_SIMP_TAC [th2] ] ;
      SUBGOAL_TAC "other" `a * y = &0 /\ a * x <= &0`
      [ ASM_REWRITE_TAC [REAL_MUL_RZERO] THEN
        let th = SPECL [`x:real`;`&0`;`a:real`] REAL_LE_LMUL_EQ in
        let th2 = REWRITE_RULE [REAL_MUL_RZERO] th in
        ASM_SIMP_TAC [th2] ] ] THEN
    let th1 = SPECL [`x:real`;`y:real`] ATN2_BREAKDOWN in
    let th2 = SPECL [`a * x:real`;`a * y:real`] ATN2_BREAKDOWN in
    let th3 = REAL_ARITH `!x. (x < &0 \/ &0 < x) ==> ~(&0 = x)` in
    ASM_SIMP_TAC [th1; th2; th3; GSYM (SPEC `a:real` REAL_DIV_MUL2)] );;        
  
  let ATN2_RNEG = prove
   (`!x y. (~(y = &0) \/ &0 < x) ==> atn2(x,--y) = --(atn2(x,y))`,
    STRIP_TAC THEN STRIP_TAC THEN STRIP_ASSUME_TAC 
      (REAL_ARITH `&0 < x \/ &0 < y \/ y < &0 \/ (y = &0 /\ x <= &0)`) THENL
    [ ASM_REWRITE_TAC [] ;
      ASM_SIMP_TAC [REAL_LT_IMP_NE] THEN SUBGOAL_TAC "neg" `--y < &0`
       [ ASM_REWRITE_TAC [REAL_NEG_LT0] ] ;
      ASM_SIMP_TAC [REAL_LT_IMP_NE] THEN SUBGOAL_TAC "pos" `&0 < --y`
       [ ASM_REWRITE_TAC [REAL_NEG_GT0] ] ;
      ASM_REWRITE_TAC [real_lt] ] THEN
    let th1 = SPECL [`x:real`;`y:real`] ATN2_BREAKDOWN in
    let th2 = SPECL [`x:real`;`--y:real`] ATN2_BREAKDOWN in
    let th3 = REAL_ARITH `(--x)/y = --(x/y)` in
    let th4 = REAL_FIELD `(y < &0 \/ &0 < y) ==>  x / (--y) = --(x/y)` in
    ASM_SIMP_TAC [th1; th2; th3; th4; ATN_NEG] THEN REAL_ARITH_TAC);;

  (* lemma:acs_atn2 *)   
  
  let acs_atn2 = prove
   (acs_atn2_t,
    STRIP_TAC THEN ASM_CASES_TAC `y = &1 \/ y = --(&1)` THENL
    [ POP_ASSUM DISJ_CASES_TAC THENL
      [ ASM_REWRITE_TAC [] THEN CONV_TAC REAL_RAT_REDUCE_CONV THEN 
        REWRITE_TAC [ACS_1; SQRT_0; ATN2_0_1] THEN REAL_ARITH_TAC ;
        ASM_REWRITE_TAC [] THEN CONV_TAC REAL_RAT_REDUCE_CONV THEN 
        REWRITE_TAC [ACS_NEG_1; SQRT_0; ATN2_0_NEG_1] THEN REAL_ARITH_TAC ] ;
      STRIP_TAC THEN 
      SUBGOAL_TAC "sqrt" `&0 < sqrt (&1 - y pow 2)`
      [ MATCH_MP_TAC SQRT_POS_LT THEN
        SUBGOAL_THEN `&0 <= y pow 2 /\ y pow 2 < &1`
                     (fun th -> MP_TAC th THEN REAL_ARITH_TAC) THEN
        REWRITE_TAC [REAL_LE_POW_2; REAL_ARITH `a < &1 <=> a < &1 pow 2`;
                     GSYM REAL_LT_SQUARE_ABS ] THEN 
        REPEAT (POP_ASSUM MP_TAC) THEN REAL_ARITH_TAC ] THEN
       ASM_SIMP_TAC [ATN2_BREAKDOWN] THEN MATCH_MP_TAC ACS_ATN THEN
       REPEAT (POP_ASSUM MP_TAC) THEN REAL_ARITH_TAC ]);;
  
  (* ----------------------------------------------------------------------- *)
  (* Theory of triangles (without vectors). Includes laws of cosines/sines.  *)
  (* ----------------------------------------------------------------------- *)
  
  let UPS_X_SQUARES = prove
   (`!a b c. ups_x (a * a) (b * b) (c * c) =
           &16 * ((a + b + c) / &2) * 
           (((a + b + c) / &2) - a) * 
           (((a + b + c) / &2) - b) * 
           (((a + b + c) / &2) - c)`,
    REPEAT STRIP_TAC THEN REWRITE_TAC [ups_x] THEN REAL_ARITH_TAC);;
  
	   


  let TRI_UPS_X_POS = prove
   (`!a b c. (&0 < a) /\ (&0 < b) /\ (&0 <= c) /\ (c <= a + b) /\ (a <= b + c) /\ (b <= c + a) ==>
     &0 <= ups_x (a * a) (b * b) (c * c)`,
    REPEAT STRIP_TAC THEN REWRITE_TAC [UPS_X_SQUARES] THEN
    REPEAT (MATCH_MP_TAC REAL_LE_MUL THEN STRIP_TAC) THENL
    [ REAL_ARITH_TAC ;
      REPEAT (POP_ASSUM MP_TAC) THEN REAL_ARITH_TAC ;
      SUBGOAL_THEN `&2 * a <= a + b + c` 
                   (fun th -> MP_TAC th THEN REAL_ARITH_TAC) THEN
      REPEAT (POP_ASSUM MP_TAC) THEN REAL_ARITH_TAC ;
      SUBGOAL_THEN `&2 * b <= a + b + c` 
                   (fun th -> MP_TAC th THEN REAL_ARITH_TAC) THEN
      REPEAT (POP_ASSUM MP_TAC) THEN REAL_ARITH_TAC ;
      SUBGOAL_THEN `&2 * c <= a + b + c` 
                   (fun th -> MP_TAC th THEN REAL_ARITH_TAC) THEN
      REPEAT (POP_ASSUM MP_TAC) THEN REAL_ARITH_TAC ]);;
  
  let TRI_SQUARES_BOUNDS = prove
   (`!a b c. (&0 < a) /\ (&0 < b) /\ (&0 <= c) /\ (c <= a + b) /\ (a <= b + c) /\ (b <= c + a) ==>
     --(&1) <= ((a * a) + (b * b) - (c * c)) / (&2 * a * b) /\
     ((a * a) + (b * b) - (c * c)) / (&2 * a * b) <= &1`,
    REPEAT STRIP_TAC THEN 
    SUBGOAL_TAC "2ab_pos" `&0 < &2 * a * b` 
    [ ASM_SIMP_TAC [REAL_LT_MUL_3; REAL_ARITH `&0 < &2`] ] THENL
    [ SUBGOAL_TAC "abc_square" `c*c <= (a + b) * (a + b)`
      [ MATCH_MP_TAC (REWRITE_RULE [IMP_IMP] REAL_LE_MUL2) THEN 
        REPEAT (POP_ASSUM MP_TAC) THEN REAL_ARITH_TAC ] THEN
      ASM_SIMP_TAC [REAL_LE_RDIV_EQ] THEN REMOVE_THEN "abc_square" MP_TAC THEN
      REAL_ARITH_TAC ;
      SUBGOAL_TAC "abc_square" `(a - b) * (a - b) <= c*c`
      [ DISJ_CASES_TAC (REAL_ARITH `a <= b \/ b <= a`) THENL
        [ SUBST1_TAC (REAL_ARITH `(a-b)*(a-b)=(b-a)*(b-a)`); ALL_TAC ] THEN
        MATCH_MP_TAC (REWRITE_RULE [IMP_IMP] REAL_LE_MUL2) THEN 
        REPEAT (POP_ASSUM MP_TAC) THEN REAL_ARITH_TAC ] THEN
      ASM_SIMP_TAC [REAL_LE_LDIV_EQ] THEN REMOVE_THEN "abc_square" MP_TAC THEN
      REAL_ARITH_TAC ]);;

  let ATN2_ARCLENGTH = prove
   (`!a b c. (&0 < a) /\ (&0 < b) /\ (&0 <= c) /\ (c <= a + b) /\ (a <= b + c) /\ (b <= c + a) ==>
     arclength a b c = pi / &2 - atn2(sqrt(ups_x (a*a) (b*b) (c*c)), (a*a) + (b*b) - (c*c))`,
    REPEAT STRIP_TAC THEN 
    let th = REAL_ARITH `c * c - a * a - b * b = --(a * a + b * b - c * c)` in
    REWRITE_TAC [arclength; th; ATN2_RNEG] THEN
    SUBGOAL_THEN `~(a * a + b * b - c * c = &0) \/
                 &0 < sqrt(ups_x (a*a) (b*b) (c*c))` 
                (fun th -> ASM_SIMP_TAC [th; ATN2_RNEG] THEN 
                           REAL_ARITH_TAC) THEN
    REWRITE_TAC [TAUT `(~A \/ B) <=> (A ==> B)`] THEN STRIP_TAC THEN
    SUBGOAL_TAC "c_ab" `c*c = a*a + b*b` 
    [ POP_ASSUM MP_TAC THEN REAL_ARITH_TAC ] THEN 
    REMOVE_THEN "c_ab" (fun th -> REWRITE_TAC [ups_x; th]) THEN 
    MATCH_MP_TAC SQRT_POS_LT THEN 
    CONV_TAC (DEPTH_BINOP_CONV `(<)` REAL_POLY_CONV) THEN
    MATCH_MP_TAC REAL_LT_MUL_3 THEN STRIP_TAC THENL
    [ REAL_ARITH_TAC ;
      ASM_SIMP_TAC [REAL_POW_LT] ]);;

  let TRI_LEMMA = prove
   (`!a b c. (&0 < a) /\ (&0 < b) /\ (&0 <= c) /\ (c <= a + b) /\ (a <= b + c) /\ (b <= c + a) ==>
     (&2 * a * b) * (a * a + b * b - c * c) / (&2 * a * b) =
     a * a + b * b - c * c`,
    REPEAT STRIP_TAC THEN 
    SUBGOAL_TAC "2ab_pos" `&0 < &2 * a * b`
    [ ASM_SIMP_TAC [REAL_LT_MUL_3; REAL_ARITH `&0 < &2`] ] THEN
    SUBGOAL_TAC "2ab_not0" `~(&2 * a * b = &0)` 
    [ POP_ASSUM MP_TAC THEN REAL_ARITH_TAC ] THEN
    ASM_SIMP_TAC [REAL_DIV_LMUL]);;

  let TRI_UPS_X_SQUARES = prove
   (`!a b c. (&0 < a) /\ (&0 < b) /\ (&0 <= c) /\ (c <= a + b) /\ (a <= b + c) /\ (b <= c + a) ==>
     ups_x (a * a) (b * b) (c * c) =
     (&2 * a * b) pow 2 * (&1 - ((a * a + b * b - c * c) / (&2 * a * b)) pow 2)`,
    REPEAT STRIP_TAC THEN
    ASM_SIMP_TAC [ups_x; REAL_SUB_LDISTRIB; GSYM REAL_POW_MUL; TRI_LEMMA] THEN
    REAL_ARITH_TAC);;

  let TRI_UPS_X_SQRT = prove
   (`!a b c. (&0 < a) /\ (&0 < b) /\ (&0 <= c) /\ (c <= a + b) /\ (a <= b + c) /\ (b <= c + a) ==>
     sqrt(ups_x (a * a) (b * b) (c * c)) =
     (&2 * a * b) * sqrt(&1 - ((a * a + b * b - c * c) / (&2 * a * b)) pow 2)`,
    REPEAT STRIP_TAC THEN
    SUBGOAL_TAC "2ab_pos" `&0 < &2 * a * b`
    [ ASM_SIMP_TAC [REAL_LT_MUL_3; REAL_ARITH `&0 < &2`] ] THEN
    SUBGOAL_TAC "other_pos" `&0 <= &1 - ((a * a + b * b - c * c) / (&2 * a * b)) pow 2`
    [ SUBGOAL_THEN `((a * a + b * b - c * c) / (&2 * a * b)) pow 2 <= &1`
        (fun th -> MP_TAC th THEN REAL_ARITH_TAC) THEN
    ASM_SIMP_TAC [ABS_SQUARE_LE_1; REAL_ABS_BOUNDS; TRI_SQUARES_BOUNDS] ] THEN
    ASM_SIMP_TAC [SQRT_MUL_L; REAL_LT_IMP_LE; TRI_UPS_X_SQUARES] );;

  let ACS_ARCLENGTH = prove
   (`!a b c. (&0 < a) /\ (&0 < b) /\ (&0 <= c) /\ (c <= a + b) /\ (a <= b + c) /\ (b <= c + a) ==>
     arclength a b c = acs (((a * a) + (b * b) - (c * c)) / (&2 * a * b))`,
    REPEAT STRIP_TAC THEN ASM_SIMP_TAC [ATN2_ARCLENGTH; TRI_SQUARES_BOUNDS; acs_atn2] THEN
    SUBGOAL_TAC "2ab_pos" `&0 < &2 * a * b`
    [ ASM_SIMP_TAC [REAL_LT_MUL_3; REAL_ARITH `&0 < &2`] ] THEN
    SUBGOAL_THEN 
      `(sqrt (ups_x (a * a) (b * b) (c * c)), a * a + b * b - c * c) =
       ((&2 * a * b) * sqrt (&1 - ((a * a + b * b - c * c) / (&2 * a * b)) pow 2),
        (&2 * a * b) * ((a * a + b * b - c * c) / (&2 * a * b)))`
      (fun th -> ASM_SIMP_TAC [ATN2_LMUL_EQ; th]) THEN 
    ASM_SIMP_TAC [TRI_UPS_X_SQRT; TRI_LEMMA]);;

  let law_of_cosines = prove    
   (law_of_cosines_t,
    REPEAT STRIP_TAC THEN 
    REWRITE_TAC [REAL_ARITH `&2 * a * b * x = (&2 * a * b) * x`] THEN
    ASM_SIMP_TAC [ACS_ARCLENGTH; TRI_SQUARES_BOUNDS; COS_ACS; TRI_LEMMA] THEN 
    REAL_ARITH_TAC);;

  let law_of_sines =  prove
   (law_of_sines_t,
    REPEAT STRIP_TAC THEN
    REWRITE_TAC [REAL_ARITH `&2 * a * b * x = (&2 * a * b) * x`;
                 REAL_ARITH `x pow 2 = x * x` ] THEN
    ASM_SIMP_TAC [ACS_ARCLENGTH; TRI_SQUARES_BOUNDS; SIN_ACS; TRI_UPS_X_SQRT]);;

  (* ----------------------------------------------------------------------- *)
  (* Cross product properties.                                               *)
  (* ----------------------------------------------------------------------- *)

  let DIST_TRIANGLE_DETAILS = prove
         (`~(u = v) /\ ~(u = w) <=>
           &0 < dist(u,v) /\ &0 < dist(u,w) /\
     &0 <= dist(v,w) /\
     dist(v,w) <= dist(u,v) + dist(u,w) /\
     dist(u,v) <= dist(u,w) + dist(v,w) /\
     dist(u,w) <= dist(v,w) + dist(u,v)`,
                NORM_ARITH_TAC);;

  let arcVarc = prove
         (arcVarc_t,
          SIMP_TAC [DIST_TRIANGLE_DETAILS;  arcV; ACS_ARCLENGTH] THEN
                REPEAT STRIP_TAC THEN AP_TERM_TAC THEN 
                REWRITE_TAC [DOT_NORM_NEG; dist] THEN 
                let tha = NORM_ARITH `norm (v - u) = norm (u - v)` in
                let thb = NORM_ARITH `norm (w - u) = norm (u - w)` in
                let thc = NORM_ARITH `norm (v - u - (w - u)) = norm (v - w)` in
                REWRITE_TAC [tha; thb; thc] THEN CONV_TAC REAL_FIELD);;

  let DIST_LAW_OF_COS = prove
         (`(dist(v:real^3,w)) pow 2 = (dist(u,v)) pow 2 + (dist(u,w)) pow 2 - 
                                     &2 * (dist(u,v)) * (dist(u,w)) * cos (arcV u v w)`,
    ASM_CASES_TAC `~(u = v:real^3) /\ ~(u = w)` THEN POP_ASSUM MP_TAC THENL
                [ ASM_SIMP_TAC [arcVarc] THEN 
                  REWRITE_TAC [law_of_cosines; DIST_TRIANGLE_DETAILS];
                  REWRITE_TAC [TAUT `~(~A /\ ~B) <=> (A \/ B)`] THEN STRIP_TAC THEN 
                        ASM_REWRITE_TAC [DIST_REFL; DIST_SYM] THEN REAL_ARITH_TAC]);;

  let DIST_L_ZERO = prove
         (`!v. dist(vec 0, v) = norm v`,
    NORM_ARITH_TAC);;
        
  (* I would like to change this to real^N but that means changing arcV to real^N *)

  let DOT_COS = prove 
         (`u:real^3 dot v = (norm u) * (norm v) * cos (arcV (vec 0) u v)`,
    MP_TAC (INST [`vec 0:real^3`,`u:real^3`; 
                              `u:real^3`,`v:real^3`; 
                                                                  `v:real^3`,`w:real^3`] DIST_LAW_OF_COS) THEN  
                SUBGOAL_THEN 
                  `dist(u:real^3,v) pow 2 = 
                   dist(vec 0, v) pow 2 + dist(vec 0, u) pow 2 - &2 * u dot v` 
                        (fun th -> REWRITE_TAC [th; DIST_L_ZERO] THEN REAL_ARITH_TAC) THEN
                REWRITE_TAC [NORM_POW_2; dist; DOT_RSUB; DOT_LSUB; 
                             DOT_SYM; DOT_LZERO; DOT_RZERO] THEN
    REAL_ARITH_TAC);;

  (* DIMINDEX_3, FORALL_3, SUM_3, DOT_3, VECTOR_3, FORALL_VECTOR_3          *)
        (* are all very useful.  Any time you see a theorem you need with         *)
        (* 1 <= i /\ i <= dimindex(:3), first use INST_TYPE and then rewrite      *)
        (* with DIMINDEX_3 and FORALL_3 or see if it's in the list below.         *)
        
  let CART_EQ_3 = prove
   (`!x y. (x:A^3) = y <=> x$1 = y$1 /\ x$2 = y$2 /\ x$3 = y$3`,
          REWRITE_TAC [CART_EQ; DIMINDEX_3; FORALL_3]);;
        
        let LAMBDA_BETA_3 = prove
   (`((lambda) g:A^3) $1 = g 1 /\
           ((lambda) g:A^3) $2 = g 2 /\
                 ((lambda) g:A^3) $3 = g 3`,
    let th = REWRITE_RULE [DIMINDEX_3; FORALL_3] 
                                      (INST_TYPE [`:3`,`:B`] LAMBDA_BETA) in
                REWRITE_TAC [th]);;

  let VEC_COMPONENT_3 = prove
   (`!k. (vec k :real^3)$1 = &k /\ 
               (vec k :real^3)$2 = &k /\ 
                     (vec k :real^3)$3 = &k`,
    let th = REWRITE_RULE [DIMINDEX_3; FORALL_3] 
                                      (INST_TYPE [`:3`,`:N`] VEC_COMPONENT) in
                REWRITE_TAC [th]);;

  let VECTOR_ADD_COMPONENT_3 = prove
   (`!x:real^3 y. (x + y)$1 = x$1 + y$1 /\
                        (x + y)$2 = x$2 + y$2 /\
                                                                        (x + y)$3 = x$3 + y$3`,
                let th = REWRITE_RULE [DIMINDEX_3; FORALL_3] 
                                      (INST_TYPE [`:3`,`:N`] VECTOR_ADD_COMPONENT) in
                REWRITE_TAC [th]);;
  
	   

   (`!x:real^3 y. (x - y)$1 = x$1 - y$1 /\
                        (x - y)$2 = x$2 - y$2 /\
                                                                        (x - y)$3 = x$3 - y$3`,
                let th = REWRITE_RULE [DIMINDEX_3; FORALL_3] 
                                      (INST_TYPE [`:3`,`:N`] VECTOR_SUB_COMPONENT) in
                REWRITE_TAC [th]);;

  let VECTOR_NEG_COMPONENT_3 = prove
   (`!x:real^3. (--x)$1 = --(x$1) /\
                      (--x)$2 = --(x$2) /\
                                                                (--x)$3 = --(x$3)`,
    let th = REWRITE_RULE [DIMINDEX_3; FORALL_3] 
                                      (INST_TYPE [`:3`,`:N`] VECTOR_NEG_COMPONENT) in
                REWRITE_TAC [th]);;

  let VECTOR_MUL_COMPONENT_3 = prove
   (`!c x:real^3. (c % x)$1 = c * x$1 /\
                        (c % x)$2 = c * x$2 /\
                                                                        (c % x)$3 = c * x$3`,
    let th = REWRITE_RULE [DIMINDEX_3; FORALL_3] 
                                      (INST_TYPE [`:3`,`:N`] VECTOR_MUL_COMPONENT) in
                REWRITE_TAC [th]);;

 (* COND_COMPONENT_3 - no need, COND_COMPONENT works fine. *)

  let BASIS_3 = prove
   (`(basis 1:real^3)$1 = &1 /\ (basis 1:real^3)$2 = &0 /\ (basis 1:real^3)$3 = &0 /\
           (basis 2:real^3)$1 = &0 /\ (basis 2:real^3)$2 = &1 /\ (basis 2:real^3)$3 = &0 /\
           (basis 3:real^3)$1 = &0 /\ (basis 3:real^3)$2 = &0 /\ (basis 3:real^3)$3 = &1`,
          REWRITE_TAC [basis; 
                       REWRITE_RULE [DIMINDEX_3; FORALL_3] 
                                                                        (INST_TYPE [`:3`,`:B`] LAMBDA_BETA)] THEN
          ARITH_TAC);;

  let COMPONENTS_3 = prove
         (`!v. v:real^3 = v$1 % basis 1 + v$2 % basis 2 + v$3 % basis 3`,
    REWRITE_TAC [CART_EQ_3; VECTOR_ADD_COMPONENT_3; 
                             VECTOR_MUL_COMPONENT_3; BASIS_3] THEN REAL_ARITH_TAC);;

  let VECTOR_COMPONENTS_3 = prove
         (`!a b c. vector [a;b;c]:real^3 = a % basis 1 + b % basis 2 + c % basis 3`,
          let th = REWRITE_RULE [VECTOR_3] 
                                      (ISPEC `vector [a;b;c]:real^3` COMPONENTS_3) in
    REWRITE_TAC [th]);;

  let cross_skew = prove
         (cross_skew_t,
          REWRITE_TAC [CART_EQ_3; CROSS_COMPONENTS; VECTOR_NEG_COMPONENT_3] THEN 
                REAL_ARITH_TAC);;
          
  let cross_triple = prove
         (cross_triple_t,
          REWRITE_TAC [ DOT_3; CROSS_COMPONENTS] THEN REAL_ARITH_TAC);;
  
        let NORM_CAUCHY_SCHWARZ_FRAC = prove
         (`!(u:real^N) v. ~(u = vec 0) /\ ~(v = vec 0) ==>
                 -- &1 <= (u dot v) / (norm u * norm v) /\
                 (u dot v) / (norm u * norm v) <= &1`,
                REPEAT STRIP_TAC THEN
                SUBGOAL_TAC "norm_pos" `&0 < norm (u:real^N) * norm (v:real^N)`
                [ POP_ASSUM MP_TAC THEN POP_ASSUM MP_TAC THEN 
                  SIMP_TAC [GSYM NORM_POS_LT; IMP_IMP; REAL_LT_MUL] ] THEN
                MP_TAC (SPECL [`u:real^N`;`v:real^N`] NORM_CAUCHY_SCHWARZ_ABS) THEN
                ASM_SIMP_TAC [REAL_ABS_BOUNDS; REAL_LE_RDIV_EQ; REAL_LE_LDIV_EQ] THEN
                REAL_ARITH_TAC);;
        
        let CROSS_LZERO = prove
         (`!x. (vec 0) cross x = vec 0`,
           REWRITE_TAC [CART_EQ_3; CROSS_COMPONENTS; VEC_COMPONENT_3] THEN 
           REAL_ARITH_TAC);;

        let CROSS_RZERO = prove
         (`!x. x cross (vec 0) = vec 0`,
           REWRITE_TAC [CART_EQ_3; CROSS_COMPONENTS; VEC_COMPONENT_3] THEN 
           REAL_ARITH_TAC);;
 
  let CROSS_SQUARED = prove
         (`!u v. (u cross v) dot (u cross v) = 
                       (ups_x (u dot u) (v dot v) ((u - v) dot (u - v))) / &4`,
          REWRITE_TAC [DOT_3; CROSS_COMPONENTS; ups_x; VECTOR_SUB_COMPONENT_3] THEN
          REAL_ARITH_TAC);;
 
  let DIST_UPS_X_POS = prove
   (`~(u = v) /\ ~(u = w) ==>
           &0 <= ups_x (dist(u,v) pow 2) (dist(u,w) pow 2) (dist(v,w) pow 2)`,
                REWRITE_TAC [DIST_TRIANGLE_DETAILS; TRI_UPS_X_POS; REAL_POW_2]);;
  
        let SQRT_DIV_R = prove
         (`&0 <= x /\ &0 <= y ==> sqrt (x) / y = sqrt (x/ (y pow 2)) /\ &0 <= x/(y pow 2)`,
                SIMP_TAC [SQRT_DIV; REAL_LE_POW_2; POW_2_SQRT; REAL_LE_DIV]);;
        
  let NORM_CROSS = prove
         (`!u v. ~(vec 0 = u) /\ ~(vec 0 = v) ==>
                   norm (u cross v) = 
                         sqrt (ups_x ((norm u) pow 2) 
                                                       ((norm v) pow 2) 
                                                                                         ((dist(u,v)) pow 2)) / &2`,
                REPEAT GEN_TAC THEN DISCH_TAC THEN IMP_RES_THEN MP_TAC DIST_UPS_X_POS THEN
                REWRITE_TAC [DIST_L_ZERO] THEN 
                SIMP_TAC[SQRT_DIV_R; REAL_ARITH `&0 <= &2`; REAL_ARITH `&2 pow 2 = &4`] THEN 
                DISCH_TAC THEN MATCH_MP_TAC (GSYM SQRT_UNIQUE) THEN 
                REWRITE_TAC [dist; NORM_POW_2; CROSS_SQUARED] THEN NORM_ARITH_TAC);;
                                
        let VECTOR_LAW_OF_SINES = prove                 
         (`~(vec 0 = u:real^3) /\ ~(vec 0 = v) ==>
           &2 * (norm u) * (norm v) * sin (arcV (vec 0) u v) =
              sqrt (ups_x (norm u pow 2) (norm v pow 2) (dist (u,v) pow 2))`,
                 SIMP_TAC [arcVarc; DIST_TRIANGLE_DETAILS; law_of_sines; DIST_L_ZERO]);;        
                                                
        let cross_mag = prove
         (cross_mag_t,
          REPEAT STRIP_TAC THEN 
                REWRITE_TAC [arcVarc; VECTOR_SUB_RZERO] THEN
                ASM_CASES_TAC `(u:real^3) = vec 0 \/ (v:real^3) = vec 0` THENL
                [ POP_ASSUM STRIP_ASSUME_TAC THEN 
                  ASM_REWRITE_TAC [CROSS_LZERO; CROSS_RZERO; NORM_0] THEN REAL_ARITH_TAC ;
                        POP_ASSUM MP_TAC THEN 
                        REWRITE_TAC [DE_MORGAN_THM; MESON [] `a = vec 0 <=> vec 0 = a`] THEN 
                        SIMP_TAC [NORM_CROSS; GSYM VECTOR_LAW_OF_SINES] THEN REAL_ARITH_TAC ]);;
                        
(*** work in progress

  prove
         (`!u v w. arcV u v w = arcV (vec 0) (v - u) (w - u)`,
           REWRITE_TAC [CONV_RULE KEP_REAL3_CONV arcV; VECTOR_SUB_RZERO]);;

  let ARCV_BILINEAR_L = prove
         (`!(u:real^N) v s. ~(u = vec 0) /\ ~(v = vec 0) /\ &0 < s ==> 
             arcV (vec 0) (s % u) v = arcV (vec 0) u v`,
          REWRITE_TAC [REAL_ARITH `!x. &0 < x <=> ~(&0 = x) /\ &0 <= x`] THEN
                REWRITE_TAC [GSYM NORM_POS_LT] THEN     REPEAT STRIP_TAC THEN 
                REWRITE_TAC [CONV_RULE KEP_REAL3_CONV arcV; VECTOR_SUB_RZERO; DOT_LMUL;
                             NORM_MUL; GSYM REAL_MUL_ASSOC] THEN
                SUBGOAL_TAC "norm_pos" `&0 < norm (u:real^N) * norm (v:real^N)`
                 [MATCH_MP_TAC REAL_LT_MUL THEN ASM_REWRITE_TAC []] THEN 
                SUBGOAL_TAC "norm_nonzero" `~(&0 = norm (u:real^N) * norm (v:real^N))` 
                 [POP_ASSUM MP_TAC THEN REAL_ARITH_TAC] THEN
                SUBGOAL_TAC "stuff" `abs s = s`
                 [ASM_REWRITE_TAC [REAL_ABS_REFL]] THEN 
                ASM_SIMP_TAC [GSYM REAL_DIV_MUL2]);;
        
        let ARCV_SYM = prove
         (`!(u:real^N) v w. arcV u v w = arcV u w v`,
         REWRITE_TAC [CONV_RULE KEP_REAL3_CONV arcV; DOT_SYM; REAL_MUL_SYM]);;

  let ARCV_BILINEAR_R = prove
         (`!(u:real^N) v s. ~(u = vec 0) /\ ~(v = vec 0) /\ &0 < s ==> 
             arcV (vec 0) u (s % v) = arcV (vec 0) u v`,
                REPEAT STRIP_TAC THEN
                SUBGOAL_TAC "switch" `arcV (vec 0) (u:real^N) (s % v) = arcV (vec 0) (s % v)    u`
                 [REWRITE_TAC [ARCV_SYM]] THEN 
                POP_ASSUM SUBST1_TAC THEN ASM_SIMP_TAC [ARCV_BILINEAR_L; ARCV_SYM]);;

  
  prove
         (`!u v. ~(u = vec 0) /\ ~(v = vec 0) ==>
              arcV (vec 0) u v = 
                          arcV (vec 0) ((inv (norm u)) % u) ((inv (norm v)) % v)`,
                REPEAT STRIP_TAC THEN
                SUBGOAL_TAC "u" `&0 < inv (norm (u:real^3))`
                [ REPEAT (POP_ASSUM MP_TAC) THEN 
                  SIMP_TAC [GSYM NORM_POS_LT; REAL_LT_INV] ] THEN
                SUBGOAL_TAC "v" `&0 < inv (norm (v:real^3))`
                [ REPEAT (POP_ASSUM MP_TAC) THEN 
                  SIMP_TAC [GSYM NORM_POS_LT; REAL_LT_INV] ] THEN
                SUBGOAL_TAC "vv" `~(inv (norm v) % (v:real^3) = vec 0)` 
                [ ASM_REWRITE_TAC [VECTOR_MUL_EQ_0] THEN POP_ASSUM MP_TAC THEN 
                  REAL_ARITH_TAC ] THEN
    ASM_SIMP_TAC [ARCV_BILINEAR_L; ARCV_BILINEAR_R]);;

  prove
         (`!v:real^N. ~(v = vec 0) ==> norm((inv (norm v)) % v) = &1`,
          REWRITE_TAC [NORM_MUL; REAL_ABS_INV; REAL_ABS_NORM; GSYM NORM_POS_LT] THEN
                CONV_TAC REAL_FIELD);;
        
        prove
         (`!v0 va vb vc. 
            dihV v0 va vb vc = 
                  dihV (vec 0) (va - v0) (vb - v0) (vc - v0)`,
          REWRITE_TAC [CONV_RULE KEP_REAL3_CONV dihV; VECTOR_SUB_RZERO]);;

  prove
         (`!va vb vc s. ~(va = vec 0) /\ ~(vb = vec 0) /\ ~(vb = vec 0) /\ &0 < s ==> 
             dihV (vec 0) (s % va) vb vc = dihV (vec 0) va vb vc`,
                REWRITE_TAC [REAL_ARITH `!x. &0 < x <=> ~(&0 = x) /\ &0 <= x`] THEN
                REWRITE_TAC [GSYM NORM_POS_LT] THEN     REPEAT STRIP_TAC THEN 
                REWRITE_TAC [CONV_RULE KEP_REAL3_CONV dihV; VECTOR_SUB_RZERO; DOT_LMUL;
                             DOT_RMUL; NORM_MUL; GSYM REAL_MUL_ASSOC; VECTOR_MUL_ASSOC] THEN
                let thm1 = 
                        VECTOR_ARITH `!x v. (s * s * x) % (v:real^3) = (s pow 2) % (x % v)` in
                let thm2 =
                        VECTOR_ARITH `!x v. (s * x * s) % (v:real^3) = (s pow 2) % (x % v)` in
                REWRITE_TAC [thm1; thm2; GSYM VECTOR_SUB_LDISTRIB]
                );;
        
  let COLLINEAR_TRANSLATE = prove 
         (`collinear (s:real^N->bool) <=> collinear {v - v0 | v IN s}`,
          REWRITE_TAC [collinear; IN_ELIM_THM] THEN EQ_TAC THEN STRIP_TAC THEN
                EXISTS_TAC `u :real^N` THEN REPEAT STRIP_TAC THENL 
                [ ASM_SIMP_TAC [VECTOR_ARITH `!u:real^N v w. u - w - (v - w) = u - v`] ;
                  ONCE_REWRITE_TAC [VECTOR_ARITH `x:real^N - y = (x - v0) - (y - v0)`] THEN
                  SUBGOAL_THEN
                          `(?v:real^N. v IN s /\ x - v0 = v - v0) /\
                                 (?v. v IN s /\ y - v0 = v - v0)`
              (fun th -> ASM_SIMP_TAC [th]) THEN 
                        STRIP_TAC THENL [EXISTS_TAC `x:real^N`; EXISTS_TAC `y:real^N`] THEN
                        ASM_REWRITE_TAC [] ]);;
  
	   

         (`{f x | x IN {a, b, c}} = {f a, f b, f c}`,
          REWRITE_TAC [EXTENSION; IN_ELIM_THM; 
                             SET_RULE `x IN {a, b, c} <=> (x = a \/ x = b \/ x = c)`] THEN
                MESON_TAC []);;
        
        let COLLINEAR_TRANSLATE_3 = prove 
         (`collinear {u:real^N, v, w} <=> collinear {u - v0, v - v0, w - v0}`,
          SUBGOAL_TAC "step1"
                  `collinear {u:real^N, v, w} <=> collinear {x - v0 | x IN {u, v, w}}`
                  [ REWRITE_TAC [GSYM COLLINEAR_TRANSLATE] ] THEN
                SUBGOAL_TAC "step2"
                  `{x - v0 | x:real^N IN {u, v, w}} = {u - v0, v - v0, w - v0}`
                        [ REWRITE_TAC [SET_MAP_3] ] THEN
                ASM_REWRITE_TAC [] );;

        let COLLINEAR_ZERO = prove 
         (`collinear {u:real^N, v, w} <=> collinear {vec 0, v - u, w - u}`,
          SUBGOAL_TAC "zero"
                  `vec 0 :real^N = u - u`
                        [ REWRITE_TAC [VECTOR_SUB_REFL] ] THEN
                ASM_REWRITE_TAC [GSYM COLLINEAR_TRANSLATE_3]);;

  let COLLINEAR_SYM = prove
         (`collinear {vec 0: real^N, x, y} <=> collinear {vec 0: real^N, y, x}`,
          AP_TERM_TAC THEN SET_TAC [] );;

  let COLLINEAR_FACT = prove 
         (`collinear {vec 0: real^N, x, y} <=> 
           ((y dot y) % x = (x dot y) % y)`,
                ONCE_REWRITE_TAC [COLLINEAR_SYM] THEN EQ_TAC THENL 
                [ REWRITE_TAC [COLLINEAR_LEMMA] THEN STRIP_TAC THEN
                  ASM_REWRITE_TAC [DOT_LZERO; DOT_RZERO; VECTOR_MUL_LZERO; 
                                   VECTOR_MUL_RZERO; VECTOR_MUL_ASSOC; 
                                                                                         DOT_LMUL; REAL_MUL_SYM];
                        REWRITE_TAC [COLLINEAR_LEMMA;
                                     TAUT `A \/ B \/ C <=> ((~A /\ ~B) ==> C)`] THEN 
                        REPEAT STRIP_TAC THEN EXISTS_TAC `(x:real^N dot y) / (y dot y)` THEN
                        MATCH_MP_TAC 
                          (ISPECL [`y:real^N dot y`;`x:real^N`] VECTOR_MUL_LCANCEL_IMP) THEN
                        SUBGOAL_TAC "zero"
                          `~((y:real^N) dot y = &0)` [ ASM_REWRITE_TAC [DOT_EQ_0] ] THEN
                        ASM_SIMP_TAC [VECTOR_MUL_ASSOC; REAL_DIV_LMUL] ] );;
          

  let COLLINEAR_NOT_ZERO = prove 
         (`~collinear {u:real^N, v, w} ==> ~(vec 0 = v - u) /\ ~(vec 0 = w - u)`,
          ONCE_REWRITE_TAC [COLLINEAR_ZERO] THEN REWRITE_TAC [COLLINEAR_LEMMA] THEN 
                MESON_TAC [] );;

        let COS_ARCV = prove
         (`~(vec 0 = u:real^3) /\ ~(vec 0 = v) ==>
           cos (arcV (vec 0) u v)       = (u dot v) / (norm u * norm v)`,
                REWRITE_TAC [DOT_COS; 
                             MESON [NORM_EQ_0] `!v. vec 0 = v <=> norm v = &0`] THEN
          CONV_TAC REAL_FIELD);;

                
        prove
         (`~(collinear {v0:real^3,va,vc}) /\ ~(collinear {v0,vb,vc}) ==>
    (let gamma = dihV v0 vc va vb in
     let a = arcV v0 vb vc in
     let b = arcV v0 va vc in
     let c = arcV v0 va vb in
       cos(gamma) pow 2 = ((cos(c) - cos(a)*cos(b))/(sin(a)*sin(b))) pow 2)`,                   

                sin (arcV v0 vb vc) = 
                norm (((vc - v0) dot (vc - v0)) % (va - v0) -
          ((va - v0) dot (vc - v0)) % (vc - v0))
                
                cos (arcV v0 va vb) = 
                                                                                                                                                                                                                                
                                                                                                                                                                                                                                                                                                                                                                                          
  prove
         (spherical_loc_t,
          REWRITE_TAC [COLLINEAR_ZERO ;COLLINEAR_FACT] THEN 
                ONCE_REWRITE_TAC [VECTOR_ARITH `a = b <=> vec 0 = a - b`] THEN 
                REPEAT STRIP_TAC THEN 
                REPEAT (CONV_TAC let_CONV) THEN 
                REWRITE_TAC [CONV_RULE KEP_REAL3_CONV dihV] THEN
                ASM_SIMP_TAC [COS_ARCV ; COLLINEAR_NOT_ZERO]

***)
                        
        (* yet unproven theorems: *)
        
  let  spherical_loc = trigAxiomProofB   spherical_loc_t 
  let  spherical_loc2 = trigAxiomProofB   spherical_loc2_t 
  let  dih_formula = trigAxiomProofB   dih_formula_t 
  let  dih_x_acs = trigAxiomProofB   dih_x_acs_t 
  let  beta_cone = trigAxiomProofB   beta_cone_t 
  let  euler_triangle = trigAxiomProofB   euler_triangle_t 
  let  polar_coords = trigAxiomProofB   polar_coords_t 
  let  polar_cycle_rotate = trigAxiomProofB   polar_cycle_rotate_t 
  let  thetaij = trigAxiomProofB   thetaij_t 
  let  thetapq_wind = trigAxiomProofB   thetapq_wind_t 
  let  zenith = trigAxiomProofB   zenith_t 
  let  spherical_coord = trigAxiomProofB   spherical_coord_t 
  let  polar_coord_zenith = trigAxiomProofB   polar_coord_zenith_t 
  let  azim_pair = trigAxiomProofB   azim_pair_t 
  let  azim_cycle_sum = trigAxiomProofB   azim_cycle_sum_t 
  let  dih_azim = trigAxiomProofB   dih_azim_t 
  let  sph_triangle_ineq = trigAxiomProofB   sph_triangle_ineq_t 
  let  sph_triangle_ineq_sum = trigAxiomProofB   sph_triangle_ineq_sum_t 
(* [deprecated]
  let  aff_insert_sym = trigAxiomProofB   aff_insert_sym_t 
  let  aff_sgn_insert_sym_gt = trigAxiomProofB   aff_sgn_insert_sym_gt_t 
  let  aff_sgn_insert_sym_ge = trigAxiomProofB   aff_sgn_insert_sym_ge_t 
  let  aff_sgn_insert_sym_lt = trigAxiomProofB   aff_sgn_insert_sym_lt_t 
  let  aff_sgn_insert_sym_le = trigAxiomProofB   aff_sgn_insert_sym_le_t 
*)
  let  azim_hyp = trigAxiomProofB   azim_hyp_t 
  let  azim_cycle_hyp = trigAxiomProofB   azim_cycle_hyp_t 
(* [deprecated]
  let  aff = trigAxiomProofA   aff_t
  let  aff_gt = trigAxiomProofB   aff_gt_t
  let  aff_ge = trigAxiomProofB   aff_ge_t
  let  aff_lt = trigAxiomProofB   aff_lt_t
  let  aff_le = trigAxiomProofB   aff_le_t
*)
  let  azim = trigAxiomProofB   azim_t
  let  azim_cycle = trigAxiomProofB   azim_cycle_t
end;;

	   
open Trig;;
	   
DIEPKY *)
	   

	   

	   

	   

	   

	   

	   

	   

	   

	   

	   

	   

	   

	   

	   

	   

	   

	   

	   

	   

	   

	   

	   

	   

	   

	   

	   
(* ========== QUANG TRUONG ========== *)
let cosV = new_definition` cosV u v = (u dot v) / (norm u * norm v) `;;
	   
let sinV = new_definition` sinV u v = sqrt ( &1 - cosV u v pow 2 ) `;;
	   

	   

	   
let SET_TAC =
	   
   let basicthms =
	   
    [NOT_IN_EMPTY; IN_UNIV; IN_UNION; IN_INTER; IN_DIFF; IN_INSERT;
	   
     IN_DELETE; IN_REST; IN_INTERS; IN_UNIONS; IN_IMAGE] in
	   
   let allthms = basicthms @ map (REWRITE_RULE[IN]) basicthms @
	   
                 [IN_ELIM_THM; IN] in
	   
   let PRESET_TAC =
	   
     TRY(POP_ASSUM_LIST(MP_TAC o end_itlist CONJ)) THEN
	   
     REPEAT COND_CASES_TAC THEN
	   
     REWRITE_TAC[EXTENSION; SUBSET; PSUBSET; DISJOINT; SING] THEN
	   
     REWRITE_TAC allthms in
	   
   fun ths ->
	   
     PRESET_TAC THEN
	   
     (if ths = [] then ALL_TAC else MP_TAC(end_itlist CONJ ths)) THEN
	   
     MESON_TAC[];;
	   

	   
 let SET_RULE tm = prove(tm,SET_TAC[]);;
	   

	   
(* some TRUONG TACTICS *)
	   

	   
let PHA = REWRITE_TAC[ MESON[] ` (a/\b)/\c <=> a/\ b /\ c `; MESON[]` 
	   
a ==> b ==> c <=> a /\ b ==> c `];;
	   

	   
let NGOAC = REWRITE_TAC[ MESON[] ` a/\b/\c <=> (a/\b)/\c `];;
	   

	   
let DAO = NGOAC THEN REWRITE_TAC[ MESON[]` a /\ b <=> b /\ a`];;
	   

	   
let PHAT = REWRITE_TAC[ MESON[] ` (a\/b)\/c <=> a\/b\/c `];;
	   

	   
let NGOACT =  REWRITE_TAC[ GSYM (MESON[] ` (a\/b)\/c <=> a\/b\/c `)];;
	   

	   
let KHANANG = PHA THEN REWRITE_TAC[ MESON[]` ( a\/ b ) /\ c <=> a /\ c \/ b /\ c `] THEN 
	   
 REWRITE_TAC[ MESON[]` a /\ ( b \/ c ) <=> a /\ b \/ a /\ c `];;
	   

	   
let ATTACH thm = MATCH_MP (MESON[]` ! a b. ( a ==> b ) ==> ( a <=> a /\ b )`) thm;;
	   

	   
let NHANH tm = ONCE_REWRITE_TAC[ ATTACH (SPEC_ALL ( tm ))];;
	   
let LET_TR = CONV_TAC (TOP_DEPTH_CONV let_CONV);;
	   

	   
let DOWN_TAC = REPEAT (FIRST_X_ASSUM MP_TAC) THEN REWRITE_TAC[IMP_IMP] THEN PHA;;
	   
let IMP_IMP_TAC = REWRITE_TAC[GSYM IMP_IMP] ;;
	 
  

	   

	   

	   

	   
let NOT_EQ_IMPCOS_ARC = prove(`~( v0 = (u:real^N) ) /\ ~ ( v0 = w ) ==> cos (arcV v0 u w) = 
	   
((u - v0) dot (w - v0)) / (norm (u - v0) * norm (w - v0))`,
REWRITE_TAC[GSYM VECTOR_SUB_EQ; GSYM NORM_EQ_0] THEN 
	   
NHANH (MESON[NORM_POS_LE]` ~(norm (x:real^N) = &0 ) ==> &0 <= norm x `) THEN 
	   
REWRITE_TAC[REAL_ARITH` ~ ( a = &0 ) /\ &0 <= a <=>
	   
  &0 < a `] THEN 
	   
SIMP_TAC[NORM_SUB] THEN 
	   
MP_TAC (SPECL[` u - (v0:real^N)`; `v0 - (w :real^N) `] NORM_CAUCHY_SCHWARZ_ABS) THEN 
	   
NHANH (REAL_LT_MUL) THEN PHA THEN 
	   
REWRITE_TAC[MESON[REAL_LE_DIV2_EQ; REAL_FIELD ` &0 < a ==> a / a = &1 `]` a <= b /\ l1 /\ l2 /\  &0 < b <=>
	   
  a / b <= &1  /\ l1 /\ l2 /\ &0 < b `] THEN 
	   
NHANH (MESON[REAL_LT_IMP_LE; REAL_ABS_REFL; REAL_ABS_DIV]`
	   
  abs b / a <= &1 /\ l1 /\ l2 /\ &0 < a ==>
	   
  abs ( b / a ) <= &1 `) THEN 
	   
ONCE_REWRITE_TAC[ GSYM REAL_ABS_NEG] THEN 
	   
REWRITE_TAC[REAL_ARITH` -- ( a / b ) = ( --a ) / b `;
	   
  VECTOR_ARITH` --((u - v0) dot (v0 - w)) = ((u - v0) dot (w - v0)) `] THEN
REWRITE_TAC[REAL_ABS_BOUNDS; arcV] THEN 
	   
SIMP_TAC[NORM_SUB] THEN MESON_TAC[COS_ACS]);;
	   

	   

	   

	   
let COLLINEAR_TRANSABLE = prove(
	   
`collinear {(a:real^N), b, c} <=> collinear {vec 0, b - a, c - a}`,
	   
REWRITE_TAC[collinear; IN_INSERT; NOT_IN_EMPTY] THEN EQ_TAC THENL 
	   
[STRIP_TAC THEN EXISTS_TAC `u: real^N` THEN REPEAT GEN_TAC THEN 
	   
ASM_MESON_TAC[VECTOR_ARITH` ( a - c ) - ( b - c ) = a - (b:real^N)`;
	   
  VECTOR_SUB_REFL; VECTOR_ARITH` vec 0 - ( a - b ) = b - a `;
	   
  VECTOR_ARITH` a - vec 0 = a `]; STRIP_TAC THEN EXISTS_TAC `u:real^N`
	   
THEN REPEAT GEN_TAC] THEN ASM_MESON_TAC[VECTOR_ARITH` ( a - c ) - ( b - c ) = a - (b:real^N)`;
	   
  VECTOR_SUB_REFL; VECTOR_ARITH` vec 0 - ( a - b ) = b - a `;
	   
  VECTOR_ARITH` a - vec 0 = a `]);;
	   

	   

	   

	   

	   

	   
let ALLEMI_COLLINEAR = prove(`((vc - v0) dot ((vc: real^N) - v0)) % (va - v0) =
	   
 ((va - v0) dot (vc - v0)) % (vc - v0)
	   
 ==> collinear {v0, vc, va}`,
	   
ASM_CASES_TAC ` (vc - v0) dot (vc - (v0:real^N)) = &0 ` THENL 
	   
[FIRST_X_ASSUM MP_TAC THEN REWRITE_TAC[DOT_EQ_0; VECTOR_SUB_EQ] THEN 
	   
SIMP_TAC[INSERT_INSERT; COLLINEAR_2]; FIRST_X_ASSUM MP_TAC THEN 
	   
PHA THEN NHANH (MESON[]` ~( a = &0 ) /\ b = c ==> &1 / a % b =
	   
  &1 / a % c `) THEN SIMP_TAC[VECTOR_MUL_ASSOC] THEN PHA THEN 
	   
ONCE_REWRITE_TAC[MESON[]` a /\b ==> c <=> a ==> b ==> c `] THEN 
	   
SIMP_TAC[REAL_FIELD` ~ ( a = &0 ) ==> &1 / a * a = &1 `;
	   
  VECTOR_MUL_LID] THEN ONCE_REWRITE_TAC[COLLINEAR_TRANSABLE ] THEN 
	   
MESON_TAC[COLLINEAR_LEMMA]]);;
	   

	   

	   
let NOT_VEC0_IMP_LE1 = prove(`~( x = vec 0 ) /\ ~( y = vec 0 ) ==> 
	   
abs (( x dot y )/ (( norm x ) * ( norm y ))) <= &1 `,
	   
REWRITE_TAC[GSYM NORM_POS_LT; REAL_ABS_DIV; REAL_ABS_MUL; REAL_ABS_NORM] THEN 
	   
NHANH (REAL_LT_MUL) THEN 
	   
SIMP_TAC[REAL_LE_LDIV_EQ; REAL_MUL_LID; NORM_CAUCHY_SCHWARZ_ABS]);;
	   

	   
let sin_acs_t = prove(`! y. (-- &1 <= y /\ y <= &1) ==> (sin (acs(y)) = sqrt(&1 - y pow 2))`,
	   
    REPEAT STRIP_TAC THEN MATCH_MP_TAC(GSYM SQRT_UNIQUE) THEN
	   
    ASM_SIMP_TAC[ACS_BOUNDS; SIN_POS_PI_LE; REAL_EQ_SUB_RADD] THEN
	   
    ASM_MESON_TAC[COS_ACS; SIN_CIRCLE]);;
	   

	   

	   
let ABS_LE_1_IMP_SIN_ACS = prove(`!y. abs y <= &1 ==> sin (acs y) = sqrt (&1 - y pow 2)`,
	   
SIMP_TAC[REAL_ABS_BOUNDS; sin_acs_t]);;
	   

	   

	   
let NOT_2EQ_IMP_SIN_ARCV = prove(`~( v0 = va) /\ ~(v0 = (vb:real^N)) ==>
	   
 sin ( arcV v0 va vb ) = sqrt
	   
     (&1 -
	   
      (((va - v0) dot (vb - v0)) / (norm (va - v0) * norm (vb - v0))) pow 2) `,
	   
REWRITE_TAC[arcV] THEN ONCE_REWRITE_TAC[EQ_SYM_EQ] THEN 
	   
ONCE_REWRITE_TAC[GSYM VECTOR_SUB_EQ] THEN NHANH (NOT_VEC0_IMP_LE1 ) THEN 
	   
SIMP_TAC[ABS_LE_1_IMP_SIN_ACS]);;
	   

	   

	   
let ABS_NOT_EQ_NORM_MUL = prove(` ~ ( abs ( x dot y )  = norm x * norm y ) <=>
	   
  abs ( x dot y ) < norm x * norm y `,
	   
SIMP_TAC[REAL_LT_LE; NORM_CAUCHY_SCHWARZ_ABS]);;
	   

	   

	   

	   
let SQUARE_NORM_CAUCHY_SCHWARZ_POW2 = prove(`((x:real^N) dot y) pow 2 <= (norm x * norm y) pow 2`,
	   
REWRITE_TAC[GSYM REAL_LE_SQUARE_ABS] THEN 
	   
MESON_TAC[GSYM REAL_ABS_REFL; REAL_LE_MUL; NORM_POS_LE;
	   
  NORM_CAUCHY_SCHWARZ_ABS]);;
	   

let REAL_LE_POW_2 = prove(` ! x. &0 <= x pow 2 `,
REWRITE_TAC[REAL_POW_2; REAL_LE_SQUARE]);;

	   
let SQRT_SEPARATED = prove(`sqrt (((norm x * norm y) pow 2 - ((x:real^N) dot y) pow 2) / (norm x * norm y) pow 2) =
	   
 sqrt ((norm x * norm y) pow 2 - (x dot y) pow 2) /
	   
 sqrt ((norm x * norm y) pow 2)`,
	   
MP_TAC SQUARE_NORM_CAUCHY_SCHWARZ_POW2 THEN 
	   
ONCE_REWRITE_TAC[GSYM REAL_SUB_LE] THEN SIMP_TAC[REAL_LE_POW_2; SQRT_DIV]);;
	   

	   

	   

	   

	   
let COMPUTE_NORM_OF_P = prove(`norm ((vc dot vc) % va - (va dot vc) % vc) =
	   
 sqrt ((vc dot vc) * ((va dot va) * (vc dot vc) - (va dot vc) pow 2))`,
	   
REWRITE_TAC[vector_norm; DOT_LSUB; DOT_RSUB; DOT_LMUL; DOT_RMUL] THEN 
	   
MATCH_MP_TAC (MESON[]` a = b ==> P a = P b `) THEN SIMP_TAC[DOT_SYM] THEN REAL_ARITH_TAC);;
	   

	   

	   

	   

	   
let MOVE_NORM_OUT_OF_SQRT = prove(`sqrt (norm (vc:real^N) pow 2 * ((norm va * norm vc) pow 2 - (va dot vc) pow 2)) =
	   
 norm vc * sqrt ((norm va * norm vc) pow 2 - (va dot vc) pow 2)`,
	   
MP_TAC (MESON[SQUARE_NORM_CAUCHY_SCHWARZ_POW2]`
	   
  ((va: real^N) dot vc) pow 2 <= (norm va * norm vc) pow 2 `) THEN 
	   
ONCE_REWRITE_TAC[GSYM REAL_SUB_LE] THEN 
	   
SIMP_TAC[REAL_LE_POW_2; SQRT_MUL; NORM_POS_LE; POW_2_SQRT]);;
	   

let PI2_EQ_ACS0 = prove(` pi / &2 = acs ( &0 ) `,
MP_TAC (REAL_ARITH` -- &1 <= &0 /\ &0 <= &1 `) THEN 
NHANH ACS_BOUNDS THEN STRIP_TAC THEN MATCH_MP_TAC COS_INJ_PI
THEN ASM_SIMP_TAC[COS_PI2; COS_ACS] THEN ASSUME_TAC PI_POS
THEN ASM_REAL_ARITH_TAC);;

let ANGLE_EQ_ARCV = prove(`! vap vbp.  angle (vap,vec 0,vbp) = arcV (vec 0) vap vbp `,
REWRITE_TAC[arcV; angle; vector_angle] THEN REPEAT STRIP_TAC THEN
COND_CASES_TAC THENL [POP_ASSUM DISJ_CASES_TAC THENL [
ASM_SIMP_TAC[DOT_LZERO; REAL_ARITH` &0 / a = &0 `; PI2_EQ_ACS0];
ASM_SIMP_TAC[DOT_RZERO; REAL_ARITH` &0 / a = &0 `; PI2_EQ_ACS0]];
REWRITE_TAC[]]);;


let dihV = prove(`! w0 w1 w2 w3. dihV w0 w1 w2 w3 =
 (let va = w2 - w0 in
  let vb = w3 - w0 in
  let vc = w1 - w0 in
  let vap = (vc dot vc) % va - (va dot vc) % vc in
  let vbp = (vc dot vc) % vb - (vb dot vc) % vc in arcV (vec 0) vap vbp)`,
SIMP_TAC[dihV; ANGLE_EQ_ARCV]);;
	   
(* lemma 16 *)
	   

	   
let RLXWSTK = prove(`! (v0: real^N) va vb vc. let gam = dihV v0 vc va vb in
	   
 let a = arcV v0 vc vb in
	   
 let b = arcV v0 vc va in
	   
 let c = arcV v0 va vb in
	   
 ~collinear {v0, vc, va} /\ ~collinear {v0, vc, vb}
	   
 ==> cos gam = (cos c - cos a * cos b) / ( sin a * sin b )`, 
	   
REPEAT GEN_TAC THEN REPEAT LET_TAC THEN EXPAND_TAC "gam" THEN 
	   
REWRITE_TAC[dihV] THEN LET_TR THEN 
	   
NHANH (ONCE_REWRITE_RULE[GSYM CONTRAPOS_THM] ALLEMI_COLLINEAR) THEN 
	   
ONCE_REWRITE_TAC[VECTOR_ARITH` a = b <=> vec 0 = a - b `] THEN 
	   
SIMP_TAC[NOT_EQ_IMPCOS_ARC; VECTOR_SUB_RZERO ] THEN 
	   
ABBREV_TAC ` (va_v0p: real^N) = ((vc - v0) dot (vc - v0)) % (va - v0) -
	   
((va - v0) dot (vc - v0)) % (vc - v0) ` THEN 
	   
ABBREV_TAC ` (vb_v0p :real^N) = ((vc - v0) dot (vc - v0)) % (vb - v0) -
	   
       ((vb - v0) dot (vc - v0)) % (vc - v0) ` THEN 
	   
EXPAND_TAC "c" THEN EXPAND_TAC "a" THEN EXPAND_TAC "b" THEN 
	   
NHANH (MESON[COLLINEAR_2; INSERT_INSERT; INSERT_AC]` 
	   
  ~collinear {v0, vc, va} ==> ~( v0 = vc) /\ ~( v0 = va ) `) THEN 
	   
SIMP_TAC[NOT_2EQ_IMP_SIN_ARCV; NOT_EQ_IMPCOS_ARC] THEN 
	   
ONCE_REWRITE_TAC[COLLINEAR_TRANSABLE] THEN 
	   
REWRITE_TAC[GSYM NORM_CAUCHY_SCHWARZ_EQUAL] THEN 
	   
ONCE_REWRITE_TAC[VECTOR_ARITH` a = b <=> b - a = vec 0`] THEN 
	   
SIMP_TAC[ GSYM NORM_EQ_0] THEN ONCE_REWRITE_TAC[ GSYM DE_MORGAN_THM] THEN 
	   
REWRITE_TAC[GSYM REAL_ENTIRE] THEN SIMP_TAC[REAL_FIELD`~ ( c = &0 ) ==>  
	   
  &1 - ( b / c ) pow 2 = ( c pow 2 - b pow 2) / c pow 2 `] THEN 
	   
SIMP_TAC[SQRT_SEPARATED] THEN SIMP_TAC[REAL_LE_MUL; NORM_POS_LE; POW_2_SQRT] THEN 
	   
SIMP_TAC[REAL_FIELD` x / (( b / a ) * ( c / aa )) = ( x * a * aa ) / ( b * c ) `] THEN 
	   
REWRITE_TAC[REAL_SUB_RDISTRIB; REAL_MUL_AC; REAL_ENTIRE; DE_MORGAN_THM] THEN 
	   
SIMP_TAC[REAL_FIELD` ~( a = &0 ) /\ ~( b = &0 ) 
	   
  ==> x / ( a * b ) * a * b * c = x * c `;
	   
  REAL_FIELD` ~( a = &0 ) /\ ~ ( b = &0 ) /\ ~ ( c = &0)  ==> 
	   
  x / ( a * c ) * y / ( b * c ) * a * b * c * c = x * y `] THEN 
	   
STRIP_TAC THEN EXPAND_TAC "va_v0p" THEN EXPAND_TAC "vb_v0p" THEN 
	   
REWRITE_TAC[COMPUTE_NORM_OF_P] THEN 
	   
REWRITE_TAC[ GSYM NORM_POW_2; REAL_ARITH` a pow 2 * b pow 2 = ( a * b ) pow 2`] THEN 
	   
ABBREV_TAC `vaa = ( va - (v0:real^N))` THEN 
	   
ABBREV_TAC `vbb = ( vb - (v0:real^N))` THEN 
	   
ABBREV_TAC `vcc = ( vc - (v0:real^N))` THEN 
	   
SIMP_TAC[MOVE_NORM_OUT_OF_SQRT; DOT_LSUB; DOT_RSUB] THEN 
	   
SIMP_TAC[MOVE_NORM_OUT_OF_SQRT; DOT_LSUB; DOT_RSUB;
	   
 DOT_LMUL; DOT_RMUL; DOT_SYM; GSYM NORM_POW_2] THEN 
	   
REWRITE_TAC[REAL_ARITH` ( a * b ) * a * c = a pow 2 * b * c `] THEN 
	   
REWRITE_TAC[REAL_FIELD` a / ( b * c ) = ( a / b ) / c `] THEN 
	   
MATCH_MP_TAC (MESON[]` a = b ==> a / c = b / c `) THEN 
	   
MATCH_MP_TAC (MESON[]` a = b ==> a / c = b / c `) THEN 
	   
REWRITE_TAC[REAL_ARITH` norm vcc pow 2 * norm vcc pow 2 * (vaa dot vbb) -
	   
     norm vcc pow 2 * (vbb dot vcc) * (vaa dot vcc) -
	   
     ((vaa dot vcc) * norm vcc pow 2 * (vbb dot vcc) -
	   
      (vaa dot vcc) * (vbb dot vcc) * norm vcc pow 2) =
	   
  norm vcc pow 2 * ( norm vcc pow 2 * (vaa dot vbb) - (vaa dot vcc) * (vbb dot vcc) ) `] THEN 
	   
UNDISCH_TAC `~ ( norm (vcc:real^N) = &0 ) ` THEN CONV_TAC REAL_FIELD);;
	   

	   

	   

	   

	   

	   
let SIN_POW2_EQ_1_SUB_COS_POW2 = prove(` sin x pow 2 = &1 - cos x pow 2 `,
	   
MP_TAC (SPEC_ALL SIN_CIRCLE) THEN REAL_ARITH_TAC);;
	   

	   

	   

	   

	   
let LE_AND_NOT_0_EQ_LT = REAL_ARITH` &0 <= a /\ ~( a = &0 ) <=> &0 < a `;;
	   

	   
let ABS_REFL = REAL_ABS_REFL;;
	   
let LT_IMP_ABS_REFL = MESON[REAL_ABS_REFL; REAL_LT_IMP_LE]`&0 < a ==> abs a = a`;;
	   

	   

let ABS_MUL = REAL_ABS_MUL;;
	   
	   
let NOT_COLLINEAR_IMP_NOT_SIN0 = prove(`~collinear {v0, va, vb}  ==> ~(sin ( arcV v0 va vb ) = &0)`,
	   
SIMP_TAC[] THEN NHANH (MESON[INSERT_AC; COLLINEAR_2]` ~collinear {v0, va, vb}
	   
  ==> ~( v0 = va ) /\ ~(v0 = vb) `) THEN 
	   
SIMP_TAC[NOT_2EQ_IMP_SIN_ARCV] THEN 
	   
ONCE_REWRITE_TAC[VECTOR_ARITH` a = b <=> b - a = vec 0 `] THEN 
	   
SIMP_TAC[ GSYM NORM_POS_LT] THEN 
	   
STRIP_TAC THEN 
	   
MATCH_MP_TAC (MESON[SQRT_EQ_0]` &0 <= x /\ ~( x = &0 ) ==> ~( sqrt x = &0 ) `) THEN 
	   
DOWN_TAC THEN 
	   
ONCE_REWRITE_TAC[ COLLINEAR_TRANSABLE ] THEN 
	   
REWRITE_TAC[ GSYM NORM_CAUCHY_SCHWARZ_EQUAL; ABS_NOT_EQ_NORM_MUL;
	   
LE_AND_NOT_0_EQ_LT ] THEN 
	   
SIMP_TAC[REAL_FIELD`&0 < a /\ &0 < aa ==> &1 - ( b / ( a * aa )) pow 2
	   
  = ( ( a * aa ) pow 2 - b pow 2 ) / ( a * aa ) pow 2 `] THEN 
	   
STRIP_TAC THEN 
	   
MATCH_MP_TAC (SPEC_ALL REAL_LT_DIV) THEN 
	   
REWRITE_TAC[REAL_SUB_LT; GSYM REAL_LT_SQUARE_ABS] THEN 
	   
ONCE_REWRITE_TAC[REAL_ARITH` &0 = &0 pow 2 `] THEN 
	   
DOWN_TAC THEN 
	   
REWRITE_TAC[REAL_SUB_LT; GSYM REAL_LT_SQUARE_ABS; REAL_ABS_0;
	   
  ABS_MUL] THEN 
	   
SIMP_TAC[LT_IMP_ABS_REFL; REAL_LT_MUL ]);;
	 
  
let REAL_LE_LDIV = 
MESON[REAL_LE_LDIV_EQ; REAL_MUL_LID]`
 ! x  z. &0 < z /\ x <= z ==> x / z <=  &1 `;;
	   
	   
let NOT_IDEN_IMP_ABS_LE = prove(`~(v0 = va) /\ ~(v0 = vb)
	   
 ==> abs (((va - v0) dot (vb - v0)) / (norm (va - v0) * norm (vb - v0))) <=
	   
     &1`, ONCE_REWRITE_TAC[VECTOR_ARITH` a = b <=> b - a = vec 0`] THEN 
	  
SIMP_TAC[REAL_ABS_DIV; REAL_ABS_MUL; REAL_ABS_NORM; GSYM NORM_POS_LT] THEN 
	   
STRIP_TAC THEN MATCH_MP_TAC REAL_LE_LDIV
 THEN ASM_SIMP_TAC[REAL_LT_MUL; REAL_MUL_LID;
REAL_DIV_1; NORM_CAUCHY_SCHWARZ_ABS]);;
	   

	   
let ABS_1 = REAL_ABS_1;;
	   
let PROVE_SIN_LE = prove(`~(v0 = va) /\ ~(v0 = vb)  ==> &0 <= sin ( arcV v0 va vb )`,
	   
SIMP_TAC[NOT_2EQ_IMP_SIN_ARCV; arcV] THEN 
	   
NGOAC THEN NHANH (NOT_IDEN_IMP_ABS_LE ) THEN 
	   
SIMP_TAC[ABS_LE_1_IMP_SIN_ACS] THEN STRIP_TAC THEN MATCH_MP_TAC SQRT_POS_LE THEN 
	   
DOWN_TAC THEN ONCE_REWRITE_TAC[ GSYM ABS_1] THEN 
	   
ASM_SIMP_TAC[REAL_SUB_LE; GSYM ABS_1; REAL_LE_SQUARE_ABS] THEN 
	   
SIMP_TAC[REAL_ARITH`( &1 ) pow 2 = &1`; ABS_1]);;
	   

	   

	   

	   
let MUL_POW2 = REAL_ARITH` (a*b) pow 2 = a pow 2 * b pow 2 `;;
	   

	   

	   

	   

	   
let COMPUTE_SIN_DIVH_POW2 = prove(`! (v0: real^N) va vb vc.
	   
     let betaa = dihV v0 vc va vb in
	   
     let a = arcV v0 vc vb in
	   
     let b = arcV v0 vc va in
	   
     let c = arcV v0 va vb in
	   
     let p =
	   
         &1 - cos a pow 2 - cos b pow 2 - cos c pow 2 +
	   
         &2 * cos a * cos b * cos c in
	   
~collinear {v0, vc, va} /\ ~collinear {v0, vc, vb} ==>
	   
     ( sin betaa ) pow 2 = p / ((sin a * sin b) pow 2) `,

REPEAT STRIP_TAC THEN MP_TAC (SPEC_ALL RLXWSTK ) THEN 
	   
REPEAT LET_TAC THEN SIMP_TAC[SIN_POW2_EQ_1_SUB_COS_POW2 ] THEN 
	   
REPEAT STRIP_TAC THEN REPLICATE_TAC 2 (FIRST_X_ASSUM MP_TAC) THEN 
	   
NHANH (NOT_COLLINEAR_IMP_NOT_SIN0) THEN 
	   
EXPAND_TAC "a" THEN EXPAND_TAC "b" THEN PHA THEN 
	   
SIMP_TAC[REAL_FIELD` ~( a = &0 ) /\ ~ ( b = &0 ) ==>
	   
  &1 - ( x / ( a * b )) pow 2 = (( a * b ) pow 2 - x pow 2 ) / (( a * b ) pow 2 ) `] THEN 
	   
ASM_SIMP_TAC[] THEN STRIP_TAC THEN 
	   
MATCH_MP_TAC (MESON[]` a = b ==> a / x  = b / x `) THEN 
	   
EXPAND_TAC "p" THEN SIMP_TAC[MUL_POW2; SIN_POW2_EQ_1_SUB_COS_POW2] THEN 
	   
REAL_ARITH_TAC);;
	   

	   

	   

	   

	   
let PROVE_P_LE = prove(`!(v0:real^N) va vb vc.
	   
     let a = arcV v0 vc vb in
	   
     let b = arcV v0 vc va in
	   
     let c = arcV v0 va vb in
	   
     let p =
	   
         &1 - cos a pow 2 - cos b pow 2 - cos c pow 2 +
	   
         &2 * cos a * cos b * cos c in
	   
     ~collinear {v0, vc, va} /\ ~collinear {v0, vc, vb} ==> &0 <= p`,
	   
REPEAT GEN_TAC THEN MP_TAC (SPEC_ALL COMPUTE_SIN_DIVH_POW2 ) THEN 
	   
REPEAT LET_TAC THEN REWRITE_TAC[MESON[]` ( a ==> b ) ==> a ==> c <=>
	   
  a /\ b ==> c `] THEN NHANH (NOT_COLLINEAR_IMP_NOT_SIN0) THEN 
	   
ASM_SIMP_TAC[] THEN STRIP_TAC THEN FIRST_X_ASSUM MP_TAC THEN 
	   
ASM_SIMP_TAC[REAL_FIELD` ~( a = &0 ) /\ ~( b = &0 ) ==>
	   
  ( x = y / ( a * b ) pow 2 <=> x * ( a * b ) pow 2 = y ) `] THEN 
	   
MESON_TAC[GSYM MUL_POW2; REAL_LE_POW_2]);;
	   

	   

	   
let POW2_COND = MESON[REAL_ABS_REFL; REAL_LE_SQUARE_ABS]` ! a b. &0 <= a /\ &0 <= b ==> 
	   
( a <= b <=> a pow 2 <= b pow 2 ) `;;
	   

	   

	   
let EQ_POW2_COND = prove(`!a b. &0 <= a /\ &0 <= b ==> (a = b <=> a pow 2 = b pow 2)`,
	   
REWRITE_TAC[REAL_ARITH` a = b <=> a <= b /\ b <= a `] THEN SIMP_TAC[POW2_COND]);;
	   

	   
let NOT_COLLINEAR_IMP_2_UNEQUAL = MESON[INSERT_INSERT; COLLINEAR_2; INSERT_AC]`
	   
  ~collinear {v0, va, vb} ==> ~(v0 = va) /\ ~(v0 = vb) `;;
	   

	   

	   
let NOT_COLL_IM_SIN_LT = prove(`~collinear {v0, va, vb} ==> &0 < sin (arcV v0 va vb)`,
	   
REWRITE_TAC[GSYM LE_AND_NOT_0_EQ_LT] THEN 
	   
NHANH (NOT_COLLINEAR_IMP_2_UNEQUAL ) THEN 
	   
SIMP_TAC[NOT_COLLINEAR_IMP_NOT_SIN0; PROVE_SIN_LE]);;
	   

	   
let ARC_SYM = prove(` arcV v0 vc vb = arcV v0 vb vc `,
	   
SIMP_TAC[arcV; DOT_SYM; REAL_MUL_SYM]);;
	   

	   

	   
let DIV_POW2 = REAL_FIELD` ( a / b ) pow 2 = a pow 2 / b pow 2 `;;
	   

	   

	   
ONCE_REWRITE_RULE[GSYM  CONTRAPOS_THM] ALLEMI_COLLINEAR;;
	   

	   
let SIN_MUL_EXPAND = prove(` !(v0:real^N) va vb vc.
	   
         let gam = dihV v0 vc va vb in 
	   
         let bet = dihV v0 vb vc va in
	   
         let a = arcV v0 vc vb in
	   
         let b = arcV v0 vc va in
	   
         let c = arcV v0 va vb in
	   
         let p =
	   
             &1 - cos a pow 2 - cos b pow 2 - cos c pow 2 +
	   
             &2 * cos a * cos b * cos c in
	   
         ~collinear {v0, vc, va} /\ ~collinear {v0, vc, vb} /\
	   
  ~ collinear {v0,va,vb} ==>
	   
  sin gam * sin bet = p / ( sin b * sin c * ( sin a pow 2 )) `,
REPEAT GEN_TAC THEN 
	   
MP_TAC (COMPUTE_SIN_DIVH_POW2) THEN 
	   
REPEAT LET_TAC THEN 
	   
REPEAT STRIP_TAC THEN 
	   
MATCH_MP_TAC (MESON[EQ_POW2_COND]` &0 <= a /\ &0 <= b /\ a pow 2 = b pow 2
	   
  ==> a = b `) THEN 
	   
CONJ_TAC THENL [ REPLICATE_TAC 3 (FIRST_X_ASSUM MP_TAC) THEN 
	   
EXPAND_TAC "gam" THEN EXPAND_TAC "betaa" THEN 
	   
EXPAND_TAC "bet" THEN REWRITE_TAC[dihV] THEN LET_TR THEN 
	   
NHANH (ONCE_REWRITE_RULE[GSYM  CONTRAPOS_THM] ALLEMI_COLLINEAR) THEN 
	   
ONCE_REWRITE_TAC[SET_RULE` {a,b} = {b,a}`] THEN 
	   
NHANH (ONCE_REWRITE_RULE[GSYM  CONTRAPOS_THM] ALLEMI_COLLINEAR) THEN 
	   
ONCE_REWRITE_TAC[VECTOR_ARITH ` a = b <=> vec 0 = a - b `] THEN 
	   
REPEAT STRIP_TAC THEN MATCH_MP_TAC REAL_LE_MUL THEN 
	   
ASM_SIMP_TAC[PROVE_SIN_LE]; REWRITE_TAC[]] THEN 
	   
CONJ_TAC THENL [MP_TAC (SPEC_ALL PROVE_P_LE ) THEN 
	   
REPEAT LET_TAC THEN 
	   
DOWN_TAC THEN 
	   
ONCE_REWRITE_TAC[EQ_SYM_EQ] THEN 
	   
STRIP_TAC THEN 
	   
FIRST_X_ASSUM MP_TAC THEN 
	   
ASM_SIMP_TAC[] THEN 
	   
MATCH_MP_TAC (MESON[]` (! a. a = b ==> &0 <= a ==>  P a )
	   
   ==> &0 <= b ==> P b `) THEN 
	   
GEN_TAC THEN STRIP_TAC THEN 
	   
UNDISCH_TAC `~collinear {v0, vc, (vb: real^N)}` THEN 
	   
UNDISCH_TAC `~collinear {v0, vc, (va: real^N)}` THEN 
	   
UNDISCH_TAC `~collinear {v0, va, (vb: real^N)}` THEN 
	   
NHANH (NOT_COLL_IM_SIN_LT  ) THEN 
	   
NHANH (REAL_LT_IMP_LE) THEN 
	   
REPEAT STRIP_TAC THEN 
	   
MATCH_MP_TAC REAL_LE_DIV THEN 
	   
ASM_SIMP_TAC[REAL_LE_MUL; REAL_LE_POW_2]; REWRITE_TAC[]] THEN
EXPAND_TAC "gam" THEN EXPAND_TAC "betaa" THEN EXPAND_TAC "bet" THEN 
	   
SIMP_TAC[MUL_POW2] THEN 
	   
REPLICATE_TAC 3 (FIRST_X_ASSUM MP_TAC) THEN 
	   
PHA THEN 
	   
FIRST_X_ASSUM MP_TAC THEN 
	   
SIMP_TAC[] THEN 
	   
DISCH_TAC THEN 
	   
ONCE_REWRITE_TAC[SET_RULE` {a,b} = {b,a}`] THEN 
	   
FIRST_X_ASSUM MP_TAC THEN 
	   
SIMP_TAC[] THEN 
	   
REWRITE_TAC[REAL_FIELD` a / x * aa / y = ( a * aa ) / ( x * y ) `] THEN 
	   
REPEAT STRIP_TAC THEN 
	   
ASM_SIMP_TAC[ARC_SYM] THEN 
	   
ONCE_REWRITE_TAC[ARC_SYM] THEN 
	   
ASM_SIMP_TAC[] THEN 
	   
SIMP_TAC[DIV_POW2; REAL_ARITH` ((sin a * sin b) pow 2 * (sin c * sin a) pow 2) =
	   
  (sin b * sin c * sin a pow 2) pow 2 `] THEN 
	   
MATCH_MP_TAC (MESON[]` a = b ==> a / x = b / x `) THEN 
	   
EXPAND_TAC "p'" THEN 
	   
EXPAND_TAC "p" THEN 
	   
EXPAND_TAC "a" THEN 
	   
EXPAND_TAC "b" THEN 
	   
EXPAND_TAC "c" THEN 
	   
EXPAND_TAC "a'" THEN 
	   
EXPAND_TAC "b'" THEN 
	   
EXPAND_TAC "c'" THEN 
	   
SIMP_TAC[ARC_SYM] THEN 
	   
REAL_ARITH_TAC);;
	   

	   
let DIHV_SYM = prove(`dihV a b x y = dihV a b y x `,
	   
REWRITE_TAC[dihV] THEN LET_TR THEN SIMP_TAC[DOT_SYM; ARC_SYM]);;
	   

	   
(* lemma 17 *)
	   
let NLVWBBW = prove(` !(v0:real^N) va vb vc.
	   
let al = dihV v0 va vb vc in
	   
         let ga = dihV v0 vc va vb in 
	   
         let be = dihV v0 vb vc va in
	   
         let a = arcV v0 vc vb in
	   
         let b = arcV v0 vc va in
	   
         let c = arcV v0 va vb in
	   
         let p =
	   
             &1 - cos a pow 2 - cos b pow 2 - cos c pow 2 +
	   
             &2 * cos a * cos b * cos c in
	   
         ~collinear {v0, vc, va} /\ ~collinear {v0, vc, vb} /\
	   
  ~ collinear {v0,va,vb} ==>
	   
cos c * sin al * sin be = cos ga + cos al * cos be `,
	   
REPEAT GEN_TAC THEN MP_TAC RLXWSTK THEN REPEAT LET_TAC THEN 
	   
EXPAND_TAC "al" THEN EXPAND_TAC "be" THEN EXPAND_TAC "ga" THEN 
	   
EXPAND_TAC "gam" THEN SIMP_TAC[INSERT_AC] THEN STRIP_TAC THEN 
	   
MP_TAC SIN_MUL_EXPAND THEN REPEAT LET_TAC THEN EXPAND_TAC "bet" THEN 
	   
SIMP_TAC[INSERT_AC; DIHV_SYM; ARC_SYM] THEN 
	   
ONCE_REWRITE_TAC[MESON[DIHV_SYM]` aa * sin (dihV v0 va vb vc) * sin (dihV v0 vb va vc) =
	   
  aa * sin (dihV v0 va vc vb) * sin (dihV v0 vb vc va)`] THEN 
	   
DISCH_TAC THEN ONCE_REWRITE_TAC[MESON[INSERT_AC]`~collinear {v0, va, vc} /\
	   
 ~collinear {v0, vb, vc} /\ ~collinear {v0, va, vb} <=>
	   
~collinear {v0, vc, va} /\ ~collinear {v0, vb, va} /\
	   
 ~collinear {v0, vc, vb}  `] THEN FIRST_X_ASSUM MP_TAC THEN 
	   
SIMP_TAC[] THEN DOWN_TAC THEN SIMP_TAC[ARC_SYM; DIHV_SYM] THEN 
	   
STRIP_TAC THEN REPLICATE_TAC 3 (FIRST_X_ASSUM MP_TAC) THEN 
	   
NHANH (NOT_COLLINEAR_IMP_NOT_SIN0) THEN ASM_SIMP_TAC[ARC_SYM] THEN 
	   
REPEAT STRIP_TAC THEN UNDISCH_TAC `~( sin a = &0 )` THEN 
	   
UNDISCH_TAC `~( sin b = &0 )` THEN UNDISCH_TAC `~( sin c = &0 )` THEN 
	   
PHA THEN SIMP_TAC[REAL_FIELD `~(c = &0) /\ ~(b = &0) /\ ~(a = &0)
	   
  ==> x / (a * b) +     y / (b * c) *     z / (c * a) = ( x * c pow 2 + y * z ) / ( b * a * c pow 2 ) `] THEN 
	   
STRIP_TAC THEN REWRITE_TAC[REAL_ARITH` a * ( x / y ) = ( a * x ) / y `] THEN 
	   
MATCH_MP_TAC (MESON[]` a = b ==> a / x = b / x `) THEN 
	   
SIMP_TAC[SIN_POW2_EQ_1_SUB_COS_POW2] THEN REAL_ARITH_TAC);;
	 
  

	   

	   
let COMPUTE_NORM_POW2 = prove(`
	   
 norm ((vc dot vc) % vb - (vb dot vc) % vc ) pow 2 = ((norm vc pow 2 + norm vc pow 2) - dist (vc,vc) pow 2) / &2 *
	   
 (((norm vc pow 2 + norm vc pow 2) - dist (vc,vc) pow 2) / &2 *
	   
  ((norm vb pow 2 + norm vb pow 2) - dist (vb,vb) pow 2) / &2 -
	   
  ((norm vb pow 2 + norm vc pow 2) - dist (vb,vc) pow 2) / &2 *
	   
  ((norm vb pow 2 + norm vc pow 2) - dist (vb,vc) pow 2) / &2) -
	   
 ((norm vb pow 2 + norm vc pow 2) - dist (vb,vc) pow 2) / &2 *
	   
 (((norm vc pow 2 + norm vc pow 2) - dist (vc,vc) pow 2) / &2 *
	   
  ((norm vc pow 2 + norm vb pow 2) - dist (vc,vb) pow 2) / &2 -
	   
  ((norm vb pow 2 + norm vc pow 2) - dist (vb,vc) pow 2) / &2 *
	   
  ((norm vc pow 2 + norm vc pow 2) - dist (vc,vc) pow 2) / &2) `,
	   
MATCH_MP_TAC (MESON[]`(! c. c = b ==> a = c ) ==> a = b`) THEN REPEAT STRIP_TAC THEN 
	   
SIMP_TAC[NORM_POW_2] THEN SIMP_TAC[GSYM dist; 
	   
VECTOR_SUB_RZERO; DOT_LSUB; DOT_RSUB; DOT_LMUL; 
	   
DOT_RMUL; DOT_NORM_NEG] THEN ASM_SIMP_TAC[]);;
	   

	   

	   
let UPS_X_AND_HERON = prove(`ups_x (x1 pow 2) (x2 pow 2) (x6 pow 2) =
	   
 (x1 + x2 + x6) * (x1 + x2 - x6) * (x2 + x6 - x1) * (x6 + x1 - x2)`,
	   
SIMP_TAC[ups_x] THEN REAL_ARITH_TAC);;
	   

	   

	   
let UPS_X_POS = prove(`dist (v0,v1) pow 2 = v01 /\
	   
 dist (v0,v2) pow 2 = v02 /\
	   
 dist (v1,v2) pow 2 = v12
	   
 ==> &0 <= ups_x v01 v02 v12`,
	   
ONCE_REWRITE_TAC[EQ_SYM_EQ] THEN 
	   
SIMP_TAC[UPS_X_AND_HERON] THEN 
	   
DISCH_TAC THEN 
	   
MATCH_MP_TAC REAL_LE_MUL THEN 
	   
SIMP_TAC[DIST_POS_LE; REAL_LE_ADD] THEN 
	   
MATCH_MP_TAC REAL_LE_MUL THEN 
	   
CONJ_TAC THENL [
	   
MESON_TAC[ONCE_REWRITE_RULE[REAL_ARITH` a <= b + c <=> &0 <= b + c - a `]
	   
    DIST_TRIANGLE; DIST_SYM; DIST_POS_LE];
	   
MATCH_MP_TAC REAL_LE_MUL] THEN 
	   
MESON_TAC[ONCE_REWRITE_RULE[REAL_ARITH` a <= b + c <=> &0 <= b + c - a `]
	   
    DIST_TRIANGLE; DIST_SYM; DIST_POS_LE]);;
	   

	   

	   
let DIST_TRANSABLE = prove(` dist ( a - v0, b ) = dist ( a , b + v0 ) `,
	   
REWRITE_TAC[dist; VECTOR_ARITH` a - v0 - b = (a:real^N) - ( b + v0 ) `]);;
	   

	   
prove(` v2 - v0 = va /\
	   
 v3 - v0 = vb ==> dist (va,vb) = dist ( v2,v3) `,
	   
ONCE_REWRITE_TAC[EQ_SYM_EQ] THEN 
	   
SIMP_TAC[DIST_TRANSABLE; VECTOR_ARITH` a - b + b = ( a:real^N)`]);;
	   
let REAL_LE_SQUARE_POW = 
MESON[REAL_POW_2; REAL_LE_SQUARE]`! x. &0 <= x pow 2 `;;
	  
 
g ` dist ((v0:real^N),v1) pow 2 = v01 /\
	   
 dist (v0,v2) pow 2 = v02 /\
	   
 dist (v0,v3) pow 2 = v03 /\
	   
 dist (v1,v2) pow 2 = v12 /\
	   
 dist (v1,v3) pow 2 = v13 /\
	   
 dist (v2,v3) pow 2 = v23 /\
	   
 ~collinear {v0, v1, v2} /\
	   
 ~collinear {v0, v1, v3}
	   
 ==> (let va = v2 - v0 in
	   
      let vb = v3 - v0 in
	   
      let vc = v1 - v0 in
	   
      let vap = (vc dot vc) % va - (va dot vc) % vc in
	   
      let vbp = (vc dot vc) % vb - (vb dot vc) % vc in
	   
            (((vap - vec 0) dot (vbp - vec 0)) /
	   
       (norm (vap - vec 0) * norm (vbp - vec 0)))) =
	   
          (delta_x4 v01 v02 v03 v23 v13 v12 /
	   
      sqrt (ups_x v01 v02 v12 * ups_x v01 v03 v13))`;;
	   
e (REPEAT LET_TAC THEN STRIP_TAC);;
	   
e (EXPAND_TAC "vap" THEN EXPAND_TAC "vbp");;
	   
e (ONCE_REWRITE_TAC[MESON[NORM_POS_LE; POW_2_SQRT]` norm x = sqrt ( norm x pow 2 ) `] THEN 
	   
REWRITE_TAC[MESON[REAL_LE_POW_2; SQRT_MUL]` sqrt ( x pow 2 ) * 
	   
  sqrt ( y pow 2 ) = sqrt ( x pow 2 * y pow 2 ) `]);;
	   
e (SIMP_TAC[VECTOR_SUB_RZERO; COMPUTE_NORM_POW2 ] THEN 
	   
REWRITE_TAC[GSYM (MESON[NORM_POS_LE; POW_2_SQRT]` norm x = sqrt ( norm x pow 2 ) `)] THEN 
	   
REWRITE_TAC[DIST_REFL; REAL_SUB_RZERO; REAL_ARITH` &0 pow 2 = &0`] THEN 
	   
EXPAND_TAC "va" THEN EXPAND_TAC "vb" THEN 
	   
EXPAND_TAC "vc" THEN SIMP_TAC[VECTOR_ARITH` a - b - (c - b ) = a -(c:real^N)`; GSYM dist] THEN 
	   
FIRST_X_ASSUM MP_TAC);;
	   
e (NHANH (MESON[COLLINEAR_2; INSERT_INSERT]` ~ collinear {a,b,c} 
	   
  ==> ~( a = b ) `) THEN REWRITE_TAC[DIST_NZ] THEN 
	   
NHANH (REAL_FIELD` &0 < a ==> &1 = ( &1 / &4 * (a pow 2 ))/ ( &1 / &4 * (a pow 2 )) `) THEN 
	   
ONCE_REWRITE_TAC[MESON[REAL_MUL_LID]` l ==> a = b <=> l ==> a 
	   
  = &1 * b `]);;
	   
e (ABBREV_TAC ` as = (&1 / &4 * dist ((v0:real^N),v1) pow 2 ) ` THEN 
	   
SIMP_TAC[REAL_FIELD` a / b * aa / bb = ( a * aa ) / ( b * bb ) `] THEN 
	   
STRIP_TAC THEN MATCH_MP_TAC (MESON[]` a = aa /\ b = bb ==>
	   
  a /  b = aa / bb `));;
	   
e (CONJ_TAC THENL [ SIMP_TAC[GSYM NORM_POW_2; GSYM dist] THEN 
	   
ASM_SIMP_TAC[] THEN 
	   
SIMP_TAC[DIST_SYM; DOT_LSUB; DOT_RSUB; DOT_LMUL; DOT_RMUL] THEN 
	   
SIMP_TAC[DOT_NORM_NEG] THEN EXPAND_TAC "va" THEN 
	   
EXPAND_TAC "vb" THEN EXPAND_TAC "vc" THEN 
	   
REWRITE_TAC[ VECTOR_ARITH` a - b - ( c - b ) = a - (c:real^N)`] THEN 
	   
REWRITE_TAC[GSYM dist] THEN EXPAND_TAC "as" THEN 
	   
UNDISCH_TAC `&1 / &4 * dist ((v0:real^N),v1) pow 2 = as` THEN 
	   
FIRST_X_ASSUM MP_TAC THEN PHA THEN 
	   
MATCH_MP_TAC (MESON[]` a ==> b ==> a `) THEN 
	   
ASM_SIMP_TAC[DIST_SYM; DIST_REFL; delta_x4] THEN 
	   
REAL_ARITH_TAC; UNDISCH_TAC`&1 / &4 * dist ((v0:real^N),v1) pow 2 = as`]
	   
THEN MP_TAC (SPEC ` dist ((v0:real^N),v1)` REAL_LE_POW_2) THEN 
	   
PHA THEN NHANH (REAL_ARITH `&0 <= a /\ &1 / &4 * a = as ==> &0 <= as `) THEN 
	   
REWRITE_TAC[MESON[POW_2_SQRT]` da /\ &0 <= a ==>  p1 = a * p2 <=>
	   
  da /\ &0 <= a ==> p1 = sqrt ( a pow 2 ) * p2  `] THEN DOWN_TAC THEN 
	   
NHANH (MESON[UPS_X_POS; DIST_SYM ]`dist (v0,v1) pow 2 = v01 /\
	   
 dist (v0,v2) pow 2 = v02 /\ dist (v0,v3) pow 2 = v03 /\
	   
 dist (v1,v2) pow 2 = v12 /\ dist (v1,v3) pow 2 = v13 /\
	   
 dist (v2,v3) pow 2 = v23 /\ l ==> &0 <= ups_x v01 v02 v12 
	   
  /\ &0 <= ups_x v01 v03 v13 `) THEN NHANH (REAL_LE_MUL));;

e (SIMP_TAC[REAL_LE_SQUARE_POW; GSYM SQRT_MUL] THEN 
	   
STRIP_TAC THEN MATCH_MP_TAC (MESON[]` a = b ==> p a = p b `) THEN 
	   
REPLICATE_TAC 6 (FIRST_X_ASSUM MP_TAC) THEN 
	   
ONCE_REWRITE_TAC[EQ_SYM_EQ] THEN 
	   
REPEAT STRIP_TAC THEN ASM_SIMP_TAC[DIST_SYM] THEN DOWN_TAC THEN 
	   
NHANH (MESON[prove(` v2 - v0 = va /\
	   
 v3 - v0 = vb ==> dist (va,vb) = dist ( v2,v3) `,
	   
ONCE_REWRITE_TAC[EQ_SYM_EQ] THEN 
	   
SIMP_TAC[DIST_TRANSABLE; VECTOR_ARITH` a - b + b = ( a:real^N)`]); DIST_SYM]`
	   
 v2 - v0 = va /\ v3 - v0 = vb /\
	   
 v1 - v0 = vc /\ l ==> dist (va,vb ) = dist (v2,v3) /\ dist (vb,vc) =
	   
dist(v1,v3) /\ dist (va,vc) = dist (v1,v2)`) THEN SIMP_TAC[ups_x] THEN 
	   
STRIP_TAC THEN REAL_ARITH_TAC);;
let PROVE_DELTA_OVER_SQRT_2UPS = top_thm();;
	   

	   

	   

	   
let FOR_LEMMA19 = prove(`!(v0:real^N) v1 v2 v3.
	   
     let ga = dihV v0 v1 v2 v3 in
	   
     let v01 = dist (v0,v1) pow 2 in
	   
     let v02 = dist (v0,v2) pow 2 in
	   
     let v03 = dist (v0,v3) pow 2 in
	   
     let v12 = dist (v1,v2) pow 2 in
	   
     let v13 = dist (v1,v3) pow 2 in
	   
     let v23 = dist (v2,v3) pow 2 in
	   
     ~collinear {v0, v1, v2} /\ ~collinear {v0, v1, v3}
	   
     ==> ga =
	   
         acs
	   
         (delta_x4 v01 v02 v03 v23 v13 v12 /
	   
          sqrt (ups_x v01 v02 v12 * ups_x v01 v03 v13))`,
REPEAT STRIP_TAC THEN REPEAT LET_TAC THEN EXPAND_TAC "ga" THEN 
SIMP_TAC[dihV; arcV] THEN REPEAT LET_TAC THEN REPEAT STRIP_TAC THEN 
MATCH_MP_TAC (MESON[]` a = b ==> p a = p b `) THEN MP_TAC 
PROVE_DELTA_OVER_SQRT_2UPS THEN REPEAT LET_TAC THEN
ASM_MESON_TAC[]);;
	   

	   

	   
let COMPUTE_DELTA_OVER = prove(`dist ((v0:real^N),v1) pow 2 = v01 /\
	   
 dist (v0,v2) pow 2 = v02 /\
	   
 dist (v0,v3) pow 2 = v03 /\
	   
 dist (v1,v2) pow 2 = v12 /\
	   
 dist (v1,v3) pow 2 = v13 /\
	   
 dist (v2,v3) pow 2 = v23 /\
	   
 ~collinear {v0, v1, v2} /\
	   
 ~collinear {v0, v1, v3}
	   
 ==> ((((v1 - v0) dot (v1 - v0)) % (v2 - v0) -
	   
       ((v2 - v0) dot (v1 - v0)) % (v1 - v0)) dot
	   
      (((v1 - v0) dot (v1 - v0)) % (v3 - v0) -
	   
       ((v3 - v0) dot (v1 - v0)) % (v1 - v0))) /
	   
     (norm
	   
      (((v1 - v0) dot (v1 - v0)) % (v2 - v0) -
	   
       ((v2 - v0) dot (v1 - v0)) % (v1 - v0)) *
	   
      norm
	   
      (((v1 - v0) dot (v1 - v0)) % (v3 - v0) -
	   
       ((v3 - v0) dot (v1 - v0)) % (v1 - v0))) =
	   
     delta_x4 v01 v02 v03 v23 v13 v12 /
	   
     sqrt (ups_x v01 v02 v12 * ups_x v01 v03 v13)`,
	   
MP_TAC PROVE_DELTA_OVER_SQRT_2UPS THEN REWRITE_TAC[VECTOR_ARITH` a -  vec 0 = a `]
	   
THEN LET_TR THEN SIMP_TAC[]);;
	   

	   

	   

	   


	   

	   

	   
let POS_COMPATIBLE_WITH_ATN2 = prove(` &0 < a ==> atn2 (x,y) = atn2 (a * x,a * y)`,
	   
SIMP_TAC[atn2; REAL_FIELD` &0 < a ==> ( a * b ) / (a * c ) = b / c `] THEN 
	   
SIMP_TAC[ABS_MUL] THEN REWRITE_TAC[REAL_ARITH` a * y < &0 <=> &0 < a * ( -- y )`;
	   
REAL_ARITH` b < &0 <=> &0 < -- b `] THEN 
	   
SIMP_TAC[ABS_MUL; LT_IMP_ABS_REFL; REAL_LT_LMUL_EQ; REAL_LT_MUL_EQ]);;
	   

	   

	   

	   

	   

	   
(* need to be proved *)
	   
let NOT_COLLINEAR_IMP_UPS_LT = new_axiom `
	   
~( collinear {(v0:real^N),v1,v2} ) ==>
	   
let v01 = dist (v0,v1) pow 2 in
	   
let v02 = dist (v0,v2) pow 2 in
	   
let v12 = dist (v1,v2) pow 2 in
	   
 &0 < ups_x v01 v02 v12 `;;
	   

	   
(* Jason have proved the following lemma in the first half
of this file *)
let acs_atn2_t = `!y. (-- &1 <= y /\ y <=  &1) ==> (acs y = pi/(&2) - atn2(sqrt(&1 - y pow 2),y))`;;
let acs_atn2 = new_axiom acs_atn2_t;;
	   
	   
let REAL_LT_DIV_0 = prove(` ! a b. &0 < b ==> ( &0 < a / b <=> &0 < a ) `,
REPEAT STRIP_TAC THEN EQ_TAC THENL
[ASSUME_TAC (UNDISCH (SPEC `b:real` REAL_LT_IMP_NZ)) THEN 
ASM_MESON_TAC[REAL_LT_MUL; REAL_DIV_LMUL];
ASM_SIMP_TAC[REAL_LT_DIV]]);;

	   
let REAL_LE_RDIV_0 = prove(` ! a b. &0 < b ==> ( &0 <= a / b <=> &0 <= a ) `,
REWRITE_TAC[REAL_ARITH ` &0 <= a <=> &0 < a \/ a = &0 `] THEN 
SIMP_TAC[REAL_LT_DIV_0] THEN 
SIMP_TAC[REAL_FIELD `&0 < b ==> ( a / b = &0 <=> a = &0 ) `]);;
	   

let POW_2 = REAL_POW_2;;   

	   
let NOT_ZERO_EQ_POW2_LT = prove(` ~( a = &0 ) <=> &0 < a pow 2 `,
	   
SIMP_TAC[GSYM LE_AND_NOT_0_EQ_LT; POW_2; 
	   
REAL_ENTIRE; REAL_LE_SQUARE]);;
	   




(* lemma 18 *)
	   
let OJEKOJF = prove(`!(v0:real^N) v1 v2 v3.
	   
     let ga = dihV v0 v1 v2 v3 in
	   
     let v01 = dist (v0,v1) pow 2 in
	   
     let v02 = dist (v0,v2) pow 2 in
	   
     let v03 = dist (v0,v3) pow 2 in
	   
     let v12 = dist (v1,v2) pow 2 in
	   
     let v13 = dist (v1,v3) pow 2 in
	   
     let v23 = dist (v2,v3) pow 2 in
	   
     ~collinear {v0, v1, v2} /\ ~collinear {v0, v1, v3}
	   
     ==> ga =
	   
         acs
	   
         (delta_x4 v01 v02 v03 v23 v13 v12 /
	   
          sqrt (ups_x v01 v02 v12 * ups_x v01 v03 v13)) /\
	   
ga = pi / &2 - atn2( sqrt ( &4 * v01 * delta_x v01 v02 v03 v23 v13 v12 ),
	   
delta_x4 v01 v02 v03 v23 v13 v12 ) `, REPEAT STRIP_TAC THEN 
	   
MP_TAC (SPEC_ALL FOR_LEMMA19 ) THEN REPEAT LET_TAC THEN 
	   
SIMP_TAC[] THEN DOWN_TAC THEN NGOAC THEN REWRITE_TAC[MESON[]`l/\ ( a ==> b ) <=>
	   
  ( a ==> b ) /\ l `] THEN PHA THEN NHANH (COMPUTE_DELTA_OVER ) THEN 
	   
NHANH (ONCE_REWRITE_RULE[GSYM CONTRAPOS_THM] ALLEMI_COLLINEAR) THEN 
	   
ONCE_REWRITE_TAC[GSYM VECTOR_SUB_EQ] THEN 
	   
ABBREV_TAC ` (w1:real^N) = ((v1 - v0) dot (v1 - v0)) % (v2 - v0) -
	   
     ((v2 - v0) dot (v1 - v0)) % (v1 - v0)` THEN 
	   
ABBREV_TAC ` (w2:real^N) = ((v1 - v0) dot (v1 - v0)) % (v3 - v0) -
	   
   ((v3 - v0) dot (v1 - v0)) % (v1 - v0) ` THEN 
	   
ONCE_REWRITE_TAC[MESON[]`( a/\ b ) /\ c /\ d <=>
	   
  a /\ c /\ b /\ d `] THEN NHANH (NOT_VEC0_IMP_LE1) THEN PHA THEN 
	   
REWRITE_TAC[MESON[]` P a /\ a = b <=> a = b /\ P b `] THEN 
	   
SIMP_TAC[REAL_ABS_BOUNDS; acs_atn2; REAL_ARITH ` a - x = 
	   
  a - y <=> x = y `] THEN NHANH (NOT_COLLINEAR_IMP_UPS_LT ) THEN 
	   
LET_TR THEN PHA THEN NHANH (MESON[REAL_LT_MUL]` &0 < x /\ a1 /\ &0 < y /\ a2 ==>
	   
  &0 < x * y `) THEN STRIP_TAC THEN FIRST_X_ASSUM MP_TAC THEN 
	   
ASM_SIMP_TAC[] THEN NHANH SQRT_POS_LT THEN 
	   
SIMP_TAC[MESON[POS_COMPATIBLE_WITH_ATN2]` &0 < a ==> 
	   
  atn2 ( x, y / a ) = atn2 ( a * x , a * ( y / a ) ) `] THEN 
	   
SIMP_TAC[REAL_FIELD` &0 < a ==> a * ( y / a ) = y `] THEN 
	   
REPLICATE_TAC 2 (FIRST_X_ASSUM MP_TAC) THEN 
	   
PHA THEN NGOAC THEN REWRITE_TAC[GSYM REAL_ABS_BOUNDS] THEN 
	   
ONCE_REWRITE_TAC[GSYM ABS_1] THEN 
	   
SIMP_TAC[REAL_LE_SQUARE_ABS; REAL_ARITH` a <= &1 <=>
	   
  &0 <= &1 - a `; REAL_ARITH` ( &1 ) pow 2 = &1 `; ABS_1] THEN 
	   
DAO THEN ONCE_REWRITE_TAC[GSYM IMP_IMP] THEN 
	   
SIMP_TAC[REAL_FIELD` &0 < a ==> &1 - ( b / a ) pow 2
	   
  = ( a pow 2 - b pow 2 ) / ( a pow 2 ) `] THEN 
	   
NHANH (REAL_LT_IMP_NZ) THEN NHANH (REAL_LT_IMP_LE) THEN 
	   
SIMP_TAC[NOT_ZERO_EQ_POW2_LT; REAL_LE_RDIV_0 ; SQRT_DIV] THEN 
	   
NHANH (REAL_LT_IMP_LE) THEN SIMP_TAC[SQRT_DIV; REAL_LE_POW2] THEN 
	   
SIMP_TAC[SQRT_DIV; REAL_LE_POW2; POW_2_SQRT; REAL_FIELD` &0 < a ==>
	   
a * b / a = b `] THEN REPEAT STRIP_TAC THEN MATCH_MP_TAC 
	   
(MESON[]` a = b ==> atn2 ( sqrt a, c )  = atn2 ( sqrt b, c ) `) THEN 
	   
ASM_SIMP_TAC[SQRT_WORKS; ups_x; delta_x4; delta_x] THEN 
	   
REAL_ARITH_TAC);;
	   

	   

	   

	   

	   

	   
let LEMMA16_INTERPRETE = prove(`!(v0: real^N) va vb vc.
	   
          ~collinear {v0, vc, va} /\ ~collinear {v0, vc, vb}
	   
          ==> cos (dihV v0 vc va vb) =
	   
              (cos (arcV v0 va vb) -
	   
               cos (arcV v0 vc vb) * cos (arcV v0 vc va)) /
	   
              (sin (arcV v0 vc vb) * sin (arcV v0 vc va))`,
	   
MP_TAC RLXWSTK THEN REPEAT LET_TAC THEN SIMP_TAC[]);;
	   

	   

	   

	   
let NOT_COLLINEAR_IMP_VEC_FOR_DIHV = ONCE_REWRITE_RULE[GSYM VECTOR_SUB_EQ] 
	   
(ONCE_REWRITE_RULE[GSYM CONTRAPOS_THM] ALLEMI_COLLINEAR);;
	   

	   
let ACS = ACS_BOUNDS;;
	   
let NOT_COLLINEAR_IMP_DIHV_BOUNDED = prove(
` ~( collinear {v0,v1,v2} ) /\ ~( collinear {v0,v1,v3} ) 
==> &0 <= dihV v0 v1 v2 v3 /\ dihV v0 v1 v2 v3 <= pi`,
REWRITE_TAC[dihV; arcV] THEN REPEAT LET_TAC THEN 	   
NHANH (NOT_COLLINEAR_IMP_VEC_FOR_DIHV ) THEN 	   
ASM_SIMP_TAC[VECTOR_SUB_RZERO] THEN 	   
ONCE_REWRITE_TAC[MESON[]` ( a/\b) /\c /\d <=>	   
  a /\c/\b/\d`] THEN NHANH (NOT_VEC0_IMP_LE1) THEN 
SIMP_TAC[REAL_ABS_BOUNDS; ACS]) ;;
	   

	   

	   

	   
let DIHV_FORMULAR = prove(` dihV v0 v1 v2 v3 = arcV (vec 0)
	   
 (((v1 - v0) dot (v1 - v0)) % (v2 - v0) -
	   
  ((v2 - v0) dot (v1 - v0)) % (v1 - v0))
	   
 (((v1 - v0) dot (v1 - v0)) % (v3 - v0) -
	   
  ((v3 - v0) dot (v1 - v0)) % (v1 - v0)) `, REWRITE_TAC[dihV]
	   
THEN REPEAT LET_TAC THEN REWRITE_TAC[]);;

	   

	   
let COS_POW2_INTER = prove(` cos x pow 2 = &1 - sin x pow 2 `,
	   
MP_TAC (SPEC_ALL SIN_CIRCLE) THEN REAL_ARITH_TAC);;
	   

	   
(* lemma 19 *)
	   
let ISTYLPH = prove(` ! (v0:real^N) v1 v2 v3. 
	   
  &0 <= cos (arcV (v0:real^N) v2 v3) /\
	   
  dihV v0 v3 v1 v2 = pi / &2 /\
	   
  ~ collinear {v0,v1,v2} /\
	   
  ~ collinear {v0,v1,v3} /\
	   
  ~ collinear {v0,v2,v3} /\
	   
  psi = arcV v0 v2 v3 /\
	   
  tte = arcV v0 v1 v2 ==>
	   
   dihV v0 v1 v2 v3  = beta psi tte `,
	   
REPEAT GEN_TAC THEN 
	   
ONCE_REWRITE_TAC[MESON[]` a /\ b ==> c <=>
	   
  a ==> b ==> c `] THEN 
	   
DISCH_TAC THEN 
	   
ONCE_REWRITE_TAC[SET_RULE` {a,b} = {b,a} `] THEN 
	   
REWRITE_TAC[ MESON[]` a /\ b /\ c /\ d /\ e <=>
	   
  a /\ b /\ (c /\ d )/\ e`] THEN 
	   
NHANH (LEMMA16_INTERPRETE ) THEN 
	   
PURE_ONCE_REWRITE_TAC[MESON[]` a = b /\ P a <=> a = b
	   
  /\ P b `] THEN 
	   
SIMP_TAC[COS_PI2] THEN 
	   
NHANH (NOT_COLLINEAR_IMP_NOT_SIN0) THEN 
	   
PHA THEN 
	   
ONCE_REWRITE_TAC[MESON[REAL_ENTIRE]`~( a = &0 ) /\ a1 /\ ~( b = &0 ) /\ &0 = l /\ ll
	   
  <=> a1 /\ ~ ( b * a = &0 ) /\ &0 = l /\ ll`] THEN 
	   
ONCE_REWRITE_TAC[SET_RULE` {a,b} = {b,a} `] THEN 
	   
ONCE_REWRITE_TAC[MESON[]`a /\ ~( aa = &0 ) /\ b /\ c <=>
	   
  ~( aa = &0 ) /\ c /\ a /\ b `] THEN 
	   
ABBREV_TAC `TU = sin (arcV v0 v3 v2) * sin (arcV v0 v3 (v1:real^N))` THEN 
	   
ABBREV_TAC `MA = (cos (arcV v0 v1 v2) - cos (arcV v0 v3 v2) * cos (arcV v0 v3 (v1:real^N)))` THEN 
	   
NHANH (MESON[REAL_FIELD`~( b = &0 ) /\ a / b = &0 ==> a = &0 `]`
	   
  ~(TU = &0) /\
	   
  &0 = MA / TU /\ ll ==> MA = &0 `) THEN 
	   
REWRITE_TAC[dihV;beta; arcV] THEN 
	   
REPEAT LET_TAC THEN 
	   
STRIP_TAC THEN 
	   
MATCH_MP_TAC (MESON[]` a = b ==> P a = P b `) THEN 
	   
REPLICATE_TAC 2 (FIRST_X_ASSUM MP_TAC) THEN 
	   
NHANH ( NOT_COLLINEAR_IMP_VEC_FOR_DIHV ) THEN 
	   
ASM_SIMP_TAC[] THEN 
	   
PHA THEN ONCE_REWRITE_TAC[EQ_SYM_EQ] THEN 
	   
SIMP_TAC[GSYM NOT_EQ_IMPCOS_ARC] THEN 
	   
DOWN_TAC THEN 
	   
ONCE_REWRITE_TAC[EQ_SYM_EQ] THEN 
	   
SIMP_TAC[] THEN 
	   
STRIP_TAC THEN 
	   
EXPAND_TAC "va" THEN 
	   
EXPAND_TAC "vb" THEN 
	   
EXPAND_TAC "vc" THEN 
	   
UNDISCH_TAC `vb' = v2 - (v0:real^N)` THEN 
	   
UNDISCH_TAC `va' = v1 - (v0:real^N)` THEN 
	   
UNDISCH_TAC `vc' = v3 - (v0:real^N)` THEN 
	   
PHA THEN SIMP_TAC[GSYM DIHV_FORMULAR] THEN 
	   
ASM_SIMP_TAC[LEMMA16_INTERPRETE] THEN 
	   
DISCH_TAC THEN 
	   
UNDISCH_TAC `&0 = MA ` THEN 
	   
ASM_SIMP_TAC[REAL_ARITH` &0 = a - b <=> a = b `; ARC_SYM;
	   
  REAL_ARITH` a * b * a = b * a pow 2 `] THEN 
	   
SIMP_TAC[COS_POW2_INTER; REAL_SUB_LDISTRIB; REAL_MUL_RID;
	   
  REAL_ARITH` a - ( a - b ) = b `] THEN 
	   
UNDISCH_TAC `~collinear {v0, v1,(v3:real^N)}` THEN 
	   
NHANH (NOT_COLLINEAR_IMP_NOT_SIN0) THEN 
	   
PHA THEN SIMP_TAC[REAL_FIELD` ~( a = &0 ) ==>
	   
  ( b * a pow 2) / ( a * c ) = (b * a) / c `] THEN 
	   
UNDISCH_TAC` ~collinear {v0, v1, (v2:real^N)}` THEN 
	   
NHANH (NOT_COLL_IM_SIN_LT) THEN 
	   
NHANH (REAL_LT_IMP_LE) THEN 
	   
UNDISCH_TAC `&0 <= cos (arcV v0 v2 (v3:real^N))` THEN 
	   
PHA THEN 
	   
NHANH (MESON[REAL_LE_MUL; REAL_LE_DIV]`
	   
  &0 <= a1 /\aa /\aa1/\
	   
 &0 <= a3 /\aa2/\aa3/\
	   
 &0 <= a2 /\ lll ==> &0 <= ( a1 * a2 )/ a3 `) THEN 
	   
STRIP_TAC THEN 
	   
FIRST_X_ASSUM MP_TAC THEN 
	   
SIMP_TAC[MESON[POW_2_SQRT]`&0 <= a ==> ( a = b 
	   
  <=> sqrt ( a pow 2 ) = b )`] THEN 
	   
STRIP_TAC THEN 
	   
MATCH_MP_TAC (MESON[]` a = b ==> P a = P b `) THEN 
	   
EXPAND_TAC "psi" THEN 
	   
EXPAND_TAC "tte" THEN 
	   
UNDISCH_TAC `va' = (vc:real^N)` THEN 
	   
UNDISCH_TAC `vb' = (va:real^N)` THEN 
	   
UNDISCH_TAC `vc' = (vb:real^N)` THEN 
	   
UNDISCH_TAC ` vb = v3 - v0 /\ vc = v1 - v0 /\ va = v2 - (v0 :real^N)` THEN 
	   
PHA THEN SIMP_TAC[GSYM arcV] THEN 
	   
STRIP_TAC THEN 
	   
SIMP_TAC[REAL_FIELD` ( a / b ) pow 2 = a pow 2 / b pow 2 `] THEN 
	   
MATCH_MP_TAC (MESON[]` a = b /\ aa = bb ==> a / aa 
	   
  = b / bb `) THEN 
	   
SIMP_TAC[SIN_POW2_EQ_1_SUB_COS_POW2; GSYM POW_2] THEN 
	   
SIMP_TAC[REAL_ARITH`(A * B ) pow 2 = A pow 2 * 
	   
  B pow 2 `; SIN_POW2_EQ_1_SUB_COS_POW2] THEN 
	   
ASM_SIMP_TAC[] THEN REAL_ARITH_TAC);;
	   

	   

	   

	   

	 
  

	   

	   

	   

	   

	   

	   

	   

	   

	   

	   

	   

	   

	   
let INTERS_SUBSET = SET_RULE` P a ==> INTERS { x | P x } SUBSET a `;;
	   

	   
let AFFINE_SET_GENERARTED2 = prove(` affine {x | ? t. x = t % u + ( &1 - t ) % v }  `,
	   
REWRITE_TAC[affine; IN_ELIM_THM] THEN REPEAT STRIP_TAC THEN 
	   
EXISTS_TAC `t * u' + (t':real) * v'` THEN FIRST_X_ASSUM MP_TAC THEN 
	   
SIMP_TAC[REAL_ARITH` a + b = c <=> a = c - b `] THEN 
	   
DISCH_TAC THEN ASM_SIMP_TAC[] THEN CONV_TAC VECTOR_ARITH);;
	   

	   
let BASED_POINT2 = prove(` {(u:real^N),v} SUBSET {x | ? t. x = t % u + ( &1 - t ) % v } `,
	   
SIMP_TAC[INSERT_SUBSET; EMPTY_SUBSET; IN_ELIM_THM] THEN CONJ_TAC THENL 
	   
[EXISTS_TAC ` &1 ` THEN CONV_TAC VECTOR_ARITH; EXISTS_TAC ` &0 `] THEN 
	   
CONV_TAC VECTOR_ARITH);;
	   

	   
let AFFINE_AFF = prove(` affine ( aff s ) `,
	   
SIMP_TAC[aff; AFFINE_AFFINE_HULL]);;
	   

	   
let INSERT_EMPTY_SUBSET = prove(`(x INSERT s SUBSET t <=> x IN t /\ s SUBSET t)
	   
/\ (!s. {} SUBSET s)`, SIMP_TAC[INSERT_SUBSET; EMPTY_SUBSET]);;
	   

	   

	   

	   
let IN_P_HULL_INSERT = prove(`a IN P hull (a INSERT s)`, 
	   
MATCH_MP_TAC (SET_RULE` a IN A /\ A SUBSET P hull A ==> a IN P hull A `) THEN 
	   
SIMP_TAC[IN_INSERT; HULL_SUBSET]);;
	   

	   
let UV_IN_AFF2 = MESON[INSERT_AC;IN_P_HULL_INSERT  ]` 
	   
u IN affine hull {u,v}/\ v IN affine hull {u,v}`;;
	   

	   

	   
let AFF2 = prove(` ! u (v:real^N). aff {u,v} = {x | ? t. x =  t % u + ( &1 - t ) % v } `,
	   
SIMP_TAC[GSYM SUBSET_ANTISYM_EQ] THEN REPEAT STRIP_TAC THENL 
	   
[SIMP_TAC[aff; hull] THEN MATCH_MP_TAC (INTERS_SUBSET) THEN 
	   
SIMP_TAC[BASED_POINT2 ;AFFINE_SET_GENERARTED2 ]; 
	   
SIMP_TAC[SUBSET; IN_ELIM_THM]] THEN REPEAT STRIP_TAC THEN 
	   
MP_TAC (MESON[AFFINE_AFF]` affine ( aff {u, (v:real^N)})`) THEN 
	   
ASM_SIMP_TAC[aff; affine] THEN
	   
MESON_TAC[UV_IN_AFF2; REAL_RING` a + &1 - a = &1 `]);;
	   

	   

	   
GEN_ALL (SPECL [`p - (v0:real^N)`;`(u:real^N) - v0 `]
	   
 VECTOR_SUB_PROJECT_ORTHOGONAL);;
	   

	   
SPECL[` (u - (v:real^N))`;` (p:real^N)`] 
	   
VECTOR_SUB_PROJECT_ORTHOGONAL;;
	   

	   

	   
let EXISTS_PROJECTING_POINT = prove(
	   
`! (p:real^N) u v. ? pp. (u + pp ) IN aff {u,v} /\ (p - pp ) dot ( u - v ) = &0 `,
	   
REPEAT STRIP_TAC THEN MP_TAC (SPECL[` (u - (v:real^N))`;` (p:real^N)`]
	   
VECTOR_SUB_PROJECT_ORTHOGONAL) THEN STRIP_TAC THEN 
	   
EXISTS_TAC `((u - v) dot p) / ((u - v) dot (u - v)) % (u - (v:real^N))` THEN 
	   
ONCE_REWRITE_TAC[DOT_SYM] THEN 
	   
CONJ_TAC THENL [SIMP_TAC[AFF2; IN_ELIM_THM; VECTOR_ARITH` a + x % ( a - b ) =
	   
  (&1 + x ) % a + ( &1 - ( &1 + x )) % b `] THEN MESON_TAC[] ;
	   
ASM_MESON_TAC[DOT_SYM]]);;
	   

	   

	   
let UV_IN_AFF2_IMP_TRANSABLE = prove(`! v0 v1 u v.
	   
  u IN aff {v0,v1} /\ v IN aff {v0,v1} ==>
	   
  ( ( u - v0 ) dot ( v1 - v0 )) * ( ( v - v0) dot ( v1 - v0 )) =
	   
  (( v1 - v0 ) dot ( v1 - v0 ) ) * ((u - v0 ) dot ( v - v0 )) `,
	   
REPEAT GEN_TAC THEN REWRITE_TAC[AFF2; IN_ELIM_THM] THEN 
	   
STRIP_TAC THEN ASM_SIMP_TAC[VECTOR_ARITH`(t % v0 + (&1 - t) % v1) - v0
	   
= ( &1 - t ) % ( v1 - v0 )`] THEN SIMP_TAC[DOT_LMUL; DOT_RMUL] THEN
	   
REAL_ARITH_TAC);;
	   

	   
let WHEN_K_POS_ARCV_STABLE = prove(` &0 < k ==>
	   
  arcV ( vec 0 ) u v = arcV ( vec 0 ) u ( k % v ) `,
	   
REWRITE_TAC[arcV; VECTOR_SUB_RZERO; DOT_RMUL; NORM_MUL] THEN 
	   
SIMP_TAC[LT_IMP_ABS_REFL; REAL_FIELD`&0 < a ==> ( a * b ) /
	   
  ( d * a * s ) = b / ( d * s ) `]);;
	   

	   

	   
let ARCV_VEC0_FORM = prove(`arcV v0 u v = arcV (vec 0) (u - v0) (v - v0)`,
	   
REWRITE_TAC[arcV; VECTOR_SUB_RZERO]);;
	   

	   
let WHEN_K_POS_ARCV_STABLE2 = prove(` k < &0  ==>
	   
  arcV ( vec 0 ) u v = arcV ( vec 0 ) u ( ( -- k) % v ) `,
	   
REWRITE_TAC[REAL_ARITH` n < &0 <=> &0 < -- n `;
	   
  WHEN_K_POS_ARCV_STABLE ]);;
	   

	   
let WHEN_K_DIFF0_ARCV = prove(` ~ ( k = &0 ) ==> 
	   
 arcV ( vec 0 ) u v = arcV ( vec 0 ) u ( ( abs k ) % v ) `,
	   
REWRITE_TAC[REAL_ABS_NZ; WHEN_K_POS_ARCV_STABLE ]);;
	   

	   

	   

	   
let PITHAGO_THEOREM = prove(`x dot y = &0
	   
 ==> norm (x + y) pow 2 = norm x pow 2 + norm y pow 2 /\
	   
     norm (x - y) pow 2 = norm x pow 2 + norm y pow 2`,
	   
SIMP_TAC[NORM_POW_2; DOT_LADD; DOT_RADD; DOT_RSUB; DOT_LSUB; DOT_SYM] THEN 
	   
REAL_ARITH_TAC);;
	   

	   

	   
let NORM_SUB_INVERTABLE = NORM_ARITH` norm (x - y) = norm (y - x)`;;
	   

	   

	   

	   
let OTHORGONAL_WITH_COS = prove(` ! v0 v1 w (p:real^N). 
	   
     ~(v0 = w) /\
	   
     ~(v0 = v1) /\
	   
     (w - p) dot (v1 - v0) = &0
	   
     ==> cos (arcV v0 v1 w) = 
	   
((p - v0) dot (v1 - v0)) / (norm (v1 - v0) * norm (w - v0))`,
	   
REPEAT GEN_TAC THEN SIMP_TAC[NOT_EQ_IMPCOS_ARC] THEN 
	   
REPEAT STRIP_TAC THEN 
	   
MATCH_MP_TAC (MESON[]` a = b ==> a / c = b / c `) THEN 
	   
ONCE_REWRITE_TAC[REAL_RING` a = b <=> a - b = &0 `] THEN 
	   
ONCE_REWRITE_TAC[MESON[DOT_SYM]` a dot b - c = b dot a - c `] THEN 
	   
FIRST_X_ASSUM MP_TAC THEN SIMP_TAC[GSYM DOT_LSUB; VECTOR_ARITH` 
	   
w - v0 - (p - v0) = w - (p:real^N)`; REAL_SUB_RZERO; DOT_SYM]);;
	   

	   

	   
let SIMPLIZE_COS_IF_OTHOR = prove(` ! v0 v1 w (p:real^N). 
	   
     ~(v0 = w) /\
	   
     ~(v0 = v1) /\ ( p - v0 ) = k % (v1 - v0 ) /\
	   
     (w - p) dot (v1 - v0) = &0
	   
     ==> cos (arcV v0 v1 w) = 
	   
k * norm ( v1 - v0 ) / norm (w - v0) `,
	   
SIMP_TAC[OTHORGONAL_WITH_COS; DOT_LMUL; GSYM NORM_POW_2] THEN 
	   
REPEAT STRIP_TAC THEN ONCE_REWRITE_TAC[EQ_SYM_EQ] THEN 
	   
ONCE_REWRITE_TAC[GSYM VECTOR_SUB_EQ] THEN REWRITE_TAC[GSYM NORM_POS_LT]
	   
THEN CONV_TAC REAL_FIELD);;
	   

	   

	   
let SIN_EQ_SQRT_ONE_SUB = prove(` ~((v0:real^N) = va) /\ ~(v0 = vb) ==>
	   
  sin ( arcV v0 va vb ) = sqrt ( &1 - cos ( arcV v0 va vb ) pow 2 ) `,
	   
DISCH_TAC THEN MATCH_MP_TAC (SIN_COS_SQRT) THEN ASM_SIMP_TAC[PROVE_SIN_LE]);;
	   

	   

	   

	   
let SIN_DI_HOC = prove(`~((v0:real^N) = w) /\ ~(v0 = vb) /\ p IN aff {v0, w} /\ (p - vb) dot (w - v0) = &0
	   
 ==> sin (arcV v0 w vb) = norm (p - vb) / norm (vb - v0)`,
	   
SIMP_TAC[SIN_EQ_SQRT_ONE_SUB] THEN ONCE_REWRITE_TAC[REAL_ARITH` a = &0 <=> -- a = &0 `] THEN 
	   
SIMP_TAC[GSYM DOT_LNEG; VECTOR_NEG_SUB; OTHORGONAL_WITH_COS] THEN 
	   
SIMP_TAC[AFF2; IN_ELIM_THM; VECTOR_ARITH` p = t % v0 + (&1 - t) % w
	   
  <=> p - v0 = (&1 - t ) % ( w - v0 ) `] THEN 
	   
STRIP_TAC THEN ASM_SIMP_TAC[DOT_LMUL; GSYM NORM_POW_2] THEN 
	   
ONCE_REWRITE_TAC[MESON[REAL_LE_DIV; POW_2_SQRT; NORM_POS_LE]`
	   
  norm a / norm b = sqrt (( norm a / norm b ) pow 2 ) `] THEN 
	   
MATCH_MP_TAC (MESON[]` a = b ==> p a = p b `) THEN 
	   
UNDISCH_TAC` ~(v0 = (w:real^N))` THEN UNDISCH_TAC`~(v0 = (vb:real^N))` THEN 
	   
ONCE_REWRITE_TAC[VECTOR_ARITH` a = b <=> (b:real^N) - a = vec 0 `] THEN 
	   
SIMP_TAC[ GSYM NORM_POS_LT; REAL_FIELD` &0 < a ==>
	   
  ( c * a pow 2 ) / ( a * b ) = (c * a )/ b /\
	   
&1 - ( b / a ) pow 2 = ( a pow 2 - b pow 2 ) / a pow 2 `] THEN 
	   
REPEAT STRIP_TAC THEN SIMP_TAC[DIV_POW2] THEN 
	   
MATCH_MP_TAC (MESON[]` a = b ==> a / x = b / x `) THEN 
	   
SIMP_TAC[MUL_POW2] THEN ONCE_REWRITE_TAC[MESON[REAL_POW2_ABS]`
	   
 a pow 2 * t = ( abs a ) pow 2 * t`] THEN 
	   
SIMP_TAC[GSYM MUL_POW2; GSYM NORM_MUL] THEN DOWN_TAC THEN 
	   
ONCE_REWRITE_TAC[EQ_SYM_EQ] THEN SIMP_TAC[] THEN 
	   
NHANH (MESON[]` a = b ==> ( vb - (p:real^N)) dot a 
	   
  = ( vb - (p:real^N)) dot b `) THEN 
	   
REWRITE_TAC[DOT_RMUL; MESON[]` ( a /\ x * t = c ) /\
	   
  &0 = t /\ l <=> a /\ c = x * ( &0 )  /\ t = &0 /\ l `;
	   
  REAL_MUL_RZERO] THEN NHANH (PITHAGO_THEOREM) THEN 
	   
SIMP_TAC[VECTOR_ARITH` vb - p + p - v0 = vb - (v0:real^N)`] THEN 
	   
STRIP_TAC THEN SIMP_TAC[NORM_SUB] THEN REAL_ARITH_TAC );;
	   

	   

	   
let CHANG_BIET_GI = prove(`pu - p = (&1 - t) % (w - p) ==> pu IN aff {p, w}`,
	   
REWRITE_TAC[AFF2; IN_ELIM_THM; VECTOR_ARITH`pu - p = (&1 - t) % (w - p) <=>
	   
  pu = t % p + ( &1 - t ) % w `] THEN MESON_TAC[]);;
	   

	   

	   
let SUB_DOT_EQ_0_INVERTALE = prove(` ( a - b ) dot c = &0 <=> ( b - a ) dot c = &0 `,
	   
SIMP_TAC[DOT_LSUB] THEN REAL_ARITH_TAC);;
	   

	   

	   
let SIN_DI_HOC2 = ONCE_REWRITE_RULE[SUB_DOT_EQ_0_INVERTALE] SIN_DI_HOC;;
	   

	   

	   

	   
let KEY_LEMMA_FOR_ANGLES = prove(`! (p:real^N) u v w pu pv. pu IN aff {p,w} /\ pv IN aff {p,w} /\
	   
( u - pu ) dot (w - p ) = &0 /\
	   
( v - pv ) dot (w - p ) = &0  /\
	   
~( p = u \/ p = v \/ p = w ) ==>
	   
cos ( arcV p w u + arcV p w v ) - cos ( arcV p u v ) =
	   
(-- ( v - pv ) dot ( u - pu ) - norm ( v - pv ) * norm ( u - pu )) /
	   
(norm ( p - u ) * norm ( p - v ))`,
	   
SIMP_TAC[COS_ADD; AFF2; IN_ELIM_THM; VECTOR_ARITH` pu = t % p + (&1 - t) % w <=> pu - p = ( &1 - t ) % (w - p ) `;
	   
  DE_MORGAN_THM] THEN 
	   
REPEAT STRIP_TAC THEN 
	   
DOWN_TAC THEN 
	   
NHANH (MESON[SIMPLIZE_COS_IF_OTHOR]` pu - p = (&1 - t) % (w - p) /\
	   
 pv - p = (&1 - t') % (w - p) /\
	   
 (u - pu) dot (w - p) = &0 /\
	   
 (v - pv) dot (w - p) = &0 /\
	   
 ~(p = u) /\
	   
 ~(p = v) /\
	   
 ~(p = w) ==> cos (arcV p w u) = 
	   
  (&1 - t ) * norm (w - p) / norm (u - p) /\
	   
  cos (arcV p w v) =
	   
  ( &1 - t') * norm (w - p ) / norm ( v - p ) `) THEN 
	   
NHANH (CHANG_BIET_GI) THEN 
	   
NHANH (MESON[SIN_DI_HOC2]`(a11 /\ pu IN aff {p, w}) /\
	   
  (a22 /\ pv IN aff {p, w}) /\
	   
  (u - pu) dot (w - p) = &0 /\
	   
  (v - pv) dot (w - p) = &0 /\
	   
  ~(p = u) /\
	   
  ~(p = v) /\
	   
  ~(p = w) ==>
	   
   sin (arcV p w u) = norm ( pu - u ) / norm ( u - p ) /\
	   
  sin (arcV p w v) = norm ( pv - v ) / norm ( v - p ) `) THEN 
	   
STRIP_TAC THEN 
	   
ASM_SIMP_TAC[NOT_EQ_IMPCOS_ARC; REAL_FIELD` a / b * aa / bb 
	   
  = ( a * aa ) / ( b * bb ) `; REAL_RING` (a * b ) * c * d = a * c * b * d `;
	   
  REAL_FIELD` a * b / c = ( a * b ) / c `; REAL_FIELD ` a / b - c / b
	   
  = ( a - c ) / b `; NORM_SUB] THEN 
	   
MATCH_MP_TAC (MESON[]` a = b ==> a / x = b / x `) THEN 
	   
SIMP_TAC[NORM_SUB; REAL_MUL_SYM; REAL_ARITH` a - b - c = v - b <=>
	   
  a - c - v = &0 `] THEN 
	   
REWRITE_TAC[MESON[VECTOR_ARITH` a - b = a - x + x - (b:real^N)`]`
	   
  a - (u - p) dot (v - p) = a - (u - pu + pu - p) dot (v - pv + pv - p) `;
	   
  DOT_LADD; DOT_RADD] THEN 
	   
ASM_SIMP_TAC[DOT_LMUL; DOT_RMUL; DOT_SYM; REAL_MUL_RZERO;
	   
  REAL_ADD_RID; GSYM NORM_POW_2; GSYM POW_2; NORM_SUB;DOT_LNEG; 
	   
REAL_ADD_LID] THEN REAL_ARITH_TAC);;
	 
  

	   

	   

	   

	   
let ARCV_BOUNDED = prove(` ~( v0 = u ) /\ ~ ( v0 = v ) ==>
	   
&0 <= arcV v0 u v /\ arcV v0 u v <= pi`,
	   
NHANH (NOT_IDEN_IMP_ABS_LE) THEN REWRITE_TAC[arcV; REAL_ABS_BOUNDS]
	   
THEN SIMP_TAC[ACS_BOUNDS]);;
	   

	   

	   
(* This lemma in Multivariate/transc.ml *)
	   
let COS_MONO_LT_EQ = new_axiom
	   
`!x y. &0 <= x /\ x <= pi /\ &0 <= y /\ y <= pi
	   
         ==> (cos(x) < cos(y) <=> y < x)`;;
	   

	   

	   

	   
let COS_MONOPOLY = prove(
	   
` ! a b. &0 <= a /\ a <= pi /\ &0 <= b /\ b <= pi ==>
	   
( a < b <=> cos b < cos a ) `, MESON_TAC[COS_MONO_LT_EQ]);;
	   

	   
let COS_MONOPOLY_EQ = prove(
` ! a b. &0 <= a /\ a <= pi /\ &0 <= b /\ b <= pi ==>
( a <= b <=> cos b <= cos a ) `,
REPEAT STRIP_TAC THEN REWRITE_TAC[GSYM REAL_NOT_LT]
THEN ASM_MESON_TAC[COS_MONOPOLY ]);;
	   

	   

	   
let END_POINT_ADD_IN_AFF2 = prove(`!k (u:real^N) v. u + k % (u - v) IN aff {u, v} /\
	   
u + k % (v - u ) IN aff {u,v} `,
	   
REWRITE_TAC[AFF2; VECTOR_ARITH` u + k % (u - v) = 
	   
  ( &1 + k ) % u + ( &1 - ( &1 + k )) % v `] THEN 
	   
SIMP_TAC[VECTOR_ARITH` u + k % (v - u) = 
	   
  (&1 - k) % u + (&1 - (&1 - k)) % v`]  THEN SET_TAC[]);;
	   

	   
let EXISTS_PROJECTING_POINT2 = prove(`!(p:real^N) u v0 . ?pp. pp IN aff {u, v0} /\ (p - pp) dot (u - v0) = &0`,
	   
REPEAT GEN_TAC THEN MP_TAC (SPECL[` u - (v0:real^N) `; `p - ( v0 :real^N)`] 
	   
VECTOR_SUB_PROJECT_ORTHOGONAL) THEN 
	   
SIMP_TAC[DOT_SYM; VECTOR_ARITH` a - b - c = a - ( b + (c:real^N))`] THEN 
	   
ONCE_REWRITE_TAC[INSERT_AC] THEN MESON_TAC[END_POINT_ADD_IN_AFF2 ]);;
	   

	   

	   
let KEY_LEMMA_FOR_ANGLES1 = 
	   
ONCE_REWRITE_RULE[ INSERT_AC] KEY_LEMMA_FOR_ANGLES;;
	   

	   
SPECL[`p:real^N`; `u:real^N`; `v:real^N`;`x:real^N`;`ux:real^N`;`vx:real^N`] 
	   
KEY_LEMMA_FOR_ANGLES1;;
	   

	   
let ARCV_INEQUALTY = prove(`! p u v (x:real^N). ~ ( p = x ) /\ ~( p = u ) /\ ~( p = v )  ==>
	   
arcV p u v <= arcV p u x + arcV p x v `,
	   
NHANH (ARCV_BOUNDED) THEN 
	   
REPEAT GEN_TAC THEN 
	   
ASM_CASES_TAC` pi <= arcV p u x + arcV p x (v:real^N)` THENL 
	   
[ASM_MESON_TAC[REAL_LE_TRANS];
	   
PHA THEN 
	   
NHANH (MESON[ARCV_BOUNDED ]`~(p = x) /\ ~(p = u) /\ ~(p = v) /\ l
	   
  ==> &0 <= arcV p u x /\ &0 <= arcV p x v `) THEN 
	   
NHANH (REAL_LE_ADD) THEN 
	   
DOWN_TAC THEN 
	   
NHANH (REAL_ARITH` ~(a <= b ) ==> b <= a `) THEN 
	   
SIMP_TAC[COS_MONOPOLY_EQ ] THEN 
	   
MP_TAC (MESON[EXISTS_PROJECTING_POINT2]` ? (ux:real^N) vx.
	   
  ux IN aff {x,p} /\ vx IN aff {x,p} /\
	   
  ( u - ux ) dot (x - p ) = &0 /\
	   
  ( v - vx ) dot ( x - p ) = &0 `) THEN 
	   
REPEAT STRIP_TAC THEN 
	   
DOWN_TAC THEN 
	   
REWRITE_TAC[MESON[]` ux IN aff {x, p} /\
	   
 vx IN aff {x, p} /\
	   
 (u - ux) dot (x - p) = &0 /\
	   
 (v - vx) dot (x - p) = &0 /\a11/\a22 /\
	   
 ~(p = x) /\
	   
 ~(p = u) /\
	   
 ~(p = v) /\ l <=> a11 /\ a22 /\ l /\ ux IN aff {x, p} /\
	   
     vx IN aff {x, p} /\
	   
     (u - ux) dot (x - p) = &0 /\
	   
     (v - vx) dot (x - p) = &0 /\
	   
     ~(p = u \/ p = v \/ p = x) `] THEN 
	   
NHANH (SPECL[`p:real^N`; `u:real^N`; `v:real^N`;`x:real^N`;`ux:real^N`;`vx:real^N`] 
	   
KEY_LEMMA_FOR_ANGLES1) THEN 
	   
ONCE_REWRITE_TAC[REAL_ARITH` a <= b <=> a - b <= &0 `] THEN 
	   
SIMP_TAC[ARC_SYM; DE_MORGAN_THM] THEN 
	   
ONCE_REWRITE_TAC[GSYM VECTOR_SUB_EQ] THEN 
	   
SIMP_TAC[GSYM NORM_POS_LT; REAL_FIELD` a / ( b * c ) =  ( a / b) / c `] THEN 
	   
SIMP_TAC[REAL_ARITH` (a/ b ) / c <= &0 <=> &0 <= (( -- a ) / b ) / c `;
	   
  REAL_LE_RDIV_0] THEN 
	   
STRIP_TAC THEN 
	   
REWRITE_TAC[REAL_ARITH`&0 <= -- ( a - b ) <=> a <= b `] THEN 
	   
MESON_TAC[NORM_NEG; NORM_CAUCHY_SCHWARZ]]);;
	   

	   
let KEITDWB = ARCV_INEQUALTY;;
(* June *)

	   
g `! (p:real^N) (n:num) fv.
	   
     2 <= n /\ (!i. i <= n ==> ~(p = fv i))
	   
     ==> arcV p (fv 0) (fv n) <=
	   
         sum (0..n - 1) (\i. arcV p (fv i) (fv (i + 1)))`;;
	   
e (GEN_TAC);;
	   
e (INDUCT_TAC);;
	   
e (SIMP_TAC[ARITH_RULE` ~( 2 <= 0 ) `]);;
	   
e (SPEC_TAC (`n:num`,` a:num`));;
	   
e (INDUCT_TAC);;
	   
e (SIMP_TAC[ONE; ARITH_RULE` ~(2 <= SUC 0) `]);;
	   
e (SPEC_TAC(`a:num`,`u:num`));;
	   
e (INDUCT_TAC);;
	   
e (SIMP_TAC[ARITH_RULE` 2 <= 2 `;ARITH_RULE `SUC ( SUC 0 ) = 2 `  ]);;
	   
e (SIMP_TAC[ARITH_RULE` 0 < 1 /\ 2 - 1 = 1 `;ARITH_RULE` 0 <= 1 `;
	   
  SUM_CLAUSES_RIGHT]);;
	   
e (SIMP_TAC[SUB_REFL; SUM_SING_NUMSEG; ADD; ARITH_RULE` 1 + 1 = 2 `;
	   
  ARITH_RULE` i <= 2 <=> i = 0 \/ i = 1 \/ i = 2 `]);;
	   
e (SIMP_TAC[MESON[]` (! a. a = x \/ a = y \/ a = z ==> Q a ) <=> 
	   
  Q x /\ Q y /\ Q z `]);;
	   
e (MP_TAC ARCV_INEQUALTY );;
	   
e (SIMP_TAC[IN_INSERT; NOT_IN_EMPTY]);;
	   
e (GEN_TAC);;
	   
e (MP_TAC (ARITH_RULE` 2 <= SUC ( SUC u )`));;
	   
e (ABBREV_TAC ` ed = ( SUC (SUC u ))`);;
	   
e (REWRITE_TAC[ADD1; ARITH_RULE` a <= b + 1 <=> a <= b \/
	   
  a = b + 1 `; MESON[]` (! x. p x \/ x = a ==> h x ) <=>
	   
  (! x. p x ==> h x ) /\ h a `]);;
	   
e (PHA);;
	   
e (ONCE_REWRITE_TAC[MESON[]` a /\ b/\ c/\ d <=> b /\ d /\ a /\ c `]);;
	   
e (REPLICATE_TAC 2 (FIRST_X_ASSUM MP_TAC));;
	   
e (PHA);;
	   
e (NHANH (MESON[]`(!fv. 2 <= ed /\ (!i. i <= ed ==> ~(p = fv i))
	   
       ==> Q fv) /\a1 /\a2 /\a3 /\ 2 <= ed /\ (!i. i <= ed ==> ~(p = fv i)) ==> Q fv `));;
	   
e (NHANH (ARITH_RULE` 2 <= d ==> 0 < d - 1 + 1 /\ 0 <= d - 1 + 1 `));;
	   
e (SIMP_TAC[ARITH_RULE` 2 <= a ==> ( a + 1 ) - 1 = a - 1 + 1 `;
	   
  SUM_CLAUSES_RIGHT]);;
	   
e (ASM_SIMP_TAC[ARITH_RULE` (ed - 1 + 1) - 1 = ed - 1 `]);;
	   
e (SIMP_TAC[ARITH_RULE` 2 <= d ==> d - 1 + 1 = d `]);;
	   
e (PHA);;
	   
e (REWRITE_TAC[MESON[ARITH_RULE` 2 = ed + 1 ==> ~( 2 <= ed ) `]`
	   
  ( a \/ 2 = ed + 1) /\ aa /\
	   
 2 <= ed /\ ll <=> a /\ aa /\
	   
 2 <= ed /\ ll `]);;
	   
e (STRIP_TAC THEN FIRST_X_ASSUM MP_TAC);;
	   
e (MATCH_MP_TAC (REAL_ARITH` a <= b + c ==> b <= x ==> a <= x + c `));;
	   
e (FIRST_X_ASSUM MP_TAC);;
	   
e (NHANH (MESON[LE_REFL; LE_0]` (! i. i <= d ==> p i ) ==> p ( 0 ) /\
	   
  p ( d ) `));;
	   
e (MP_TAC (ARCV_INEQUALTY));;
	   
e (ASM_SIMP_TAC[IN_INSERT; NOT_IN_EMPTY]);;
	   
let FGNMPAV = top_thm();;
	   

	   

	   

	   

	   
let IMP_TAC = ONCE_REWRITE_TAC[MESON[]` a/\ b ==> c 
	   
  <=> a ==> b ==> c `];;
	   

	   
g ` &0 <= t12 /\ t12 < &2 * pi /\ t12 = &2 * pi * real_of_int k12 
	   
==> t12 = &0 `;;
	   
e (ASM_CASES_TAC` (k12:int) < &0 `);;
	   
e (MP_TAC (PI_POS));;
	   
e (DOWN_TAC);;
	   
e (SIMP_TAC[GSYM REAL_NEG_GT0; int_lt; int_of_num_th]);;
	   
e (NGOAC THEN NHANH (REAL_LT_MUL));;
	   
e (REWRITE_TAC[REAL_ARITH` &0 < -- a * b <=> &2 * b * a < &0 `]);;
	   
e (MESON_TAC[REAL_ARITH` ~( a < &0 /\ &0 <= a ) `]);;
	   
e (ASM_CASES_TAC `(k12:int) = &0 `);;
	   
e (ASM_SIMP_TAC[int_of_num_th; REAL_MUL_RZERO]);;
	   
e (DOWN_TAC);;
	   
e (NGOAC);;
	   
e (REWRITE_TAC[ARITH_RULE` ~(k12 < &0) /\ ~((k12:int) = &0) <=> &1 <= k12 `]);;
	   
e (SIMP_TAC[int_le; int_of_num_th]);;
	   
e (MP_TAC PI_POS);;
	   
e (PHA);;
	   
e (ONCE_REWRITE_TAC[MESON[REAL_LE_LMUL_EQ]` &0 < pi /\
	   
   &1 <= aa  /\ l <=> &0 < pi /\ pi * &1 <= pi * aa /\ l `]);;
	   
e (REWRITE_TAC[REAL_ARITH` a * &1 <= b <=> &2 * a <= &2 * b `]);;
	   
e (MESON_TAC[REAL_ARITH` ~( a < b /\ b <= a ) `]);;
	   
let IN_A_PERIOD_IDE0 = top_thm();;
	   

	   

	   
let UNIQUE_PROPERTY_IN_A_PERIOD = prove(
	   
`&0 <= t12 /\ t12 < &2 * pi /\ &0 <= a /\  a < &2 * pi /\
	   
t12 = a + &2 * pi * real_of_int k12 ==> t12 = a `,
	   
NHANH (REAL_FIELD` &0 <= t12 /\
	   
 t12 < &2 * pi /\
	   
 &0 <= a /\
	   
 a < &2 * pi  /\ ll ==> t12 + -- a < &2 * pi /\
	   
  -- ( t12 + -- a ) < &2 * pi `) THEN 
	   
ASM_CASES_TAC` &0 <= t12 + -- a ` THENL [
	   
REWRITE_TAC[REAL_ARITH` a = b + c <=> a + -- b = c `] THEN 
	   
STRIP_TAC THEN 
	   
ONCE_REWRITE_TAC[REAL_ARITH` a = b <=> a + -- b = &0 `] THEN 
	   
DOWN_TAC THEN 
	   
MESON_TAC[IN_A_PERIOD_IDE0 ];
	   
SIMP_TAC[REAL_ARITH` a = b + c * d * e <=>
	   
  -- ( a + -- b ) = c * d * ( -- e ) `; GSYM int_neg_th] THEN 
	   
STRIP_TAC THEN 
	   
ONCE_REWRITE_TAC[REAL_ARITH` a = b <=> -- ( a + -- b ) = &0 `] THEN 
	   
DOWN_TAC THEN 
	   
NHANH (REAL_ARITH` ~(&0 <= b ) ==> &0 <= -- b `) THEN 
	   
MESON_TAC[IN_A_PERIOD_IDE0 ]]);;
	   

	   

	   

	   

	   

	   

	   

	 
  

	   
g `!t1 t2 k12 k21.
	   
     &0 <= t1 /\
	   
     t1 < &2 * pi /\
	   
     &0 <= t2 /\
	   
     t2 < &2 * pi /\
	   
     &0 <= t12 /\
	   
     t12 < &2 * pi /\
	   
     &0 <= t21 /\
	   
     t21 < &2 * pi /\
	   
     t12 = t1 - t2 + &2 * pi * real_of_int k12 /\
	   
     t21 = t2 - t1 + &2 * pi * real_of_int k21
	   
     ==> (t1 = t2 ==> t12 + t21 = &0) /\ (~(t1 = t2) ==> t12 + t21 = &2 * pi)`;;
	   
e (REPEAT STRIP_TAC);;
	   
e (DOWN_TAC);;
	   
e (DAO);;
	   
e (IMP_TAC);;
	   
e (SIMP_TAC[REAL_SUB_REFL; REAL_ADD_LID; REAL_ADD_RID]);;
	   
e (NHANH (MESON[IN_A_PERIOD_IDE0]` t21 = &2 * pi * real_of_int k21 /\
	   
     t12 = &2 * pi * real_of_int k12 /\
	   
     t21 < &2 * pi /\
	   
     &0 <= t21 /\
	   
     t12 < &2 * pi /\
	   
     &0 <= t12 /\ l ==> &0 = t12  /\ &0 = t21 `));;
	   
e (ONCE_REWRITE_TAC[EQ_SYM_EQ]);;
	   
e (SIMP_TAC[REAL_ADD_LID]);;
	   

	   

	   
e (DOWN_TAC);;
	   
e (SPEC_TAC(`t1:real`,` t1:real`));;
	   
e (SPEC_TAC(`t2:real`,` t2:real`));;
	   
e (SPEC_TAC(`t12:real`,` t12:real`));;
	   
e (SPEC_TAC(`t21:real`,` t21:real`));;
	   
e (SPEC_TAC(`k12:int`,` k12:int`));;
	   
e (SPEC_TAC(`k21:int`,` k21:int`));;
	   
e (MATCH_MP_TAC (MESON[REAL_ARITH` a <= b \/ b <= a `]` (! a1 b1 a2 b2 a b.
	   
  P a1 b1 a2 b2 a b <=> P b1 a1 b2 a2 b a ) /\
	   
  (! a2 b2. L a2 b2 <=> L b2 a2 ) /\
	   
  (! a1 b1 a2 b2 a b.
	   
  P a1 b1 a2 b2 a b /\ a <= (b:real) ==> L a2 b2 )  
	   
  ==> (! a1 b1 a2 b2 a b. P a1 b1 a2 b2 a b ==>
	   
  L a2 b2 )   `));;
	   
e (CONJ_TAC);;
	   
e (MESON_TAC[]);;
	   

	   
e (CONJ_TAC);;
	   
e (SIMP_TAC[REAL_ADD_SYM]);;
	   
e (NHANH (REAL_FIELD` &0 <= t1 /\
	   
      t1 < &2 * pi /\
	   
      &0 <= t2 /\
	   
      t2 < &2 * pi /\
	   
      &0 <= t12 /\
	   
      t12 < &2 * pi /\ l ==> t1 - t2 < &2 * pi`));;
	   
e (REPEAT STRIP_TAC);;
	   
e (REPLICATE_TAC 3 (FIRST_X_ASSUM MP_TAC));;
	   
e (ONCE_REWRITE_TAC[REAL_ARITH` a <= b <=> &0 <= b - a `]);;
	   
e (PHA);;
	   
e (ONCE_REWRITE_TAC[GSYM REAL_SUB_0]);;
	   
e (NHANH (REAL_FIELD` ~( t2 = &0) /\
	   
    t2 < pp /\
	   
     &0 <= t2 ==> &0 <= pp - t2 /\ pp - t2 < pp `));;
	   
e (FIRST_X_ASSUM MP_TAC);;
	   
e (ONCE_REWRITE_TAC[REAL_ARITH` a - b + &2* pi * c =
	   
  &2 * pi - ( b - a ) + &2 * pi * ( c - &1 ) `]);;
	   
e (ABBREV_TAC ` ttt = &2 * pi - (t1 - t2)`);;
	   
e (ONCE_REWRITE_TAC[MESON[int_of_num_th]` &1 = real_of_int (&1)`]);;
	   
e (DOWN_TAC);;
	   
e (REWRITE_TAC[GSYM int_sub_th]);;
	   
e (NHANH (MESON[UNIQUE_PROPERTY_IN_A_PERIOD]`
	   
  &0 <= t12 /\
	   
 t12 < &2 * pi /\
	   
 &0 <= t21 /\
	   
 t21 < &2 * pi /\
	   
 t12 = t1 - t2 + &2 * pi * real_of_int k12 /\
	   
 &2 * pi - (t1 - t2) = ttt /\
	   
 t21 = ttt + &2 * pi * real_of_int (k21 - &1)  /\
	   
 ~(t1 - t2 = &0) /\
	   
 t1 - t2 < &2 * pi /\
	   
 &0 <= t1 - t2 /\
	   
 &0 <= ttt /\
	   
 ttt < &2 * pi ==> t1 - t2 = t12 /\ ttt = t21 `));;
	   
e (ONCE_REWRITE_TAC[EQ_SYM_EQ]);;
	   
e (SIMP_TAC[]);;
	   
e (STRIP_TAC);;
	   
e (CONV_TAC REAL_RING);;
	   

	   
let PDPFQUK = top_thm();;
(* June, 2009 *)

	   

(* June, 2009 *)
let QAFHJNM = prove(`! (v:real^N) w x .
let e3 = ( &1 / norm ( w - v )) % (w - v ) in 
let r = norm ( x - v ) in
let phi = arcV v w x in 
 ~( v = x ) /\ ~ ( v = w ) 
==> (? u'. u' dot e3 = &0 /\
x = v + u' + ( r * cos phi ) % e3 ) `,
NHANH (MESON[EXISTS_PROJECTING_POINT2]`l /\ ~(v = w) ==> (?pp. (pp:real^N) IN aff {w, v} 
 /\ (x - pp) dot (w - v) = &0 ) `) THEN REPEAT STRIP_TAC THEN REPEAT LET_TAC THEN 
SIMP_TAC[AFF2; IN_ELIM_THM; VECTOR_ARITH`  pp = t % w + (&1 - t) % v <=> pp - v = t % ( w - v ) `]
THEN EXPAND_TAC "phi" THEN STRIP_TAC THEN EXISTS_TAC ` x - (pp:real^N)` THEN 
REPLICATE_TAC 4 (FIRST_X_ASSUM MP_TAC) THEN PHA THEN NHANH (SIMPLIZE_COS_IF_OTHOR) THEN 
EXPAND_TAC "e3" THEN SIMP_TAC[DOT_RMUL; REAL_MUL_RZERO; VECTOR_MUL_ASSOC] THEN 
ONCE_REWRITE_TAC[VECTOR_ARITH` a = b <=> b - a = vec 0 `] THEN 
SIMP_TAC[GSYM NORM_EQ_0] THEN EXPAND_TAC "r" THEN SIMP_TAC[GSYM NORM_EQ_0; REAL_FIELD`
 ~(x = &0) /\ ~(w = &0) ==>  ( x * t * w / x ) * &1 / w = t `] THEN 
SIMP_TAC[VECTOR_ARITH` (v + x - pp + tt ) - x  = (tt: real^N) - (pp - v) `]);;
	   

(* August, 2009 *)
let YBXRVTS = prove(`! v w (u:real^3) x. 
~collinear {v,w,u} /\
n = (w - v) cross (u - v ) /\ 
x IN aff {v,w,u} ==>
angle (( v + n ), v, x) = pi / &2 `,
REWRITE_TAC[aff;AFFINE_HULL_3; IN_ELIM_THM;angle; vector_angle] THEN
REPEAT STRIP_TAC THEN COND_CASES_TAC THENL [REWRITE_TAC[];
UNDISCH_TAC ` u' + v' + w' = &1 ` THEN 
ASM_SIMP_TAC[VECTOR_ARITH`(a + b ) - a = (b:real^N)`; REAL_ARITH` a + b = &1 <=> a = &1 - b `;
VECTOR_ARITH` ((&1 - (v' + w')) % v + v' % w + w' % u) - v = v' % ( w - v ) + w' % ( u - v ) `;
DOT_RADD; DOT_RMUL; DOT_CROSS_SELF;REAL_MUL_RZERO ;REAL_ADD_RID; REAL_ARITH` &0 / a = &0`; PI2_EQ_ACS0]]);;




let types_thm th = let cl = concl th in
  List.map dest_var (frees cl );;

let seans_fn () =
  let (tms,tm) = top_goal () in
  let vss = map frees (tm::tms) in
  let vs = setify (flat vss) in
  map dest_var vs;;



(* ========= NEW RULES and TAC TIC ============================= *)
(* ============================================================= *)
(* ============================================================= *)


let PAT_REWRITE_TAC tm thms = 
(CONV_TAC (PAT_CONV tm (REWRITE_CONV thms )));;

let FOR_ASM th = 
  let th1 = REWRITE_RULE[MESON[]` a /\ b ==> c <=>
a ==> b ==> c `] th in
  let th2 = SPEC_ALL th1 in UNDISCH_ALL th2;;

(* change a th having form |- A ==> t to the form A |- t
to get ready to some other commands 


|- A ==> t
----------- FOR_ASM
A |- t  
*)

let ASSUME_TAC2 = ASSUME_TAC o FOR_ASM;;


let PAT_ONCE_REWRITE_TAC tm thms =
(CONV_TAC (PAT_CONV tm (ONCE_REWRITE_CONV thms )));;

let ASM_PAT_RW_TAC tm thms = EVERY_ASSUM (fun th -> 
(CONV_TAC (PAT_CONV tm (ONCE_REWRITE_CONV
( th ::[ thms ] )))));;

let PAT_TH_TAC tm th = 
(CONV_TAC (PAT_CONV tm (REWRITE_CONV[th] )));;

(* rewurte a goal with one theorem *)

let IMP_TO_EQ_RULE th = MATCH_MP (TAUT` (a ==> b ) ==> 
( a <=> a /\ b )`) (SPEC_ALL th);;

let NHANH_PAT tm th = PAT_ONCE_REWRITE_TAC tm 
[ IMP_TO_EQ_RULE th ];;



let USE_FIRST tm tac = UNDISCH_TAC tm THEN DISCH_TAC THEN 
FIRST_ASSUM tac;;


let ONCE_SIMP_IDENT tm tth = (UNDISCH_TAC tm) THEN
 DISCH_TAC  THEN FIRST_ASSUM ( fun th ->
 ONCE_REWRITE_TAC[(MATCH_MP tth th)] );;


let SIMP_TAC1 th = SIMP_TAC[ th];;

let SIMP_TACC1 th = ASSUME_TAC2 th THEN FIRST_X_ASSUM 
SIMP_TAC1;;

let SIMP_IDENT thms tm = UNDISCH_TAC tm THEN (SIMP_TAC thms)
  THEN DISCH_TAC;;
USE_FIRST;;



let ELIM_IDENTS th = ASSUME_TAC2 th THEN FIRST_X_ASSUM
( fun thh -> SIMP_TAC[ thh]);;

(* ============================================================== *)
(* ============================================================== *)
(* ============================================================== *)





let GIVEN_POINT_EXISTS_2_NOT_COLLINEAR = prove(` !(x:real^3). ? y z. ~ collinear {x,y,z} `,
GEOM_ORIGIN_TAC `x:real^3` THEN EXISTS_TAC` (vector [&1; &0; &0 ]) : real^3` THEN 
EXISTS_TAC` (vector [&0; &1; &0 ]) : real^3` THEN 
REWRITE_TAC[GSYM CROSS_EQ_0; cross; VECTOR_3] THEN 
CONV_TAC REAL_RAT_REDUCE_CONV THEN 
REWRITE_TAC[VECTOR_EQ; DOT_LZERO; DOT_3; VECTOR_3] THEN REAL_ARITH_TAC);;


let NOT_BASISES_EQ_VEC0 = prove(` ~( basis 1 = ((vec 0): real^3) \/
basis 2 = ((vec 0): real^3) \/ basis 3 = ((vec 0): real^3) ) `,
REWRITE_TAC[DE_MORGAN_THM] THEN CONJ_TAC THENL [
MATCH_MP_TAC BASIS_NONZERO THEN REWRITE_TAC[DIMINDEX_3] THEN ARITH_TAC; CONJ_TAC THENL [
MATCH_MP_TAC BASIS_NONZERO THEN REWRITE_TAC[DIMINDEX_3] THEN ARITH_TAC; 
MATCH_MP_TAC BASIS_NONZERO THEN REWRITE_TAC[DIMINDEX_3] THEN ARITH_TAC]]);;


let TOW_DISTINCT_POINTS_EXISTS_RD_NOT_COLLINEAR = prove(
`! x (y: real^3). ~( x = y ) ==> (? z. ~ collinear {x,y,z} )`,
GEOM_ORIGIN_TAC `x:real^3` THEN GEOM_BASIS_MULTIPLE_TAC 1 `y:real^3` THEN 
ONCE_REWRITE_TAC[EQ_SYM_EQ] THEN REWRITE_TAC[VECTOR_MUL_EQ_0] THEN 
REPEAT STRIP_TAC THEN EXISTS_TAC ` (basis 2) :real^3` THEN 
REWRITE_TAC[GSYM CROSS_EQ_0; CROSS_LMUL; CROSS_BASIS] THEN 
REWRITE_TAC[VECTOR_MUL_EQ_0] THEN FIRST_X_ASSUM MP_TAC THEN 
SIMP_TAC[REWRITE_RULE[DE_MORGAN_THM] NOT_BASISES_EQ_VEC0 ]);;


let SUBSET_IMP_SUBSET_HULL = prove(`a SUBSET b ==>  a SUBSET P hull b `,
MATCH_MP_TAC (SET_RULE`b SUBSET P hull b ==> a SUBSET b ==> a SUBSET P hull b `) THEN 
REWRITE_TAC[HULL_SUBSET]);;


let THREE_POINT_IMP_EXISTS_3 = prove(`! (v1:real^3) v2 v3. ? w2 w3.
 ~( collinear {v1,w2,w3} ) /\ {v1,v2,v3} SUBSET affine hull {v1,w2,w3} `,
REPEAT GEN_TAC THEN ASM_CASES_TAC` collinear {(v1: real^3),v2,v3} ` THENL 
[FIRST_X_ASSUM MP_TAC THEN GEOM_ORIGIN_TAC `v1: real^3` THEN 
REPEAT GEN_TAC THEN PAT_REWRITE_TAC `\x. x ==> _ ` [COLLINEAR_LEMMA] THEN 
SPEC_TAC (`v3:real^3`,`v3: real^3`) THEN SPEC_TAC (`v2:real^3`,`v2: real^3`) THEN 
MATCH_MP_TAC (MESON[]`(!a b. P a b <=> P b a) /\ (!v w. v = vec 0 \/ l v w ==> P v w)
     ==> (!v w. v = vec 0 \/ w = vec 0 \/ l v w ==> P v w)`) THEN 
SIMP_TAC[INSERT_AC] THEN REPEAT STRIP_TAC THENL [
ONCE_REWRITE_TAC[SET_RULE` {a,b,c} = {c,a,b} `] THEN 
ASM_CASES_TAC `(v3:real^3) = vec 0 ` THENL [
MP_TAC (SPEC`(vec 0) :real^3` GIVEN_POINT_EXISTS_2_NOT_COLLINEAR) THEN 
STRIP_TAC THEN 
EXISTS_TAC `y: real^3` THEN
EXISTS_TAC `z: real^3` THEN 
ASM_SIMP_TAC[INSERT_EMPTY_SUBSET] THEN 
MATCH_MP_TAC HULL_INC THEN 
SET_TAC[];
FIRST_X_ASSUM MP_TAC THEN NHANH TOW_DISTINCT_POINTS_EXISTS_RD_NOT_COLLINEAR  THEN 
STRIP_TAC THEN 
EXISTS_TAC `v3: real^3` THEN 
EXISTS_TAC `z: real^3` THEN 
FIRST_X_ASSUM MP_TAC THEN 
SIMP_TAC[INSERT_COMM] THEN 
STRIP_TAC THEN 
MATCH_MP_TAC SUBSET_IMP_SUBSET_HULL  THEN 
ASM_SIMP_TAC[] THEN 
SET_TAC[]]; ONCE_REWRITE_TAC[SET_RULE` {a,b,c} = {c,a,b} `] THEN 
ASM_CASES_TAC`v2: real^3 = vec 0 ` THENL [UNDISCH_TAC `v3 = c % (v2: real^3)` THEN 
MATCH_MP_TAC (TAUT` a ==> b ==> a `) THEN 
ASM_CASES_TAC `(v3:real^3) = vec 0 ` THENL [
MP_TAC (SPEC`(vec 0) :real^3` GIVEN_POINT_EXISTS_2_NOT_COLLINEAR) THEN 
STRIP_TAC THEN 
EXISTS_TAC `y: real^3` THEN
EXISTS_TAC `z: real^3` THEN 
ASM_SIMP_TAC[INSERT_EMPTY_SUBSET] THEN 
MATCH_MP_TAC HULL_INC THEN 
SET_TAC[];
FIRST_X_ASSUM MP_TAC THEN NHANH TOW_DISTINCT_POINTS_EXISTS_RD_NOT_COLLINEAR  THEN 
STRIP_TAC THEN 
EXISTS_TAC `v3: real^3` THEN 
EXISTS_TAC `z: real^3` THEN 
FIRST_X_ASSUM MP_TAC THEN 
SIMP_TAC[INSERT_COMM] THEN 
STRIP_TAC THEN 
MATCH_MP_TAC SUBSET_IMP_SUBSET_HULL  THEN 
ASM_SIMP_TAC[] THEN 
SET_TAC[]]; FIRST_X_ASSUM MP_TAC] THEN
ONCE_REWRITE_TAC[EQ_SYM_EQ] THEN 
NHANH TOW_DISTINCT_POINTS_EXISTS_RD_NOT_COLLINEAR THEN 
STRIP_TAC THEN 
EXISTS_TAC`v2:real^3` THEN 
EXISTS_TAC`z:real^3` THEN 
ASM_SIMP_TAC[INSERT_EMPTY_SUBSET] THEN 
ASM_SIMP_TAC[INSERT_EMPTY_SUBSET; IN_P_HULL_INSERT] THEN 
ONCE_REWRITE_TAC[INSERT_AC] THEN 
ASM_SIMP_TAC[AFFINE_HULL_3; IN_P_HULL_INSERT; IN_ELIM_THM] THEN 
EXISTS_TAC `c: real` THEN 
EXISTS_TAC `&1 - (c: real)` THEN 
EXISTS_TAC `&0` THEN 
SIMP_TAC[REAL_ARITH`c + &1 - c + &0 = &1 `] THEN 
CONV_TAC VECTOR_ARITH]; ASM_MESON_TAC[HULL_SUBSET]]);;



let SUBSET_AFFINE_HULL3_EQ_SUB_PLANE = prove(`
(? (u: real^3 ) v w. S SUBSET affine hull {u, v, w}) <=> (?x. plane x /\ S SUBSET x)`,
REWRITE_TAC[plane] THEN EQ_TAC THENL [STRIP_TAC THEN 
MP_TAC (SPECL [`u: real^3`;`v:real^3`;`w:real^3`] THREE_POINT_IMP_EXISTS_3) THEN 
STRIP_TAC THEN EXISTS_TAC` affine hull {u, w2, (w3: real^3)}` THEN CONJ_TAC THENL [
ASM_MESON_TAC[]; FIRST_X_ASSUM MP_TAC THEN 
NHANH_PAT `\x. x ==> y ` (MESON[HULL_MONO]` s SUBSET t ==> affine hull s SUBSET affine hull t`)
THEN ASM_SIMP_TAC[HULL_HULL] THEN ASM_MESON_TAC[SUBSET_TRANS]]; MESON_TAC[]]);;

let coplanar2 = coplanar;;



let NOT_COPLANAR_0_4_IMP_INDEPENDENT = prove
 (`!v1 v2 v3:real^N. ~coplanar {vec 0,v1,v2,v3} ==> independent {v1,v2,v3}`,
 REPEAT GEN_TAC THEN REWRITE_TAC[independent; CONTRAPOS_THM] THEN
 REWRITE_TAC[dependent] THEN
 SUBGOAL_THEN
  `!v1 v2 v3:real^N. v1 IN span {v2,v3} ==> coplanar{vec 0,v1,v2,v3}`
 ASSUME_TAC THENL
  [REPEAT STRIP_TAC THEN REWRITE_TAC[coplanar] THEN
   MAP_EVERY EXISTS_TAC [`vec 0:real^N`; `v2:real^N`; `v3:real^N`] THEN
   SIMP_TAC[AFFINE_HULL_EQ_SPAN; HULL_INC; IN_INSERT] THEN
   REWRITE_TAC[INSERT_SUBSET; EMPTY_SUBSET] THEN
   ASM_SIMP_TAC[SPAN_SUPERSET; IN_INSERT] THEN
   POP_ASSUM MP_TAC THEN SPEC_TAC(`v1:real^N`,`v1:real^N`) THEN
   REWRITE_TAC[GSYM SUBSET] THEN MATCH_MP_TAC SPAN_MONO THEN SET_TAC[];
   REWRITE_TAC[IN_INSERT; NOT_IN_EMPTY] THEN
   STRIP_TAC THEN ASM_REWRITE_TAC[] THEN
   FIRST_X_ASSUM SUBST_ALL_TAC THENL
    [FIRST_X_ASSUM(MP_TAC o SPECL [`v1:real^N`; `v2:real^N`; `v3:real^N`]);
     FIRST_X_ASSUM(MP_TAC o SPECL [`v2:real^N`; `v3:real^N`; `v1:real^N`]);
     FIRST_X_ASSUM(MP_TAC o SPECL [`v3:real^N`; `v1:real^N`; `v2:real^N`])]
   THEN REWRITE_TAC[INSERT_AC] THEN DISCH_THEN MATCH_MP_TAC THEN
   FIRST_X_ASSUM(MATCH_MP_TAC o MATCH_MP (SET_RULE
    `a IN s ==> s SUBSET t ==> a IN t`)) THEN
   MATCH_MP_TAC SPAN_MONO THEN SET_TAC[]]);;

let NONCOPLANAR_3_BASIS = prove
 (`!v1 v2 v3 v0 v:real^3.
       ~coplanar {v0, v1, v2, v3}
       ==> ?t1 t2 t3.
              v = t1 % (v1 - v0) + t2 % (v2 - v0) + t3 % (v3 - v0) /\
              (!ta tb tc.
                  v = ta % (v1 - v0) + tb % (v2 - v0) + tc % (v3 - v0)
                  ==> ta = t1 /\ tb = t2 /\ tc = t3)`,
 GEN_GEOM_ORIGIN_TAC `v0:real^3` ["v"] THEN REPEAT GEN_TAC THEN
 MAP_EVERY (fun t ->
   ASM_CASES_TAC t THENL [ASM_REWRITE_TAC[INSERT_AC; COPLANAR_3]; ALL_TAC])
  [`v1:real^3 = vec 0`; `v2:real^3 = vec 0`; `v3:real^3 = vec 0`;
   `v2:real^3 = v1`; `v3:real^3 = v1`; `v3:real^3 = v2`] THEN
 DISCH_THEN(ASSUME_TAC o MATCH_MP NOT_COPLANAR_0_4_IMP_INDEPENDENT) THEN
 REWRITE_TAC[VECTOR_SUB_RZERO] THEN
 MP_TAC(ISPECL [`(:real^3)`; `{v1,v2,v3}:real^3->bool`]
   CARD_GE_DIM_INDEPENDENT) THEN
 ASM_REWRITE_TAC[SUBSET_UNIV; DIM_UNIV; DIMINDEX_3] THEN
 ASM_SIMP_TAC[CARD_CLAUSES; FINITE_INSERT; FINITE_EMPTY] THEN
 ASM_REWRITE_TAC[IN_INSERT; NOT_IN_EMPTY; ARITH; SUBSET; IN_UNIV] THEN
 DISCH_THEN(MP_TAC o SPEC `v:real^3`) THEN
 REWRITE_TAC[SPAN_BREAKDOWN_EQ; SPAN_EMPTY; IN_SING] THEN
 REWRITE_TAC[VECTOR_ARITH `a - b:real^3 = c <=> a = b + c`] THEN
 REWRITE_TAC[VECTOR_ADD_RID] THEN
 MATCH_MP_TAC MONO_EXISTS THEN X_GEN_TAC `t1:real` THEN
 MATCH_MP_TAC MONO_EXISTS THEN X_GEN_TAC `t2:real` THEN
 MATCH_MP_TAC MONO_EXISTS THEN X_GEN_TAC `t3:real` THEN
 DISCH_TAC THEN ASM_REWRITE_TAC[] THEN
 MAP_EVERY X_GEN_TAC [`ta:real`; `tb:real`; `tc:real`] THEN DISCH_TAC THEN
 FIRST_X_ASSUM(MP_TAC o GEN_REWRITE_RULE I [INDEPENDENT_EXPLICIT]) THEN
 REWRITE_TAC[FINITE_INSERT; FINITE_EMPTY] THEN
 DISCH_THEN(MP_TAC o SPEC
    `(\x. if x = v1 then t1 - ta
          else if x = v2 then t2 - tb else t3 - tc):real^3->real`) THEN
 REWRITE_TAC[FORALL_IN_INSERT] THEN
 SIMP_TAC[VSUM_CLAUSES; FINITE_INSERT; FINITE_EMPTY] THEN
 ASM_REWRITE_TAC[IN_INSERT; NOT_IN_EMPTY; VECTOR_ADD_RID] THEN
 REWRITE_TAC[REAL_ARITH `s - t = &0 <=> t = s`] THEN
 DISCH_THEN MATCH_MP_TAC THEN UNDISCH_TAC
  `t1 % v1 + t2 % v2 + t3 % v3:real^3 = ta % v1 + tb % v2 + tc % v3` THEN
 VECTOR_ARITH_TAC);;


let coplanar = prove(` ! (S:real^3 -> bool ). coplanar S <=> (?x. plane x /\ S SUBSET x)`,
REWRITE_TAC[SUBSET_AFFINE_HULL3_EQ_SUB_PLANE; coplanar]);;


let COPLANAR_DET_EQ_0 = prove
 (`!v0 v1 (v2: real^3) v3.
       coplanar {v0,v1,v2,v3} <=>
       det(vector[v1 - v0; v2 - v0; v3 - v0]) = &0`,
 REPEAT GEN_TAC THEN REWRITE_TAC[DET_EQ_0_RANK; RANK_ROW] THEN
 REWRITE_TAC[rows; row; LAMBDA_ETA] THEN
 ONCE_REWRITE_TAC[SIMPLE_IMAGE_GEN] THEN
 REWRITE_TAC[GSYM numseg; DIMINDEX_3] THEN
 CONV_TAC(ONCE_DEPTH_CONV NUMSEG_CONV) THEN
 SIMP_TAC[IMAGE_CLAUSES; VECTOR_3] THEN EQ_TAC THENL
  [REWRITE_TAC[coplanar; plane; LEFT_AND_EXISTS_THM; LEFT_IMP_EXISTS_THM] THEN
   MAP_EVERY X_GEN_TAC
    [`p:real^3->bool`; `a:real^3`; `b:real^3`; `c:real^3`] THEN
   DISCH_THEN(CONJUNCTS_THEN2 STRIP_ASSUME_TAC MP_TAC) THEN
   FIRST_X_ASSUM SUBST1_TAC THEN
   W(MP_TAC o PART_MATCH lhand AFFINE_HULL_INSERT_SUBSET_SPAN o
       rand o lhand o snd) THEN
   REWRITE_TAC[GSYM IMP_CONJ_ALT] THEN
   DISCH_THEN(MP_TAC o MATCH_MP SUBSET_TRANS) THEN
   DISCH_THEN(MP_TAC o ISPEC `\x:real^3. x - a` o MATCH_MP IMAGE_SUBSET) THEN
   ONCE_REWRITE_TAC[SIMPLE_IMAGE_GEN] THEN
   REWRITE_TAC[IMAGE_CLAUSES; GSYM IMAGE_o; o_DEF; VECTOR_ADD_SUB; IMAGE_ID;
               SIMPLE_IMAGE] THEN
   REWRITE_TAC[INSERT_SUBSET] THEN STRIP_TAC THEN
   GEN_REWRITE_TAC LAND_CONV [GSYM DIM_SPAN] THEN MATCH_MP_TAC LET_TRANS THEN
   EXISTS_TAC `CARD {b - a:real^3,c - a}` THEN
   CONJ_TAC THENL
    [MATCH_MP_TAC SPAN_CARD_GE_DIM;
     SIMP_TAC[CARD_CLAUSES; FINITE_RULES] THEN ARITH_TAC] THEN
   REWRITE_TAC[FINITE_INSERT; FINITE_RULES] THEN
   GEN_REWRITE_TAC RAND_CONV [GSYM SPAN_SPAN] THEN
   MATCH_MP_TAC SPAN_MONO THEN REWRITE_TAC[INSERT_SUBSET; EMPTY_SUBSET] THEN
   MP_TAC(VECTOR_ARITH `!x y:real^3. x - y = (x - a) - (y - a)`) THEN
   DISCH_THEN(fun th -> REPEAT CONJ_TAC THEN
     GEN_REWRITE_TAC LAND_CONV [th]) THEN
   MATCH_MP_TAC SPAN_SUB THEN ASM_REWRITE_TAC[];

   DISCH_TAC THEN
   MP_TAC(ISPECL [`{v1 - v0,v2 - v0,v3 - v0}:real^3->bool`; `2`]
                 LOWDIM_EXPAND_BASIS) THEN
   ASM_REWRITE_TAC[ARITH_RULE `n <= 2 <=> n < 3`; DIMINDEX_3; ARITH] THEN
   DISCH_THEN(X_CHOOSE_THEN `t:real^3->bool`
    (CONJUNCTS_THEN2 MP_TAC STRIP_ASSUME_TAC)) THEN
   CONV_TAC(LAND_CONV HAS_SIZE_CONV) THEN
   REWRITE_TAC[LEFT_IMP_EXISTS_THM] THEN
   MAP_EVERY X_GEN_TAC [`a:real^3`; `b:real^3`] THEN
   DISCH_THEN(CONJUNCTS_THEN2 ASSUME_TAC SUBST_ALL_TAC) THEN
   REWRITE_TAC[coplanar; plane] THEN
   EXISTS_TAC `affine hull {v0,v0 + a,v0 + b}:real^3->bool` THEN
   CONJ_TAC THENL
    [MAP_EVERY EXISTS_TAC [`v0:real^3`; `v0 + a:real^3`; `v0 + b:real^3`] THEN
     REWRITE_TAC[COLLINEAR_3; COLLINEAR_LEMMA;
                 VECTOR_ARITH `--x = vec 0 <=> x = vec 0`;
                 VECTOR_ARITH `u - (u + a):real^3 = --a`;
                 VECTOR_ARITH `(u + b) - (u + a):real^3 = b - a`] THEN
     REWRITE_TAC[DE_MORGAN_THM; VECTOR_SUB_EQ;
       VECTOR_ARITH `b - a = c % -- a <=> (c - &1) % a + &1 % b = vec 0`] THEN
     ASM_REWRITE_TAC[] THEN CONJ_TAC THENL
      [ASM_MESON_TAC[IN_INSERT; INDEPENDENT_NONZERO]; ALL_TAC] THEN
     DISCH_THEN(X_CHOOSE_TAC `u:real`) THEN
     FIRST_X_ASSUM(MP_TAC o GEN_REWRITE_RULE I [independent]) THEN
     REWRITE_TAC[DEPENDENT_EXPLICIT] THEN
     MAP_EVERY EXISTS_TAC [`{a:real^3,b}`;
                           `\x:real^3. if x = a then u - &1 else &1`] THEN
     REWRITE_TAC[FINITE_INSERT; FINITE_RULES; SUBSET_REFL] THEN
     CONJ_TAC THENL
      [EXISTS_TAC `b:real^3` THEN ASM_REWRITE_TAC[IN_INSERT] THEN
       REAL_ARITH_TAC;
       ALL_TAC] THEN
     SIMP_TAC[VSUM_CLAUSES; FINITE_RULES] THEN
     ASM_REWRITE_TAC[IN_INSERT; NOT_IN_EMPTY; VECTOR_ADD_RID];
     ALL_TAC] THEN
   W(MP_TAC o PART_MATCH (lhs o rand) AFFINE_HULL_INSERT_SPAN o
     rand o snd) THEN
   ANTS_TAC THENL
    [REWRITE_TAC[IN_INSERT; NOT_IN_EMPTY] THEN
     REWRITE_TAC[VECTOR_ARITH `u = u + a <=> a = vec 0`] THEN
     ASM_MESON_TAC[INDEPENDENT_NONZERO; IN_INSERT];
     ALL_TAC] THEN
   DISCH_THEN SUBST1_TAC THEN
   ONCE_REWRITE_TAC[SIMPLE_IMAGE_GEN] THEN
   REWRITE_TAC[SIMPLE_IMAGE; IMAGE_CLAUSES; IMAGE_ID; VECTOR_ADD_SUB] THEN
   MATCH_MP_TAC SUBSET_TRANS THEN EXISTS_TAC
    `IMAGE (\v:real^3. v0 + v) (span{v1 - v0, v2 - v0, v3 - v0})` THEN
   ASM_SIMP_TAC[IMAGE_SUBSET] THEN
   REWRITE_TAC[INSERT_SUBSET; EMPTY_SUBSET; IN_IMAGE] THEN CONJ_TAC THENL
    [EXISTS_TAC `vec 0:real^3` THEN REWRITE_TAC[SPAN_0] THEN VECTOR_ARITH_TAC;
     REWRITE_TAC[VECTOR_ARITH `v1:real^N = v0 + x <=> x = v1 - v0`] THEN
     REWRITE_TAC[UNWIND_THM2] THEN REPEAT CONJ_TAC THEN
     MATCH_MP_TAC SPAN_SUPERSET THEN REWRITE_TAC[IN_INSERT]]]);;


let det_vec3 = new_definition ` det_vec3 (a:real^3) (b:real^3) (c:real^3) = 
  a$1 * b$2 * c$3 + b$1 * c$2 * a$3 + c$1 * a$2 * b$3 - 
  ( a$1 * c$2 * b$3 + b$1 * a$2 * c$3 + c$1 * b$2 * a$3 ) `;;


let DET_VEC3_EXPAND = prove
 (`det (vector [a; b; (c:real^3)] ) = det_vec3 a b c`,
 REWRITE_TAC[det_vec3; DET_3; VECTOR_3] THEN REAL_ARITH_TAC);;

let COPLANAR_DET_VEC3_EQ_0 = prove( `!v0 v1 (v2: real^3) v3.
       coplanar {v0,v1,v2,v3} <=>
       det_vec3 ( v1 - v0 ) ( v2 - v0 ) ( v3 - v0 ) = &0`, REWRITE_TAC[COPLANAR_DET_EQ_0; DET_VEC3_EXPAND]);;


let coplanar1 = coplanar;;
let coplanar = coplanar2;;



let DET_VEC3_AS_CROSS_DOT = prove(` det_vec3 v1 v2 v3 = (v1 cross v2 ) dot v3 `,
REWRITE_TAC[det_vec3; cross; DOT_3; VECTOR_3]
 THEN REAL_ARITH_TAC);;


let ORTHONORMAL_IMP_NONZERO = prove
 (`!e1 e2 e3. orthonormal e1 e2 e3
             ==> ~(e1 = vec 0) /\ ~(e2 = vec 0) /\ ~(e3 = vec 0)`,
 REPEAT GEN_TAC THEN ONCE_REWRITE_TAC[GSYM CONTRAPOS_THM] THEN
 REWRITE_TAC[DE_MORGAN_THM] THEN STRIP_TAC THEN
 ASM_REWRITE_TAC[orthonormal; DOT_LZERO] THEN REAL_ARITH_TAC);;

let ORTHONORMAL_IMP_DISTINCT = prove
 (`!e1 e2 e3. orthonormal e1 e2 e3 ==> ~(e1 = e2) /\ ~(e1 = e3) /\ ~(e2 = e3)`,
 REPEAT GEN_TAC THEN ONCE_REWRITE_TAC[GSYM CONTRAPOS_THM] THEN
 REWRITE_TAC[DE_MORGAN_THM] THEN STRIP_TAC THEN
 ASM_REWRITE_TAC[orthonormal; DOT_LZERO] THEN REAL_ARITH_TAC);;

let ORTHONORMAL_IMP_INDEPENDENT = prove
 (`!e1 e2 e3. orthonormal e1 e2 e3 ==> independent {e1,e2,e3}`,
 REPEAT STRIP_TAC THEN MATCH_MP_TAC PAIRWISE_ORTHOGONAL_INDEPENDENT THEN
 CONJ_TAC THENL [ALL_TAC; ASM SET_TAC[ORTHONORMAL_IMP_NONZERO]] THEN
 RULE_ASSUM_TAC(REWRITE_RULE[orthonormal]) THEN
 REWRITE_TAC[pairwise; IN_INSERT; NOT_IN_EMPTY] THEN
 REPEAT STRIP_TAC THEN ASM_REWRITE_TAC[orthogonal] THEN
 ASM_MESON_TAC[DOT_SYM]);;

let ORTHONORMAL_IMP_SPANNING = prove
 (`!e1 e2 e3. orthonormal e1 e2 e3 ==> span {e1,e2,e3} = (:real^3)`,
 REPEAT STRIP_TAC THEN
 MP_TAC(ISPECL [`(:real^3)`; `{e1:real^3,e2,e3}`] CARD_EQ_DIM) THEN
 ASM_SIMP_TAC[ORTHONORMAL_IMP_INDEPENDENT; SUBSET_UNIV] THEN
 REWRITE_TAC[DIM_UNIV; DIMINDEX_3; HAS_SIZE; FINITE_INSERT; FINITE_EMPTY] THEN
 SIMP_TAC[CARD_CLAUSES; FINITE_INSERT; FINITE_EMPTY; IN_INSERT] THEN
 FIRST_ASSUM(ASSUME_TAC o MATCH_MP ORTHONORMAL_IMP_DISTINCT) THEN
 ASM_REWRITE_TAC[NOT_IN_EMPTY; ARITH] THEN SET_TAC[]);;

let th = prove
 (`!e1 e2 e3.
       orthonormal e1 e2 e3
       ==> !x. ?t1 t2 t3.
                   x = t1 % e1 + t2 % e2 + t3 % e3 /\
                   !tt1 tt2 tt3.
                       x = tt1 % e1 + tt2 % e2 + tt3 % e3
                       ==> tt1 = t1 /\ tt2 = t2 /\ tt3 = t3`,
 REPEAT STRIP_TAC THEN
 FIRST_ASSUM(MP_TAC o MATCH_MP ORTHONORMAL_IMP_SPANNING) THEN
 DISCH_THEN(MP_TAC o AP_TERM `(IN) (x:real^3)`) THEN
 REWRITE_TAC[IN_UNIV; SPAN_BREAKDOWN_EQ; SPAN_EMPTY; IN_SING] THEN
 SIMP_TAC[VECTOR_ARITH `x - a - b - c = vec 0 <=> x:real^3 = a + b + c`] THEN
 MAP_EVERY (fun t -> MATCH_MP_TAC MONO_EXISTS THEN X_GEN_TAC t)
  [`t1:real`; `t2:real`; `t3:real`] THEN
 DISCH_THEN SUBST1_TAC THEN REWRITE_TAC[] THEN REPEAT GEN_TAC THEN
 ONCE_REWRITE_TAC[REAL_ARITH `x:real = y <=> y - x = &0`] THEN
 REWRITE_TAC[VECTOR_ARITH
  `a % x + b % y + c % z:real^3 = a' % x + b' % y + c' % z <=>
   (a - a') % x + (b - b') % y + (c - c') % z = vec 0`] THEN
 DISCH_TAC THEN
 FIRST_ASSUM(MP_TAC o MATCH_MP ORTHONORMAL_IMP_INDEPENDENT) THEN
 REWRITE_TAC[INDEPENDENT_EXPLICIT] THEN DISCH_THEN(MP_TAC o CONJUNCT2) THEN
 DISCH_THEN(MP_TAC o SPEC
  `\x:real^3. if x = e1 then t1 - tt1:real
              else if x = e2 then t2 - tt2
              else t3 - tt3`) THEN
 FIRST_ASSUM(ASSUME_TAC o MATCH_MP ORTHONORMAL_IMP_DISTINCT) THEN
 ASM_SIMP_TAC[VSUM_CLAUSES; FINITE_INSERT; FINITE_EMPTY] THEN
 ASM_REWRITE_TAC[IN_INSERT; NOT_IN_EMPTY; VECTOR_ADD_RID] THEN
 DISCH_THEN(fun th -> MAP_EVERY (MP_TAC o C SPEC th)
   [`e1:real^3`; `e2:real^3`; `e3:real^3`]) THEN
 ASM_SIMP_TAC[]);;

(* the following lemma are in collect_geom.ml *)
(* Hi Truong,

In the very latest snapshot there is a theorem COPLANAR_DET_EQ_0
(I think I proved it because you asked for it some time ago). By
combing that with DET_3 you should be able to get your first
theorem COPLANAR_DET_VEC3_EQ_0.

I will work on the other one NONCOPLANAR_3_BASIS and send it later
today.*)


(* 
Hi Truong,

Here is the other theorem. Fortunately I proved the rather tedious
lemma NOT_COPLANAR_0_4_IMP_INDEPENDENT earlier in this week for use
in the volume properties.

John.

have been in trig.ml

let NOT_COPLANAR_0_4_IMP_INDEPENDENT = prove
 (`!v1 v2 v3:real^N. ~coplanar {vec 0,v1,v2,v3} ==> independent {v1,v2,v3}`,
 REPEAT GEN_TAC THEN REWRITE_TAC[independent; CONTRAPOS_THM] THEN
 REWRITE_TAC[dependent] THEN
 SUBGOAL_THEN
  `!v1 v2 v3:real^N. v1 IN span {v2,v3} ==> coplanar{vec 0,v1,v2,v3}`
 ASSUME_TAC THENL
  [REPEAT STRIP_TAC THEN REWRITE_TAC[coplanar] THEN
   MAP_EVERY EXISTS_TAC [`vec 0:real^N`; `v2:real^N`; `v3:real^N`] THEN
   SIMP_TAC[AFFINE_HULL_EQ_SPAN; HULL_INC; IN_INSERT] THEN
   REWRITE_TAC[INSERT_SUBSET; EMPTY_SUBSET] THEN
   ASM_SIMP_TAC[SPAN_SUPERSET; IN_INSERT] THEN
   POP_ASSUM MP_TAC THEN SPEC_TAC(`v1:real^N`,`v1:real^N`) THEN
   REWRITE_TAC[GSYM SUBSET] THEN MATCH_MP_TAC SPAN_MONO THEN SET_TAC[];
   REWRITE_TAC[IN_INSERT; NOT_IN_EMPTY] THEN
   STRIP_TAC THEN ASM_REWRITE_TAC[] THEN
   FIRST_X_ASSUM SUBST_ALL_TAC THENL
    [FIRST_X_ASSUM(MP_TAC o SPECL [`v1:real^N`; `v2:real^N`; `v3:real^N`]);
     FIRST_X_ASSUM(MP_TAC o SPECL [`v2:real^N`; `v3:real^N`; `v1:real^N`]);
     FIRST_X_ASSUM(MP_TAC o SPECL [`v3:real^N`; `v1:real^N`; `v2:real^N`])]
   THEN REWRITE_TAC[INSERT_AC] THEN DISCH_THEN MATCH_MP_TAC THEN
   FIRST_X_ASSUM(MATCH_MP_TAC o MATCH_MP (SET_RULE
    `a IN s ==> s SUBSET t ==> a IN t`)) THEN
   MATCH_MP_TAC SPAN_MONO THEN SET_TAC[]]);;

let NONCOPLANAR_3_BASIS = prove
 (`!v1 v2 v3 v0 v:real^3.
       ~coplanar {v0, v1, v2, v3}
       ==> ?t1 t2 t3.
              v = t1 % (v1 - v0) + t2 % (v2 - v0) + t3 % (v3 - v0) /\
              (!ta tb tc.
                  v = ta % (v1 - v0) + tb % (v2 - v0) + tc % (v3 - v0)
                  ==> ta = t1 /\ tb = t2 /\ tc = t3)`,
 GEN_GEOM_ORIGIN_TAC `v0:real^3` ["v"] THEN REPEAT GEN_TAC THEN
 MAP_EVERY (fun t ->
   ASM_CASES_TAC t THENL [ASM_REWRITE_TAC[INSERT_AC; COPLANAR_3]; ALL_TAC])
  [`v1:real^3 = vec 0`; `v2:real^3 = vec 0`; `v3:real^3 = vec 0`;
   `v2:real^3 = v1`; `v3:real^3 = v1`; `v3:real^3 = v2`] THEN
 DISCH_THEN(ASSUME_TAC o MATCH_MP NOT_COPLANAR_0_4_IMP_INDEPENDENT) THEN
 REWRITE_TAC[VECTOR_SUB_RZERO] THEN
 MP_TAC(ISPECL [`(:real^3)`; `{v1,v2,v3}:real^3->bool`]
   CARD_GE_DIM_INDEPENDENT) THEN
 ASM_REWRITE_TAC[SUBSET_UNIV; DIM_UNIV; DIMINDEX_3] THEN
 ASM_SIMP_TAC[CARD_CLAUSES; FINITE_INSERT; FINITE_EMPTY] THEN
 ASM_REWRITE_TAC[IN_INSERT; NOT_IN_EMPTY; ARITH; SUBSET; IN_UNIV] THEN
 DISCH_THEN(MP_TAC o SPEC `v:real^3`) THEN
 REWRITE_TAC[SPAN_BREAKDOWN_EQ; SPAN_EMPTY; IN_SING] THEN
 REWRITE_TAC[VECTOR_ARITH `a - b:real^3 = c <=> a = b + c`] THEN
 REWRITE_TAC[VECTOR_ADD_RID] THEN
 MATCH_MP_TAC MONO_EXISTS THEN X_GEN_TAC `t1:real` THEN
 MATCH_MP_TAC MONO_EXISTS THEN X_GEN_TAC `t2:real` THEN
 MATCH_MP_TAC MONO_EXISTS THEN X_GEN_TAC `t3:real` THEN
 DISCH_TAC THEN ASM_REWRITE_TAC[] THEN
 MAP_EVERY X_GEN_TAC [`ta:real`; `tb:real`; `tc:real`] THEN DISCH_TAC THEN
 FIRST_X_ASSUM(MP_TAC o GEN_REWRITE_RULE I [INDEPENDENT_EXPLICIT]) THEN
 REWRITE_TAC[FINITE_INSERT; FINITE_EMPTY] THEN
 DISCH_THEN(MP_TAC o SPEC
    `(\x. if x = v1 then t1 - ta
          else if x = v2 then t2 - tb else t3 - tc):real^3->real`) THEN
 REWRITE_TAC[FORALL_IN_INSERT] THEN
 SIMP_TAC[VSUM_CLAUSES; FINITE_INSERT; FINITE_EMPTY] THEN
 ASM_REWRITE_TAC[IN_INSERT; NOT_IN_EMPTY; VECTOR_ADD_RID] THEN
 REWRITE_TAC[REAL_ARITH `s - t = &0 <=> t = s`] THEN
 DISCH_THEN MATCH_MP_TAC THEN UNDISCH_TAC
  `t1 % v1 + t2 % v2 + t3 % v3:real^3 = ta % v1 + tb % v2 + tc % v3` THEN
 VECTOR_ARITH_TAC);;

*)



let DIV_POW2 = REAL_FIELD` (a/b) pow 2 = a pow 2 / (b pow 2 )`;;



let REAL_LE_SQUARE_POW = REWRITE_RULE[GSYM REAL_POW_2] REAL_LE_SQUARE;;


let NOT_EQ0_IMP_TRIGIZABLE = prove(` ~( x = &0 /\ y = &0 ) ==>
 ( x / sqrt ( x pow 2 + y pow 2 )) pow 2 
+ ( y / sqrt ( x pow 2 + y pow 2 )) pow 2 = &1 `,REWRITE_TAC[DIV_POW2] THEN 
ASSUME_TAC (MESON  [REAL_LE_SQUARE_POW; REAL_LE_ADD]`
 &0 <= x pow 2 + y pow 2 `) THEN 
ASM_SIMP_TAC[SQRT_POW_2; REAL_FIELD` a / (m:real) + b / m =
 ( a + b ) / m `;GSYM REAL_SOS_EQ_0; REAL_DIV_REFL]);;



let POW2_1 = REAL_ARITH` ( &1 ) pow 2 = &1`;;

let ABS_BOUNDS = REAL_ABS_BOUNDS;;

let POW2_1_BOUNDED = prove(
` a pow 2 + b pow 2 = &1 ==> -- &1 <= a /\ a <= &1 `,
REWRITE_TAC[REAL_ARITH` a + b = c <=> b = c - a `] THEN 
NHANH ( MESON[REAL_LE_POW_2]`a pow 2 = x ==> &0 <= x `) THEN 
ONCE_REWRITE_TAC[REAL_ARITH` &1 = &1 pow 2 `] THEN 
REWRITE_TAC[REAL_SUB_LE; GSYM REAL_LE_SQUARE_ABS; ABS_1; POW2_1;
ABS_BOUNDS] THEN SIMP_TAC[]);;

let POW2_1_BOUNDED = 
MESON[REAL_ADD_SYM; POW2_1_BOUNDED; REAL_ABS_BOUNDS]`
 a pow 2 + b pow 2 = &1 ==> abs a <= &1  /\ abs  b <= &1 `;;

let SIN_COMPLEMENTIVE = prove(` sin x = sin ( pi - x ) `,
REWRITE_TAC[SIN_COS; REAL_ARITH` a / &2 - ( a - x ) = 
-- ( a / &2 - x )`; COS_NEG]);;


let CYLINDER_CORDINATE = prove(` ! w u e1 e2 (e3:real^3) x.
 orthonormal e1 e2 e3 /\
e3 = ( &1  / norm ( w - u )) % ( w - u ) /\
 ~ ( x IN aff {w,u} ) /\ ~( w = u )
==>
(? r phi h. &0 < r /\
x = u + (r * ( cos  phi )) % e1 + 
( r * sin phi) % e2 
+ h % ( w - u ) ) `,
REPEAT GEN_TAC THEN 
REWRITE_TAC[orthonormal; GSYM  DET_VEC3_AS_CROSS_DOT] THEN 
NHANH (REAL_LT_IMP_NZ) THEN 
ONCE_REWRITE_TAC[MESON[VECTOR_SUB_RZERO]` fv a b c = fv ( a - vec 0 ) ( b - vec 0 )
( c - vec 0 ) `] THEN 
REWRITE_TAC[GSYM COPLANAR_DET_VEC3_EQ_0] THEN 
NHANH (SPECL [`e1 : real^3`;` e2 :real^3`; `e3 :real^3`; 
`(vec 0 : real^3)`; `(x : real^3) - u` ]  NONCOPLANAR_3_BASIS) THEN 
REWRITE_TAC[VECTOR_SUB_RZERO] THEN 
STRIP_TAC THEN 
ASM_CASES_TAC` t1 = &0 /\ t2 = &0 ` THENL [
FIRST_X_ASSUM (CONJUNCTS_THEN ASSUME_TAC) THEN 
(ASSUME_TAC o FOR_ASM ) (prove(` t1 = &0 /\ t2 = &0 /\
 x - u= t1 % e1 + t2 % e2 + t3 % e3
==> (x:real^3) - u = t3 % e3 `,
SIMP_TAC[VECTOR_MUL_LZERO; VECTOR_ADD_LID])) THEN 
FIRST_X_ASSUM MP_TAC THEN 
UNDISCH_TAC` e3 = &1 / norm (w - u) % (w - (u:real^3))` THEN 
SIMP_TAC[VECTOR_MUL_ASSOC; VECTOR_ARITH`
 a -(b:real^n) = n % ( c - b )<=> a = n % c +
 ( &1 - n ) % b `] THEN 
UNDISCH_TAC ` ~( x IN aff {w,(u:real^3)} )` THEN 
REWRITE_TAC[AFF2; IN_ELIM_THM] THEN 
MESON_TAC[]; 
FIRST_X_ASSUM MP_TAC] THEN 
NHANH  NOT_EQ0_IMP_TRIGIZABLE THEN 
NHANH CIRCLE_SINCOS THEN 
SIMP_TAC[GSYM REAL_SOS_EQ_0] THEN 
ONCE_REWRITE_TAC[MESON[]` a /\b ==> c <=> a ==> b ==> c `] THEN 
SIMP_TAC[GSYM SQRT_EQ_0; MESON[REAL_LE_POW_2;
   REAL_LE_ADD]` &0 <= t1 pow 2 + t2 pow 2 `; REAL_FIELD` 
~ ( a = &0 ) ==> (t / a = d <=> t = a * d ) `] THEN 
REPEAT STRIP_TAC THEN 
UNDISCH_TAC`x - u = t1 % e1 + t2 % e2 + t3 % (e3: real^3)` THEN 
REPLICATE_TAC 2 (FIRST_X_ASSUM MP_TAC) THEN 
UNDISCH_TAC` e3 = &1 / norm (w - u) % (w - (u:real^3))` THEN 
PURE_ONCE_REWRITE_TAC[MESON[]` a = b ==> P a <=> a = b ==> 
P b `] THEN 
ABBREV_TAC `tt = t1 pow 2 + t2 pow 2 ` THEN 
SIMP_TAC[] THEN 
REPLICATE_TAC 3 DISCH_TAC THEN 
REWRITE_TAC[VECTOR_ARITH` a - b = c <=> a = b + (c:real^N)`;
VECTOR_MUL_ASSOC] THEN REWRITE_TAC[REAL_ARITH` &0 < r /\ ~( r = &0 ) <=> &0 < r `] THEN 
ASSUME_TAC2 (MESON[SQRT_POS_LE; REAL_LE_POW_2; REAL_LE_ADD]` t1 pow 2 + 
t2 pow 2 = tt ==> &0 <= sqrt tt `) THEN 
ASSUME_TAC2 (REAL_ARITH` ~ ( sqrt tt = &0 ) /\ &0 <= sqrt tt
==> &0 < sqrt tt `) THEN FIRST_ASSUM MP_TAC THEN MESON_TAC[]);;




(* NOT NEED AT ALL
let arith_lemma = prove 
   (`!a d x. &0 < d ==> 
        ?y. (a <= y /\ y <= a + d) /\ ?n. y = x + &n * d \/ x = y + &n * d`,
    REPEAT STRIP_TAC THEN DISJ_CASES_TAC (SPEC `(x - a):real` REAL_LE_NEGTOTAL) 
    THEN IMP_RES_THEN (IMP_RES_THEN STRIP_ASSUME_TAC) REAL_ARCH_LEAST THENL
    [ EXISTS_TAC `x - &n * d` THEN STRIP_TAC THENL
      [ (POP_ASSUM MP_TAC) THEN (POP_ASSUM MP_TAC) THEN 
        REWRITE_TAC [GSYM REAL_OF_NUM_SUC] THEN REAL_ARITH_TAC ;
        EXISTS_TAC `n:num` THEN REAL_ARITH_TAC ] ;
      EXISTS_TAC `x + &(SUC n) * d` THEN STRIP_TAC THENL
      [ (POP_ASSUM MP_TAC) THEN (POP_ASSUM MP_TAC) THEN 
        REWRITE_TAC [GSYM REAL_OF_NUM_SUC] THEN REAL_ARITH_TAC ;
        EXISTS_TAC `(SUC n):num` THEN REAL_ARITH_TAC ]]);; 
*)


let COS_SUM_2PI = prove(
`! x. cos x = cos ( &2 * pi - x ) `, GEN_TAC THEN 
ONCE_REWRITE_TAC[GSYM COS_NEG] THEN 
PAT_ONCE_REWRITE_TAC `\x. _ = x ` [GSYM COS_PERIODIC] THEN 
REWRITE_TAC[REAL_ARITH` --( a - b) + a = b `; COS_NEG]);;



 let POW2_EQ_0 = prove(` ! a. a pow 2 = &0 <=> a = &0 `,
GEN_TAC THEN MP_TAC REAL_LE_POW_2 THEN 
ASSUME_TAC (GEN_ALL NOT_ZERO_EQ_POW2_LT) THEN 
REWRITE_TAC[REAL_LE_LT] THEN 
FIRST_ASSUM (fun th -> REWRITE_TAC[GSYM th] ) THEN 
ASM_MESON_TAC[]);;


let UNIT_BOUNDED_IN_TOW_FORMS = prove(`-- &1 <= a /\ a <= &1 ==> &0 <= &1 - a pow 2 `,
DISCH_TAC THEN REWRITE_TAC[REAL_ARITH` &1 - a pow 2 = (&1 - a ) * ( &1 + a )`] THEN 
MATCH_MP_TAC REAL_LE_MUL THEN ASM_REAL_ARITH_TAC);;


let COS_TOTAL = prove(`-- &1 <= a /\ a <= &1 ==> (?!x. &0 <= x /\ x <= pi /\ cos x = a ) `,
NHANH (UNIT_BOUNDED_IN_TOW_FORMS) THEN NHANH_PAT `\a. a ==> _` SQRT_WORKS THEN 
ONCE_REWRITE_TAC[REAL_ARITH` a = &1 - b pow 2 <=> b pow 2 + a = &1 `] THEN 
SIMP_TAC[EXISTS_UNIQUE] THEN NHANH SINCOS_TOTAL_PI THEN 
STRIP_TAC THEN EXISTS_TAC` t:real` THEN ASM_SIMP_TAC[] THEN 
ASM_MESON_TAC[COS_INJ_PI]);;




let SUM_POW2_EQ1_UNIQUE_TRIG = prove(` ! a b. a pow 2 + b pow 2 = &1 ==> (?!x. &0 <= x /\
x < &2 * pi /\ cos x = a /\ sin x = b )`,
REPEAT GEN_TAC THEN NHANH (POW2_1_BOUNDED) THEN 
REWRITE_TAC[REAL_ABS_BOUNDS] THEN 
NHANH_PAT `\x. _ /\ x /\ _ ==> h ` COS_TOTAL THEN 
PAT_REWRITE_TAC `\x. _ /\ _ /\ x ==> _ ` [REAL_ARITH`
-- &1 <= b /\ b <= &1 <=> -- &1 <= b /\ b < &0 \/ &0 <= b /\
b <= &1 `] THEN REWRITE_TAC[EXISTS_UNIQUE] THEN STRIP_TAC
THENL [ASSUME_TAC PI_POS THEN ASM_CASES_TAC ` x = &0 ` THENL [
FIRST_X_ASSUM SUBST_ALL_TAC THEN EXISTS_TAC ` &0` THEN 
SUBST_ALL_TAC COS_0 THEN FIRST_X_ASSUM (SUBST_ALL_TAC o SYM )
THEN UNDISCH_TAC `&1 pow 2 + b pow 2 = &1 ` THEN 
REWRITE_TAC[REAL_ARITH` &1 pow 2 + b = &1 <=>
b = &0 `; POW2_EQ_0] THEN DISCH_TAC THEN 
ASM_MESON_TAC[REAL_ARITH` b < &0 /\ b = &0 ==> F `];
EXISTS_TAC ` &2 * pi - x ` THEN ASSUME_TAC2 (
REAL_ARITH` x <= pi /\ &0 < pi ==> &0 <= &2 * pi - x `) THEN 
FIRST_X_ASSUM SIMP_TAC1 THEN 
ASSUME_TAC2 (REAL_ARITH` &0 <= x /\ ~( x = &0 ) ==> &0 < x `) THEN 
REWRITE_TAC[REAL_ARITH` a - b < a <=> &0 < b `] THEN 
FIRST_X_ASSUM SIMP_TAC1 THEN 
REWRITE_TAC[GSYM COS_SUM_2PI; REAL_ARITH` a - b = 
-- b + a `; SIN_PERIODIC; SIN_NEG] THEN 
SIMP_TACC1 (TAUT` cos x = a ==> cos x = a `) THEN 
SIMP_IDENT[] `cos x = a ` THEN 
ASSUME_TAC2 (REAL_ARITH` b < &0 ==> b <= &0 `) THEN 
ASSUME_TAC (SPEC_ALL SIN_CIRCLE) THEN 
USE_FIRST `cos x = a` SUBST_ALL_TAC THEN 
ASSUME_TAC2 (REAL_ARITH` sin x pow 2 + a pow 2 = &1 /\
a pow 2 + b pow 2 = &1 ==> sin x pow 2 = b pow 2 `) THEN 
SUBST_ALL_TAC (REAL_ARITH` b pow 2 = ( -- b ) pow 2 `) THEN 
ASSUME_TAC2 (REAL_ARITH` b < &0 ==> &0 <= -- b `) THEN 
ASSUME_TAC2 (SPEC_ALL SIN_POS_PI_LE) THEN 
ASSUME_TAC2 (MESON[EQ_POW2_COND]` &0 <= -- b /\
 &0 <= sin x /\sin x pow 2 = -- b pow 2 ==> sin x = -- b `) THEN 
SIMP_IDENT[REAL_NEGNEG] `sin x = -- b ` THEN 
REPEAT STRIP_TAC THEN 
UNDISCH_TAC `y < &2 * pi ` THEN 
ONCE_SIMP_IDENT ` &0 < pi ` (REAL_ARITH` &0 < p ==> ( x
< &2 * p <=> x <= p \/ p < x  /\ x < &2 * p )`) THEN 
STRIP_TAC] THENL [
ASSUME_TAC2 (SPEC `y:real` SIN_POS_PI_LE) THEN
ASSUME_TAC2 (REAL_ARITH` sin y = b /\ &0 <= sin y ==>
&0 <= b `) THEN UNDISCH_TAC ` b < &0 ` THEN 
SIMP_IDENT[REAL_ARITH` &0 <= b <=> ~(b < &0 )`] `&0 <= b`;
REWRITE_TAC[REAL_ARITH` y = -- x + b <=> b - y = x `] THEN 
REPLICATE_TAC 2 (FIRST_X_ASSUM MP_TAC) THEN PHA THEN 
REWRITE_TAC[REAL_ARITH` a < x /\ x < &2 * a <=> 
&0 < &2 * a - x /\ &2 * a - x < a `] THEN 
UNDISCH_TAC ` cos y = a ` THEN 
ONCE_REWRITE_TAC[COS_SUM_2PI] THEN 
NHANH (REAL_LT_IMP_LE) THEN 
UNDISCH_TAC `!y. &0 <= y /\ y <= pi /\ cos y = a ==> y = x` THEN 
MESON_TAC[]];EXISTS_TAC `x:real` THEN 
SIMP_IDENT[] `&0 <= x ` THEN 
SIMP_IDENT[]` cos x = a ` THEN 
ASSUME_TAC PI_POS THEN 
ASSUME_TAC2 (REAL_ARITH` x <= pi /\ &0 < pi ==>
 x < &2 * pi `) THEN 
SIMP_IDENT[]` x < &2 * pi` THEN 
ASSUME_TAC (SPEC_ALL SIN_CIRCLE) THEN 
USE_FIRST `cos x = a ` SUBST_ALL_TAC THEN 
ASSUME_TAC2 (REAL_ARITH` a pow 2 + b pow 2 = &1 /\
sin x pow 2 + a pow 2 = &1 ==> b pow 2 = sin x pow 2 `) THEN 
ASSUME_TAC2 (SPEC_ALL SIN_POS_PI_LE) THEN 
ASSUME_TAC2 (MESON[EQ_POW2_COND]` b pow 2 = sin x pow 2
 /\ &0 <= sin x /\ &0 <= b ==> sin x = b `) THEN 
SIMP_IDENT[]` sin x = b ` THEN 
ONCE_SIMP_IDENT ` &0 < pi ` (REAL_ARITH` &0 < p ==> ( x
< &2 * p <=> x <= p \/ p < x  /\ x < &2 * p )`) THEN 
REPEAT STRIP_TAC THENL [ASM_MESON_TAC[];
ASSUME_TAC2 (REAL_ARITH` pi < y /\ y < &2 * pi ==> 
&0 < y - pi /\ y - pi < pi `)] THEN 
ASSUME_TAC (UNDISCH (SPEC ` y - pi ` SIN_POS_PI)) THEN 
UNDISCH_TAC ` &0 < sin ( y - pi )` THEN 
ONCE_REWRITE_TAC[GSYM SIN_PERIODIC] THEN 
REWRITE_TAC[REAL_ARITH` a - b + &2 * b = a + b `;
SIN_PERIODIC_PI] THEN ASM_REWRITE_TAC[] THEN 
SIMP_IDENT[REAL_ARITH` &0 <= a ==> ~( &0 < -- a )`] 
` &0 <= b `]);;



let PERIODIC_AT0_IMP_ANY = prove(
` ! f p t. &0 < p  /\
(! x. f x = f ( x + p )) ==>
((?!x. &0 <= x /\ x < p /\ f x ) <=> (! t. &0 <= t /\
t < p ==> (?!x. t <= x /\
x < t + p /\ f x )))`,
REPEAT STRIP_TAC THEN REWRITE_TAC[EXISTS_UNIQUE] THEN 
 EQ_TAC THENL [REPEAT STRIP_TAC 
THEN ASM_CASES_TAC ` t <= (x:real) ` THENL [
EXISTS_TAC `x:real` THEN SIMP_IDENT[] `t <= x `
THEN SIMP_IDENT[] `(f: real -> bool) x` THEN
ELIM_IDENTS (REAL_ARITH` x < p /\ &0 <= t ==>
x < t + p `) THEN REPEAT STRIP_TAC THEN 
ASM_CASES_TAC ` y < (p:real)` THENL [
ASSUME_TAC2 (REAL_ARITH` &0 <= t /\ t <= y ==>
&0 <= y `) THEN ASM_MESON_TAC[];
DOWN_TAC THEN REWRITE_TAC[REAL_ARITH` ~( a < b ) <=> 
&0 <= a - b `; REAL_ARITH` a < b + c <=> 
a - c < b `] THEN STRIP_TAC THEN 
ASSUME_TAC2 (REAL_ARITH` y - p < t /\ t < p ==>
y - p < p `) THEN
ASSUME_TAC2 (prove(`(! a. f a <=> f ( a + (p:real)) )/\ f y ==>
f ( y - p )`, PAT_ONCE_REWRITE_TAC `\x. _ /\ x ==> _`
[REAL_ARITH` a = a - p + p `] THEN MESON_TAC[])) THEN
SUBST_ALL_TAC (
MESON[]`(!y. &0 <= y /\ y < p /\ f y ==> y = x)
<=> (!y. &0 <= y ==> y < p ==> f y ==> y = x)`) THEN 
ASSUME_TAC2 (
MESON[]`(!(y:real). &0 <= y ==> y < p ==> f y ==> y = x) /\
&0 <= y - p /\y - p < p /\ f ((y:real) - p) ==> x = y - p `) THEN 
REWRITE_TAC[REAL_ARITH` y = y - p <=> p = &0 `] THEN 
ASM_MESON_TAC[REAL_ARITH` y < t /\ x = y ==>
~( t <= x ) `]];EXISTS_TAC `x + p ` THEN 
SUBST_ALL_TAC (REAL_ARITH` ~( t <= x ) <=> x < t `) THEN 
ELIM_IDENTS (REAL_ARITH` t < p /\ &0 <= x /\ x < t ==>
t <= x + p /\ x + p < t + p `) THEN 
ELIM_IDENTS (MESON[]`(!x. f x <=> f ( x + (p:real)))
/\ f x ==> f ( x + p )`) THEN 
REWRITE_TAC[REAL_ARITH` a < b + c <=> a - c < b `] THEN 
REPEAT STRIP_TAC THEN 
ASM_CASES_TAC ` &0 <= y - p ` THEN 
ASSUME_TAC2 (REAL_ARITH` y - p < t /\ t < p ==>
y - p < p `) THEN 
ASSUME_TAC2 (prove(`(! a. f a <=> f ( a + (p:real)) )/\ f y ==>
f ( y - p )`, PAT_ONCE_REWRITE_TAC `\x. _ /\ x ==> _`
[REAL_ARITH` a = a - p + p `] THEN MESON_TAC[]))]
THENL [SUBST_ALL_TAC (
MESON[]`(!y. &0 <= y /\ y < p /\ f y ==> y = x)
<=> (!y. &0 <= y ==> y < p ==> f y ==> y = x)`) THEN 
ASSUME_TAC2 (
MESON[]`(!y. &0 <= y ==> y < p ==> f y ==> y = x) /\
&0 <= y - p /\ y - p < p /\ f ( y - p) ==> y - p
= x `) THEN 
(SIMP_IDENT[REAL_ARITH` a - b = c <=> a = b + c `]
 `y - p = (x:real) `) THEN SIMP_TAC[REAL_ADD_SYM];
SUBST_ALL_TAC (REAL_ARITH`~( &0 <= y - p ) <=> y < p `) THEN 
ASSUME_TAC2 (REAL_ARITH` &0 <= t /\ t <= y ==>
&0 <= y `) THEN SUBST_ALL_TAC (
MESON[]`(!y. &0 <= y /\ y < p /\ f y ==> y = x)
<=> (!y. &0 <= y ==> y < p ==> f y ==> y = x)`) THEN 
ASSUME_TAC2 (MESON[]`(!y. &0 <= y ==> y < p ==> f y ==> y = x)/\
f y /\ y < p /\ &0 <= y ==> y = x `) THEN 
(CONTR_TAC o UNDISCH_ALL o REAL_ARITH) ` y = x ==> x < t ==> t <= y ==> F `];
DISCH_TAC THEN FIRST_X_ASSUM (ASSUME_TAC o (SPEC
 ` &0 ` )) THEN ASSUME_TAC (REAL_ARITH` &0 <= &0 `)
     THEN DOWN_TAC THEN REWRITE_TAC[REAL_ADD_LID]
 THEN MESON_TAC[]]);;






let SUM_TWO_POW2S = MESON[REAL_LE_POW_2; REAL_LE_ADD]` &0 <= a pow 2 + b pow 2 `;;



let IDENT_WHEN_IDENT_SIN_COS = prove(`
&0 <= x' /\ x' < &2 * pi /\ &0 <= p /\ p < &2 * pi /\
cos x' = cos p /\ sin x' = sin p ==> p = x' `,
MP_TAC SIN_CIRCLE THEN 
ONCE_REWRITE_TAC[REAL_ADD_SYM] THEN 
MESON_TAC[SUM_POW2_EQ1_UNIQUE_TRIG]);;







let UNIQUE_EXISTSENCE_OF_RPHIH  =
prove(`!w u (e1: real^3) e2 e3 x.
     orthonormal e1 e2 e3 /\
     e3 = &1 / norm (w - u) % (w - u) /\
     ~(x IN aff {w, u}) /\
     ~(w = u)
     ==> (?r phii h.
              (&0 <= phii /\
               phii < &2 * pi /\
               &0 < r /\
               x =
               u + (r * cos phii) % e1 + (r * sin phii) % e2 + h % (w - u)) /\
              (!rr p hh.
                   &0 <= p /\
                   p < &2 * pi /\
                   &0 < rr /\
                   x =
                   u + (rr * cos p) % e1 + (rr * sin p) % e2 + hh % (w - u)
                   ==> rr = r /\ p = phii /\ hh = h))`,
REPEAT GEN_TAC THEN
REWRITE_TAC[orthonormal; GSYM  DET_VEC3_AS_CROSS_DOT] THEN
NHANH (REAL_LT_IMP_NZ) THEN
ONCE_REWRITE_TAC[MESON[VECTOR_SUB_RZERO]` fv a b c = fv ( a - vec 0 ) ( b - vec 0 )
( c - vec 0 ) `] THEN
REWRITE_TAC[GSYM COPLANAR_DET_VEC3_EQ_0] THEN
NHANH (SPECL [`e1 : real^3`;` e2 :real^3`; `e3 :real^3`; 
`(vec 0 : real^3)`; `(x : real^3) - u` ]  NONCOPLANAR_3_BASIS) THEN
REWRITE_TAC[VECTOR_SUB_RZERO] THEN
STRIP_TAC THEN
ASM_CASES_TAC` t1 = &0 /\ t2 = &0 ` THENL [
FIRST_X_ASSUM (CONJUNCTS_THEN ASSUME_TAC) THEN
(ASSUME_TAC o FOR_ASM ) (prove(` t1 = &0 /\ t2 = &0 /\
 x - u= t1 % e1 + t2 % e2 + t3 % e3
==> (x:real^3) - u = t3 % e3 `,
SIMP_TAC[VECTOR_MUL_LZERO; VECTOR_ADD_LID])) THEN
FIRST_X_ASSUM MP_TAC THEN
UNDISCH_TAC` e3 = &1 / norm (w - u) % (w - (u:real^3))` THEN
SIMP_TAC[VECTOR_MUL_ASSOC; VECTOR_ARITH`
 a -(b:real^n) = n % ( c - b )<=> a = n % c +
 ( &1 - n ) % b `] THEN
UNDISCH_TAC ` ~( x IN aff {w,(u:real^3)} )` THEN
REWRITE_TAC[AFF2; IN_ELIM_THM] THEN
MESON_TAC[];
FIRST_X_ASSUM MP_TAC THEN
NHANH  NOT_EQ0_IMP_TRIGIZABLE THEN 
NHANH SUM_POW2_EQ1_UNIQUE_TRIG THEN
PAT_REWRITE_TAC `\x. _ /\ _ /\ x ==> _ `
[REAL_ARITH` a < &2 * b <=> a < &0 + &2 * b `] THEN
   SIMP_TAC[GSYM REAL_SOS_EQ_0] THEN
   ONCE_REWRITE_TAC[MESON[]` a /\b ==> c <=> a ==> b ==> c `] THEN
   SIMP_TAC[GSYM SQRT_EQ_0; MESON[REAL_LE_POW_2;
      REAL_LE_ADD]` &0 <= t1 pow 2 + t2 pow 2 `; REAL_FIELD` 
   ~ ( a = &0 ) ==> (d = t / a <=> t = a * d ) `] THEN
   REWRITE_TAC[EXISTS_UNIQUE] THEN
   REPEAT STRIP_TAC THEN
   UNDISCH_TAC`x - u = t1 % e1 + t2 % e2 + t3 % (e3: real^3)` THEN
   ABBREV_TAC ` tt = t1 pow 2 + t2 pow 2 ` THEN
UNDISCH_TAC `   t1 = sqrt tt * cos x' ` THEN
UNDISCH_TAC ` t2 = sqrt tt * sin x' ` THEN
SIMP_TAC[] THEN 
REWRITE_TAC[VECTOR_ARITH` a - b = c <=> a = b + (c:real^N)`] THEN
REPEAT STRIP_TAC THEN
EXISTS_TAC ` sqrt tt ` THEN
EXISTS_TAC ` x' :real ` THEN
EXISTS_TAC ` t3 * ( &1 / norm ( (w:real^3) - u )) ` THEN
CONJ_TAC THENL [
UNDISCH_TAC`x = u + (sqrt tt * cos x') % e1 + 
(sqrt tt * sin x') % e2 + t3 % (e3 : real^3 )` THEN
UNDISCH_TAC` e3 = &1 / norm (w - u) % (w - (u:real^3))` THEN
REWRITE_TAC[REAL_ARITH` &0 < a /\ ~( a = &0 ) <=> &0 < a `] THEN
ASSUME_TAC2 (REAL_ARITH` x' < &0 + &2 * pi ==> x' < 
&2 * pi `) THEN
ASSUME_TAC2 (MESON[SQRT_POS_LE; REAL_LE_POW_2; REAL_LE_ADD]` t1 pow 2 + 
t2 pow 2 = tt ==> &0 <= sqrt tt `) THEN 
ASSUME_TAC2 (REAL_ARITH` ~ ( sqrt tt = &0 ) /\ &0 <= sqrt tt
==> &0 < sqrt tt `) THEN 
UNDISCH_TAC ` &0 < sqrt tt ` THEN
UNDISCH_TAC ` x' < &2 * pi ` THEN
UNDISCH_TAC ` &0 <= x' ` THEN
SIMP_TAC[VECTOR_MUL_ASSOC]; 
IMP_TAC THEN IMP_TAC THEN IMP_TAC THEN IMP_TAC THEN 
REPEAT GEN_TAC THEN REPEAT DISCH_TAC THEN 
UNDISCH_TAC `!ta tb tc.
          x - (u:real^3) = ta % e1 + tb % e2 + tc % e3
          ==> ta = t1 /\ tb = t2 /\ tc = t3` THEN
FIRST_X_ASSUM MP_TAC THEN 
UNDISCH_TAC`x = u + (sqrt tt * cos x') % e1 
+ (sqrt tt * sin x') % e2 + t3 % (e3:real^3)` THEN 
REWRITE_TAC[VECTOR_ARITH` a - b = (c:real^N) 
<=> a = b + c `] THEN
UNDISCH_TAC`e3 = &1 / norm (w - u) % (w - (u:real^3))` THEN
UNDISCH_TAC` ~(w = (u:real^3) )` THEN
PHA THEN
PAT_ONCE_REWRITE_TAC `\x. x /\ _ ==> _ `
[VECTOR_ARITH` ( a = (b:real^N))
<=>  ( a - b = vec 0 )`] THEN
REWRITE_TAC[ GSYM NORM_POS_LT] THEN
NHANH (MESON[REAL_FIELD ` &0 < a ==> a * &1 / a = &1`;
VECTOR_MUL_ASSOC]` &0 < a /\ aa = &1 / a % bb /\ l ==>
a % aa = ( &1 )% bb `) THEN
REWRITE_TAC[VECTOR_MUL_LID] THEN
DAO THEN
IMP_TAC THEN
DISCH_THEN (ASSUME_TAC o SYM) THEN
FIRST_ASSUM ( fun th -> PAT_ONCE_REWRITE_TAC `
\x. _ /\ x /\ _ ==> _ ` [ th]) THEN
REWRITE_TAC[VECTOR_MUL_ASSOC] THEN
NHANH (MESON[]` (!ta tb tc.
      x = u + ta % e1 + tb % e2 + tc % e3 ==> tc = t3 /\ ta = t1 /\ tb = t2 ) /\
 x = u + h1 % e1 + h2 % e2 + h3 % e3 /\
 x = u + l1 % e1 + l2 % e2 + l3 % e3 /\ ll ==>
l1 = h1 /\ l2 = h2 /\ l3 = h3 `) THEN
STRIP_TAC THEN
ELIM_IDENTS (REAL_FIELD` &0 < norm ((w:real^3) - u) /\ t3 = hh * norm ( w - u )
==> hh = t3 * &1 / norm ( w - u ) `) THEN
REPLICATE_TAC 3 (FIRST_X_ASSUM MP_TAC) THEN
PHA THEN
NHANH (MESON[]` a = b /\ aa = bb /\ l ==> a pow 2 + aa pow 2 =
b pow 2 + bb pow 2 `) THEN
REWRITE_TAC[REAL_ARITH` (a * b ) pow 2 + (a * c ) pow 2 =
a pow 2 * ( c pow 2 + b pow 2 ) `; SIN_CIRCLE; REAL_MUL_RID] THEN
ASSUME_TAC2 (MESON[SUM_TWO_POW2S]` t1 pow 2 + t2 pow 2 = tt 
==> &0 <= tt `) THEN
ASSUME_TAC2 (SPEC `tt:real` SQRT_POS_LE) THEN
ASSUME_TAC2 (SPECL[` &0`;` rr:real `] REAL_LT_IMP_LE) THEN
ASSUME_TAC2 (SPECL[` rr:real `;` sqrt tt `] EQ_POW2_COND) THEN
FIRST_X_ASSUM (MP_TAC o SYM) THEN
PAT_ONCE_REWRITE_TAC `\x. (x <=> _ ) ==> _` [EQ_SYM_EQ] THEN
SIMP_TAC[] THEN
REPEAT STRIP_TAC THEN
FIRST_X_ASSUM (SUBST_ALL_TAC o SYM) THEN
ASSUME_TAC2 (REAL_FIELD` &0 < rr /\ rr * cos x' = rr * cos p /\
rr * sin x' = rr * sin p ==> 
cos x' = cos p /\ sin x' = sin p `) THEN
SUBST_ALL_TAC (REAL_ARITH` x' < &0 + &2 * pi <=> x' < &2 * pi `) THEN
FIRST_X_ASSUM (CONJUNCTS_THEN ASSUME_TAC) THEN
ELIM_IDENTS IDENT_WHEN_IDENT_SIN_COS]]);;


 let REAL_EXISTS_UNIQUE_TRANSABLE  = 
prove(` ! f (t:real). (?!x. f x ) <=> (?!x. f (x - t))`,
REWRITE_TAC[EXISTS_UNIQUE] THEN REPEAT GEN_TAC THEN EQ_TAC THENL [
STRIP_TAC THEN EXISTS_TAC `x + (t:real)` THEN
ASM_REWRITE_TAC[REAL_ARITH` (a + b ) - b = a `] THEN
ASM_MESON_TAC[REAL_EQ_SUB_RADD; REAL_ARITH` (a + b ) - b = a `];
STRIP_TAC THEN EXISTS_TAC ` x - (t:real)` THEN 
ASM_REWRITE_TAC[] THEN GEN_TAC THEN ONCE_REWRITE_TAC
[REAL_ARITH` x = ( x + t ) - t `] THEN DISCH_TAC THEN 
SUBGOAL_THEN ` y + t = (x:real)` ASSUME_TAC THENL 
[ASM_MESON_TAC[]; ASM_REAL_ARITH_TAC]]);;

(* ==================================================================== *)
(* in thms_doing_works.ml *)
(* ==================================================================== *)
(* ==================================================================== *)



 let COND_FOR_EXISTS_ANY_PERI = prove(` &0 < p /\ (!x. f x <=> f (x + p))
/\ (?!x. &0 <= x /\ x < p /\ f x) ==> 
(! t . &0 <= t /\ t < p ==> (?!x. t <= x /\ x < t + p /\ f x)) `,
ASSUME_TAC (SPEC_ALL PERIODIC_AT0_IMP_ANY) THEN ASM_MESON_TAC[]);;



 let IN_ORIGIN_PERIOD_IMP_UNIQUENESS =
prove(` ! x t. &0 <= t /\ t < &2 * pi ==> (?!gg. &0 <= gg /\
gg < &2 * pi /\ cos x = cos ( t + gg )
/\ sin x = sin ( t + gg )) `, REPEAT STRIP_TAC THEN
MP_TAC (ONCE_REWRITE_RULE[REAL_ADD_SYM] (SPEC_ALL SIN_CIRCLE)) THEN 
NHANH SUM_POW2_EQ1_UNIQUE_TRIG THEN STRIP_TAC THEN 
ONCE_REWRITE_TAC[REAL_EXISTS_UNIQUE_TRANSABLE] THEN 
REWRITE_TAC[REAL_SUB_LE; REAL_LT_SUB_RADD; REAL_SUB_ADD2 ] THEN 
ASSUME_TAC SIN_PERIODIC THEN ASSUME_TAC COS_PERIODIC THEN 
MP_TAC PI_POS THEN 
PAT_ONCE_REWRITE_TAC `\x. x ==> _ ` [REAL_ARITH` &0 < a <=>
&0 < &2 * a `] THEN ONCE_REWRITE_TAC[EQ_SYM_EQ] THEN 
ONCE_REWRITE_TAC[REAL_ADD_SYM] THEN 
DISCH_TAC THEN UNDISCH_TAC ` t < &2 * pi ` THEN 
UNDISCH_TAC ` &0 <= t ` THEN PHA THEN 
SPEC_TAC (`t:real`,`t:real`) THEN 
MATCH_MP_TAC COND_FOR_EXISTS_ANY_PERI THEN ASM_MESON_TAC[]);;



let  GIVEN_VALUED_IMP_UNIQUE_EXISTENCE = prove(
 `! x0. (?!x. &0 <= x /\ x < &2 * pi /\ cos x = cos x0 /\
 sin x = sin x0 )`, REPEAT STRIP_TAC THEN 
MP_TAC (ONCE_REWRITE_RULE[REAL_ADD_SYM] SIN_CIRCLE) THEN 
NHANH SUM_POW2_EQ1_UNIQUE_TRIG THEN SIMP_TAC[]);;



let EYFCXPP = prove(` !w u e1 e2 e3 (x1:real ^3 ) x2.
         orthonormal e1 e2 e3 /\
         e3 = &1 / norm (w - u) % (w - u) /\
         ~(x1 IN aff {w, u}) /\
         ~(x2 IN aff {w,u}) /\
         ~(w = u)
         ==> (? r1  r2  phii  ssi  h1  h2.
                  ((&0 <= phii /\
                   phii < &2 * pi /\
                   &0 <= ssi /\ ssi < &2 * pi /\
                   &0 < r1 /\ &0 < r2 /\
                   x1 =
                   u +
                   (r1 * cos phii) % e1 +
                   (r1 * sin phii) % e2 +
                   h1 % (w - u) /\ 
                    x2 =  u +
                   (r2 * cos (phii + ssi )) % e1 +
                   (r2 * sin (phii + ssi )) % e2 +
                   h2 % (w - u))) /\
 (! rr1 rr2 pphii ssii h11 h22.
(&0 <= pphii /\
                   pphii < &2 * pi /\
                   &0 <= ssii /\ ssii < &2 * pi /\
                   &0 < rr1 /\ &0 < rr2 /\
                   x1 =
                   u +
                   (rr1 * cos pphii) % e1 +
                   (rr1 * sin pphii) % e2 +
                   h11 % (w - u) /\ 
                    x2 =  u +
                   (rr2 * cos (pphii + ssii )) % e1 +
                   (rr2 * sin (pphii + ssii )) % e2 +
                   h22 % (w - u)) ==>
rr1 = r1 /\ rr2 = r2 /\ pphii = phii /\
ssii = ssi /\ h11 = h1 /\ h22 = h2 ) )`,
ONCE_REWRITE_TAC[MESON[]` a1 /\a2/\a3/\a4 /\a5 <=>
(a1/\a2/\a3/\a5) /\ a4 `] THEN
NHANH UNIQUE_EXISTSENCE_OF_RPHIH THEN 
ONCE_REWRITE_TAC[MESON[]` (( a1 /\a2/\a3/\a4) /\ss)/\a5 <=>
(a1/\a2/\a5/\a4)/\a3/\ss`] THEN 
NHANH UNIQUE_EXISTSENCE_OF_RPHIH THEN REPEAT STRIP_TAC THEN 
UNDISCH_TAC ` phii' < &2 * pi ` THEN UNDISCH_TAC ` &0 <= phii' ` THEN 
PHA THEN NHANH_PAT `\x. x ==> _ ` (SPEC `phii: real` IN_ORIGIN_PERIOD_IMP_UNIQUENESS)
THEN REWRITE_TAC[EXISTS_UNIQUE] THEN STRIP_TAC THEN 
EXISTS_TAC `r': real` THEN EXISTS_TAC `r:real` THEN 
EXISTS_TAC ` phii': real` THEN EXISTS_TAC `gg: real` THEN 
EXISTS_TAC ` h': real` THEN EXISTS_TAC ` h: real` THEN
ASM_REWRITE_TAC[] THEN REPEAT GEN_TAC THEN REWRITE_TAC[TAUT`
 a /\ b ==> c <=> a ==> b ==> c`] THEN REPEAT DISCH_TAC THEN 
REPLICATE_TAC 3 (FIRST_X_ASSUM MP_TAC) THEN 
UNDISCH_TAC ` (x2: real^3 ) =  u + (r * cos phii) % e1 + 
(r * sin (phii)) % e2 + h % (w - u)` THEN 
UNDISCH_TAC `(x1 : real^3) = u + (r' * cos phii') % e1 + 
(r' * sin phii') % e2 + h' % (w - u)` THEN 
ONCE_REWRITE_TAC[EQ_SYM_EQ] THEN ASM_REWRITE_TAC[] THEN SIMP_TAC[]
THEN REPEAT DISCH_TAC THEN ONCE_REWRITE_TAC[EQ_SYM_EQ] THEN 
ASSUME_TAC2 (UNDISCH (MESON[]`(!rr p hh.  &0 <= p /\ p < &2 * pi /\ &0 < rr /\
          (x1: real^3) = u + (rr * cos p) % e1 + (rr * sin p) % e2 + hh % (w - u)
          ==> rr = r' /\ p = phii' /\ hh = h') ==>
 u + (rr1 * cos pphii) % e1 + (rr1 * sin pphii) % e2 + h11 % (w - u) =
  x1 /\ &0 <= pphii  /\ pphii < &2 * pi /\ &0 < rr1 ==>
rr1 = r' /\ pphii = phii' /\ h11 = h' `)) THEN ASM_REWRITE_TAC[]
THEN REPEAT (FIRST_X_ASSUM (CONJUNCTS_THEN ASSUME_TAC)) THEN 
MP_TAC (SPEC `pphii + (ssii: real)`
 GIVEN_VALUED_IMP_UNIQUE_EXISTENCE) THEN 
REWRITE_TAC[EXISTS_UNIQUE] THEN STRIP_TAC THEN 
UNDISCH_TAC ` (u: real^3) + (rr2 * cos (pphii + ssii)) % e1 +
(rr2 * sin (pphii + ssii)) % e2 + h22 % (w - u) = x2` THEN 
REPLICATE_TAC 3 (FIRST_X_ASSUM MP_TAC) THEN 
ONCE_REWRITE_TAC[EQ_SYM_EQ] THEN SIMP_TAC[] THEN 
PHA THEN STRIP_TAC THEN 
ASSUME_TAC2 ((UNDISCH o MESON[])`(!rr p hh. &0 <= p /\ p < &2 * pi /\  &0 < rr /\
          (x2: real^3) = u + (rr * cos p) % e1 + (rr * sin p) % e2 + hh % (w - u)
          ==> rr = r /\ p = phii /\ hh = h) ==> 
&0 < rr2 /\ &0 <= x /\ x < &2 * pi /\
x2 = u + (rr2 * cos x) % e1 + (rr2 * sin x) % e2 + h22 % (w - u)
==> r = rr2 /\ h = h22 /\ x = phii  `) THEN 
FIRST_ASSUM (fun x -> REWRITE_TAC[ x]) THEN 
USE_FIRST `(pphii: real) = phii' ` SUBST_ALL_TAC THEN 
REPEAT (FIRST_X_ASSUM (CONJUNCTS_THEN ASSUME_TAC)) THEN 
FIRST_X_ASSUM SUBST_ALL_TAC THEN 
ELIM_IDENTS ((UNDISCH o MESON[])`(!y. &0 <= y /\
y < &2 * pi /\  cos phii = cos (phii' + y) /\
 sin phii = sin (phii' + y) ==> y = gg) ==>  
cos (phii' + ssii) = cos phii /\
sin (phii' + ssii) = sin phii /\ &0 <= ssii /\ ssii < &2 * pi 
==> gg = ssii `));;



(* ========================== *)
(* ========================== *)


let INTERGRAL_UNIONS_INTERVALS = 
prove(`! N. UNIONS {{x | &(n - 1) <= x /\ x < &n} | 0 < n /\ n <= N} =
 {x | &0 <= x /\ x < &N}`, INDUCT_TAC THENL 
[REWRITE_TAC[ARITH_RULE`~( 0 < b /\ b <= 0 )`; REAL_ARITH`~( &0 <= x /\ x < &0 )`] THEN 
SET_TAC[];
REWRITE_TAC[ARITH_RULE`0 < n /\ n <= SUC N <=> 0 < n /\ n <= N \/ n = N + 1`; SET_RULE` UNIONS 
{ f x | h x \/ x = N} = ( UNIONS { f x | h x }) UNION ( f N ) `] THEN 
REWRITE_TAC[ADD1; GSYM REAL_OF_NUM_ADD; REAL_ARITH` &0 <= x /\ x < &N + &1 <=>
&0 <= x /\ x < &N \/ &N <= x /\ x < &N + &1 `] THEN 
ASM_SIMP_TAC[ARITH_RULE` (a + 1) - 1 = a `] THEN SET_TAC[]]);;


let NOT_EQ_IMP_EXISTS_BASIC = new_axiom `! v (w:real^3). ~( v = w ) ==> 
  (? e1 e2 e3. orthonormal e1 e2 e3 /\ dist (w,v) % e3 = w - v)`;;


let REAL_LE_EQ_OR_LT = REAL_ARITH` &0 <= a <=> a = &0 \/ &0 < a `;;


let EXISTS_IN_UNIT_INTERVAL = prove(`!x. ?n. &0 <= x + real_of_int n /\ x + real_of_int n < &1`,
MATCH_MP_TAC (MESON[REAL_ARITH` &0 <= a \/ &0 <= -- a `]` (! a. P a ==> P ( -- a ))
/\ (! a. &0 <= a ==> P a ) /\ (! a. a = -- ( -- a )) ==> (! a . P a )`) THEN CONJ_TAC THENL [
GEN_TAC THEN REWRITE_TAC[REAL_LE_EQ_OR_LT ] THEN STRIP_TAC THENL [
EXISTS_TAC ` -- (n:int)` THEN 
ASM_REWRITE_TAC[int_neg_th; GSYM REAL_NEG_ADD; REAL_NEG_EQ_0] THEN REAL_ARITH_TAC;
EXISTS_TAC ` -- n + (&1: int)` THEN 
ASM_REWRITE_TAC[int_neg_th; GSYM REAL_NEG_ADD; REAL_NEG_EQ_0;int_add_th; int_of_num_th]
THEN ASM_REAL_ARITH_TAC];REWRITE_TAC[REAL_NEGNEG] THEN GEN_TAC THEN 
CHOOSE_TAC (SPEC `x: real` (MATCH_MP REAL_ARCH (REAL_ARITH` &0 < &1 `))) THEN 
ASSUME_TAC (SPEC `n: num ` INTERGRAL_UNIONS_INTERVALS) THEN 
DOWN_TAC THEN REWRITE_TAC[REAL_MUL_RID] THEN 
NHANH (SET_RULE` x < &n /\ aa =   {x | &0 <= x /\ x < &n} /\
   &0 <= x ==> x IN aa `) THEN REWRITE_TAC[IN_UNIONS; IN_ELIM_THM] THEN  
STRIP_TAC THEN EXISTS_TAC` -- ( &(n' - 1): int) ` THEN 
REPLICATE_TAC 2 (FIRST_X_ASSUM MP_TAC) THEN 
PHA THEN NHANH (SET_RULE` t = {x| P x } /\ x IN t ==> P x `) THEN 
REWRITE_TAC[int_neg_th; int_of_num_th] THEN STRIP_TAC THEN 
REPLICATE_TAC 2 (FIRST_X_ASSUM MP_TAC) THEN 
ASSUME_TAC2 (ARITH_RULE` 0 < n' ==> 1 <= n'`) THEN 
ASM_SIMP_TAC[GSYM REAL_OF_NUM_SUB] THEN REAL_ARITH_TAC]);;

let TWO_PI_POS = prove(` &0 < &2 * pi `, MP_TAC PI_POS THEN REAL_ARITH_TAC);;


let MOVE_TO_UNIT_INTERVAL = prove(`!x. ?n. &0 <= x + ( real_of_int n )* &2 * pi /\ x + ( real_of_int n) * &2 * pi  < &2 * pi`,
ONCE_REWRITE_TAC [GSYM (MATCH_MP REAL_LE_RDIV_0 TWO_PI_POS)] THEN 
ONCE_REWRITE_TAC[GSYM (MATCH_MP REAL_LT_DIV2_EQ TWO_PI_POS)] THEN 
REWRITE_TAC[REAL_ARITH` ( a + b ) / c = a / c + b / c  `; MATCH_MP (REAL_FIELD` &0 < a ==> a / a = &1 `) TWO_PI_POS;
  MATCH_MP (REAL_FIELD` &0 < c ==> (a * c ) / c = a `) TWO_PI_POS] THEN MESON_TAC[EXISTS_IN_UNIT_INTERVAL ]);;


let SIN_TOTAL_PERIODIC = prove(`! n. sin (x + &n * &2 * pi) = sin x `,
INDUCT_TAC THEN REWRITE_TAC[REAL_MUL_LZERO; REAL_ADD_RID] THEN 
ASM_REWRITE_TAC[ADD1;GSYM REAL_OF_NUM_ADD; 
REAL_ARITH` x + (&n + &1) * a = (x + &n * a ) + a `; SIN_PERIODIC]);;


let SIN_PERIODIC_IN_WHOLE = prove(` !n. sin ( x + real_of_int n * &2 * pi ) = sin x `,
GEN_TAC THEN ASM_CASES_TAC` &0 <= (n: int) ` THENL [
ASSUME_TAC2 (SPEC `n: int ` INT_OF_NUM_OF_INT) THEN EXPAND_TAC "n" THEN 
REWRITE_TAC[int_of_num_th; SIN_TOTAL_PERIODIC ]; FIRST_X_ASSUM MP_TAC] THEN 
NHANH (ARITH_RULE` ~( &0 <= (n: int) ) ==> &0 <= -- n `) THEN STRIP_TAC THEN 
ASSUME_TAC2 (SPEC `-- n: int ` INT_OF_NUM_OF_INT) THEN 
ONCE_REWRITE_TAC[ARITH_RULE` (a: int) = -- -- a `] THEN 
ONCE_REWRITE_TAC[int_neg_th] THEN FIRST_X_ASSUM (SUBST1_TAC o SYM) THEN 
REWRITE_TAC[int_of_num_th; REAL_MUL_LNEG] THEN 
MESON_TAC[SIN_TOTAL_PERIODIC; REAL_ARITH`(a + -- b ) + (b:real) = a `]);;



let COS_PERIODIC_IN_WHOLE = prove(` cos ( x + real_of_int n * &2 * pi ) = cos x `,
REWRITE_TAC[COS_SIN; REAL_ARITH` a - (b + c ) = a - b - c `] THEN 
MESON_TAC[REAL_ARITH` x = x - y + y `; SIN_PERIODIC_IN_WHOLE]);;


let SIN_COS_PERIODIC_IN_WHOLE = 
  GEN_ALL (CONJ (SPEC_ALL SIN_PERIODIC_IN_WHOLE) COS_PERIODIC_IN_WHOLE);;


let SIN_COS_IDEN_IFF_DIFFER_PERS = prove(`! x y. cos x = cos y /\ sin x = sin y <=> (? k. x = y + real_of_int k * &2 * pi ) `,
REPEAT GEN_TAC THEN EQ_TAC THENL [CHOOSE_TAC (SPEC` x:real` MOVE_TO_UNIT_INTERVAL ) THEN 
CHOOSE_TAC (SPEC` y:real` MOVE_TO_UNIT_INTERVAL ) THEN 
ASSUME_TAC (GSYM (SPECL[`n:int`;`x:real`] SIN_COS_PERIODIC_IN_WHOLE)) THEN 
FIRST_X_ASSUM (fun x -> PAT_ONCE_REWRITE_TAC`\x. x = _ /\ x = _ ==> _ ` [x]) THEN 
ASSUME_TAC (GSYM (SPECL[`n':int`;`y:real`] SIN_COS_PERIODIC_IN_WHOLE)) THEN 
FIRST_X_ASSUM (fun x -> PAT_ONCE_REWRITE_TAC `\x. _ = x /\ _ = x ==> _ ` [x]) THEN 
DOWN_TAC THEN NHANH IDENT_WHEN_IDENT_SIN_COS THEN 
REWRITE_TAC[REAL_ARITH`y + a * t = x + b * t <=> x = y + (a -b ) * t`; GSYM int_sub_th] THEN 
STRIP_TAC THEN EXISTS_TAC ` n' - (n:int)` THEN ASM_REWRITE_TAC[];
STRIP_TAC THEN ASM_SIMP_TAC[SIN_COS_PERIODIC_IN_WHOLE ]]);;


let NOT_EQ_IMP_AFF_AND_COLL3 = prove(`! v (w:real^N) u. ~( v = w ) ==> 
( u IN aff {v,w} <=> collinear {v,w,u}) `, ONCE_REWRITE_TAC[COLLINEAR_3] THEN 
REWRITE_TAC[COLLINEAR_LEMMA; VECTOR_SUB_EQ] THEN SIMP_TAC[] THEN REPEAT STRIP_TAC THEN 
MATCH_MP_TAC (MESON[]` (P ==> Q) /\ (Q <=> L) ==> (L <=> P \/ Q)`) THEN CONJ_TAC THENL [
STRIP_TAC THEN EXISTS_TAC `&0` THEN 
ASM_REWRITE_TAC[VECTOR_MUL_LZERO; VECTOR_SUB_REFL]; REWRITE_TAC[AFF2; IN_ELIM_THM] THEN 
EQ_TAC THENL [STRIP_TAC THEN EXISTS_TAC `c:real` THEN FIRST_X_ASSUM MP_TAC THEN 
VECTOR_ARITH_TAC; STRIP_TAC THEN EXISTS_TAC `t:real` THEN FIRST_X_ASSUM MP_TAC THEN 
VECTOR_ARITH_TAC]]);;

let R_SIN_CIRCLE = prove(` ! r x. ( r * cos x ) pow 2 + ( r * sin x ) pow 2 = r pow 2 `,
REPEAT GEN_TAC THEN MP_TAC (SPEC_ALL SIN_CIRCLE) THEN CONV_TAC REAL_RING);;


let R_SIN_COS_IDENT = prove(`! r rr x y. &0 <= r /\ &0 <= rr /\
r * cos x = rr * cos y /\ r * sin x = rr * sin y ==> r = rr /\ (
r = &0 \/ cos x = cos y /\ sin x = sin y ) `,
NHANH (MESON[R_SIN_CIRCLE ]`r * cos x = rr * cos y /\ r * sin x = rr * sin y ==>
  r pow 2 = rr pow 2 `) THEN REPEAT GEN_TAC THEN STRIP_TAC THEN 
SUBGOAL_THEN `r = (rr: real)` ASSUME_TAC THENL [ASM_SIMP_TAC[EQ_POW2_COND];
ASM_SIMP_TAC[]] THEN ASM_CASES_TAC ` rr = &0 ` THENL [ASM_SIMP_TAC[]; DISJ2_TAC] THEN 
FIRST_X_ASSUM SUBST_ALL_TAC THEN DOWN_TAC THEN 
REWRITE_TAC[REAL_EQ_MUL_LCANCEL] THEN MESON_TAC[]);;


let R_POS_SIN_COS_IDENT = prove(`! r rr x y. &0 < r /\ &0 < rr /\
r * cos x = rr * cos y /\ r * sin x = rr * sin y ==> r = rr /\
 cos x = cos y /\ sin x = sin y  `,
MESON_TAC[REAL_LT_IMP_LE; R_SIN_COS_IDENT; REAL_ARITH` &0 < a ==> ~( a = &0 )`]);;


let BEGIN_POINT_PERIODIC = prove(` ! x k. &0 <= x /\ x < &2 * pi /\ x = real_of_int k * &2 * pi ==> x = &0 `,
REPEAT GEN_TAC THEN ASSUME_TAC (SPEC` &0` REAL_LE_REFL) THEN ASSUME_TAC TWO_PI_POS THEN 
STRIP_TAC THEN FIRST_X_ASSUM MP_TAC THEN 
PAT_ONCE_REWRITE_TAC `\x. _ = x ==> _` [REAL_ARITH` a = &0 + a `] THEN 
ASM_MESON_TAC[SIN_COS_PERIODIC_IN_WHOLE; IDENT_WHEN_IDENT_SIN_COS]);;


let BODE_YEU_ANH_DI = prove(`! k. &0 <= ppsssi /\ ppsssi < &2 * pi /\
&0 <= ppsssi1 /\ ppsssi1 < &2 * pi /\ &0 <= aa /\
 aa < &2 * pi /\
  aa = ppsssi - ppsssi1 + real_of_int k * &2 * pi ==>
  ( aa = &0 <=> ppsssi = ppsssi1 ) `,
REPEAT STRIP_TAC THEN 
EQ_TAC THENL [ASM_REWRITE_TAC[] THEN REWRITE_TAC[REAL_ARITH` a - b + c = &0 <=> b = a + c `]
THEN ASM_MESON_TAC[IDENT_WHEN_IDENT_SIN_COS; SIN_COS_IDEN_IFF_DIFFER_PERS]; 
DISCH_THEN SUBST_ALL_TAC THEN DOWN_TAC THEN REWRITE_TAC[REAL_SUB_REFL; REAL_ADD_LID] THEN 
MESON_TAC[BEGIN_POINT_PERIODIC ]]);;

(* ----------------------------- *)
(* 19 Aug, 2009 *)
let YVREJIS = prove(`! (v: real^3) w w1 w2.
     cyclic_set {w1, w2} v w
     ==> (azim v w w1 w2 = &0 ==> azim v w w1 w2 + azim v w w2 w1 = &0) /\
         (~(azim v w w1 w2 = &0)
          ==> azim v w w1 w2 + azim v w w2 w1 = &2 * pi)`,
REWRITE_TAC[cyclic_set] THEN 
NHANH NOT_EQ_IMP_EXISTS_BASIC THEN 
REPEAT GEN_TAC THEN STRIP_TAC THEN 
ASSUME_TAC (SPECL[`v:real^3`;` w:real^3`] azim ) THEN 
ASM_REWRITE_TAC[] THEN FIRST_ASSUM (ASSUME_TAC o SPEC_ALL) THEN 
FIRST_X_ASSUM MP_TAC THEN STRIP_TAC THEN 
UNDISCH_TAC `~(v = w:real^3)` THEN 
UNDISCH_TAC `dist (w,v) % e3 = w - (v:real^3)` THEN 
UNDISCH_TAC `orthonormal e1 e2 e3` THEN PHA THEN 
ONCE_REWRITE_TAC[MESON[]`~(a = b ) <=> ~( b = a )`] THEN 
FIRST_ASSUM NHANH THEN FIRST_X_ASSUM MP_TAC THEN 
FIRST_X_ASSUM (ASSUME_TAC o (SPECL[`w2:real^3`;` w1:real^3`])) THEN 
REPEAT (FIRST_X_ASSUM (CONJUNCTS_THEN ASSUME_TAC)) THEN 
REPEAT (FIRST_X_ASSUM CHOOSE_TAC) THEN 
FIRST_ASSUM (NHANH_PAT `\x. _ ==> x `) THEN 
STRIP_TAC THEN STRIP_TAC THEN UNDISCH_TAC `w1 - v =
      (r2 * cos (psi + azim v w w2 w1)) % e1 +
      (r2 * sin (psi + azim v w w2 w1)) % e2 +
      h2' % (w - v)` THEN 
UNDISCH_TAC `w1 - (v: real^3) = (r1' * cos psi') % e1 + 
  (r1' * sin psi') % e2 + h1 % (w - v)` THEN 
USE_FIRST ` dist (w,v) % e3 = w - (v:real^3)` (SUBST1_TAC o SYM) THEN 
UNDISCH_TAC `orthonormal e1 e2 (e3: real^3)` THEN PHA THEN 
REWRITE_TAC[VECTOR_MUL_ASSOC] THEN 
NHANH (MESON[th]` orthonormal e1 e2 e3 /\ x = a1 % e1 + a2 % e2 + a3 % e3 /\
  x = aa1 %e1 + aa2 % e2 + aa3 % e3 ==> a1 = aa1 /\ a2 = aa2 /\ a3 = aa3 `) THEN 
STRIP_TAC THEN 
UNDISCH_TAC` w2 - (v: real^3) = (r1 * cos psi) % e1 + (r1 * sin psi) % e2 + h1' % (w - v)` THEN 
UNDISCH_TAC` w2 - v =
      (r2' * cos (psi' + azim v w w1 w2)) % e1 +
      (r2' * sin (psi' + azim v w w1 w2)) % e2 +  h2 % (w - v)` THEN 
UNDISCH_TAC `orthonormal e1 e2 (e3: real^3)` THEN 
USE_FIRST ` dist (w,v) % e3 = w - (v:real^3)` (SUBST1_TAC o SYM) THEN 
REWRITE_TAC[VECTOR_MUL_ASSOC] THEN PHA THEN 
NHANH (MESON[th]` orthonormal e1 e2 e3 /\ x = a1 % e1 + a2 % e2 + a3 % e3 /\
  x = aa1 %e1 + aa2 % e2 + aa3 % e3 ==> a1 = aa1 /\ a2 = aa2 /\ a3 = aa3 `) THEN STRIP_TAC THEN 
UNDISCH_TAC`{w1, w2} INTER affine hull {(v: real^3), w} = {}` THEN 
REWRITE_TAC[ GSYM aff; SET_RULE` {a,b} INTER s = {} <=> ~( a IN s ) /\ ~( b IN s ) `] THEN 
UNDISCH_TAC `~(w = (v:real^3))` THEN 
SIMP_TAC[EQ_SYM_EQ; NOT_EQ_IMP_AFF_AND_COLL3] THEN 
STRIP_TAC THEN STRIP_TAC THEN 
ASSUME_TAC2 (MESON[]`~collinear {v, w, w2} /\ (~collinear {(v:real^3), w, w2} ==> &0 < r1) ==>
  &0 < r1 `) THEN 
ASSUME_TAC2 (MESON[]`~collinear {v, w, w2} /\ (~collinear {(v:real^3), w, w2} ==> &0 < r2') ==>
  &0 < r2' `) THEN 
ASSUME_TAC2 (MESON[]`~collinear {v, w, w1} /\ (~collinear {(v:real^3), w, w1} ==> &0 < r1') ==>
  &0 < r1' `) THEN 
ASSUME_TAC2 (MESON[]`~collinear {v, w, w1} /\ (~collinear {(v:real^3), w, w1} ==> &0 < r2) ==>
  &0 < r2 `) THEN 
UNDISCH_TAC` r2' * sin (psi' + azim (v: real^3) w w1 w2) = r1 * sin psi` THEN 
UNDISCH_TAC`r2' * cos (psi' + azim v w w1 w2) = r1 * cos psi` THEN 
UNDISCH_TAC`&0 < r1` THEN UNDISCH_TAC`&0 < r2'` THEN PHA THEN 
NHANH R_POS_SIN_COS_IDENT  THEN 
REWRITE_TAC[SIN_COS_IDEN_IFF_DIFFER_PERS ] THEN STRIP_TAC THEN 
UNDISCH_TAC` r1' * sin psi' = r2 * sin (psi + azim v w w2 w1)` THEN 
UNDISCH_TAC` r1' * cos psi' = r2 * cos (psi + azim v w w2 w1)` THEN 
UNDISCH_TAC` &0 < r2 ` THEN UNDISCH_TAC` &0 < r1' ` THEN 
PHA THEN NHANH R_POS_SIN_COS_IDENT  THEN 
REWRITE_TAC[SIN_COS_IDEN_IFF_DIFFER_PERS ] THEN STRIP_TAC THEN 
CHOOSE_TAC (SPEC` psi: real` MOVE_TO_UNIT_INTERVAL ) THEN 
CHOOSE_TAC (SPEC` psi': real` MOVE_TO_UNIT_INTERVAL ) THEN 
SUBST_ALL_TAC (REWRITE_RULE[GSYM int_add_th;GSYM int_sub_th] (REAL_ARITH` psi' + azim v w w1 w2 = psi + real_of_int k * &2 * pi <=>
  azim v w w1 w2 = ( psi + real_of_int n * &2 * pi) - ( psi' + real_of_int n' * &2 * pi)
  + (real_of_int k + real_of_int n' - real_of_int n )* &2 * pi `)) THEN 
SUBST_ALL_TAC (REWRITE_RULE[GSYM int_add_th;GSYM int_sub_th] (REAL_ARITH` psi' = (psi + azim v w w2 w1) + real_of_int k' * &2 * pi <=>
  azim v w w2 w1 = (psi' + real_of_int n' * &2 * pi) - (psi + real_of_int n * &2 * pi)
  + (real_of_int n - real_of_int k' - real_of_int n') * &2 * pi `)) THEN 
ABBREV_TAC ` ppsssi = psi + real_of_int n * &2 * pi ` THEN 
ABBREV_TAC ` ppsssi1 = psi' + real_of_int n' * &2 * pi ` THEN 
REPEAT (FIRST_X_ASSUM (CONJUNCTS_THEN ASSUME_TAC)) THEN 
ASSUME_TAC2 (SPECL [` azim v w w1 w2 `;` k + n' - (n: int) `] (GEN `aa: real` BODE_YEU_ANH_DI)) THEN 
REWRITE_TAC[MESON[]` a = b ==> b + c = &0 <=> a = b ==> a + c = &0`] THEN 
FIRST_X_ASSUM SUBST1_TAC THEN 
UNDISCH_TAC `azim v w w2 w1 = ppsssi1 - ppsssi + real_of_int (n - k' - n') * &2 * pi` THEN 
UNDISCH_TAC `azim v w w1 w2 = ppsssi - ppsssi1 + real_of_int (k + n' - n) * &2 * pi` THEN 
UNDISCH_TAC` azim v w w2 w1 < &2 * pi ` THEN 
UNDISCH_TAC` &0 <= azim v w w2 w1  ` THEN UNDISCH_TAC` azim v w w1 w2 < &2 * pi ` THEN 
UNDISCH_TAC` &0 <= azim v w w1 w2 ` THEN UNDISCH_TAC` ppsssi1 < &2 * pi `  THEN 
UNDISCH_TAC`&0 <= ppsssi1  `  THEN UNDISCH_TAC` ppsssi < &2 * pi `  THEN 
UNDISCH_TAC`&0 <= ppsssi  `  THEN PHA THEN 
REWRITE_TAC[REWRITE_RULE[REAL_ARITH` &2 * a * b = b * &2 * a `] PDPFQUK]);;

(* ====================== *)
(* ====================== *)
(* ========= LEMMA 1.31 =========== *)




let ORTHONORMAL_BASIS = prove(
` orthonormal ( basis 1 ) (basis 2 ) ( basis 3 ) `,
MP_TAC (MESON[DOT_BASIS_BASIS]`! i j. 1 <= i /\ i <= dimindex (:3) /\ 1 <= j /\ j <= dimindex (:3)
           ==> ((basis i): real^3) dot basis j = (if i = j then &1 else &0)`) THEN 
REWRITE_TAC[orthonormal; DIMINDEX_3; ARITH_RULE` 1 <= i /\ i <= 3 <=> i = 1 \/ i = 2 \/ i = 3 `] THEN 
NGOAC THEN 
REWRITE_TAC[ARITH_RULE` 1 <= i /\ i <= 3 <=> i = 1 \/ i = 2 \/ i = 3 `] THEN 
KHANANG THEN 
REWRITE_TAC[TAUT`(a \/ v) \/ c <=> a \/ v \/ c `] THEN 
SIMP_TAC[TAUT`(a \/ v) \/ c <=> a \/ v \/ c `; MESON[]`(! i j. i = a /\ j = b \/ Q i j ==> R i j)
  <=> R a b /\ (! i j. Q i j ==> R i j)`; ARITH_RULE` ~(1 = 2 )/\ ~( 1 = 3 ) /\ ~( 2 = 3 )` ] THEN 
STRIP_TAC THEN 
FIRST_X_ASSUM (MP_TAC o (SPECL[` 3`;`3`])) THEN 
SIMP_TAC[] THEN 
SIMP_TAC[CROSS_BASIS; REAL_ARITH` &0 < &1 `]);;



let ORTHO_IMP_NORM_CROSS_PRODUCT = 
prove(`! x y. x dot y = &0 ==> norm (x cross y) pow 2 = (norm x * norm y) pow 2 `,
REPEAT STRIP_TAC THEN MP_TAC (SPEC_ALL NORM_CROSS_DOT) THEN 
ASM_SIMP_TAC[REAL_ARITH` a + &0 pow 2 = a `]);;


let TWO_UNIT_ORTH_VECTORS_IMP_ORTHONORMAL = prove(`! e1 (e3:real^3). norm e1 = &1 /\ norm e3 = &1 /\ e1 dot e3 = &0 ==> (? e2.
orthonormal e1 e2 e3 ) `,
REPEAT STRIP_TAC THEN 
EXISTS_TAC ` e3 cross e1 ` THEN 
ASM_SIMP_TAC[DOT_CROSS_SELF; orthonormal; CROSS_LAGRANGE; DOT_LSUB;
 DOT_LMUL; DOT_SQUARE_NORM; DOT_SYM] THEN 
ASM_SIMP_TAC[DOT_RSUB; DOT_RMUL; GSYM NORM_POW_2; DOT_SYM] THEN 
FIRST_X_ASSUM (MP_TAC o (ONCE_REWRITE_RULE[DOT_SYM])) THEN 
NHANH ORTHO_IMP_NORM_CROSS_PRODUCT THEN 
ASM_SIMP_TAC[] THEN 
REAL_ARITH_TAC);;

let ORTHONORMAL_BASIS3 = REWRITE_RULE[orthonormal] ORTHONORMAL_BASIS;;

let EXISTS_OTHOR_VECTOR_DIFFF_VEC0 = prove(
`! (u: real^3). ? v . ~(v = vec 0) /\ u dot v = &0 `,
GEOM_BASIS_MULTIPLE_TAC 1 `u:real^3` THEN REPEAT STRIP_TAC THEN 
EXISTS_TAC `( basis 2): real^3` THEN MP_TAC ORTHONORMAL_BASIS THEN 
SIMP_TAC[orthonormal; DOT_LMUL; REAL_MUL_RZERO; 
REWRITE_RULE[DE_MORGAN_THM] NOT_BASISES_EQ_VEC0]);;

let INVERT_NORM_POS_LE = prove(` ! (x: real^N). &0 <= &1 / norm x `,
GEN_TAC THEN MATCH_MP_TAC REAL_LE_DIV THEN REWRITE_TAC[NORM_POS_LE] THEN REAL_ARITH_TAC);;

let NOT_0_INVERTABLE = REAL_FIELD` ~( a = &0) <=> &1 / a * a = &1 `;;


let NOT_VEC0_UNITABLE = prove(`! (u: real^N). ~( u = vec 0 ) <=> norm ( &1 / norm u % u ) = &1 `,
SIMP_TAC[NORM_MUL; REAL_ABS_DIV; REAL_ABS_NORM; ABS_1; GSYM NORM_EQ_0; NOT_0_INVERTABLE]);;


let EXISTS_UNIT_OTHOR_VECTOR = prove(` !(u: real^3). ?v. norm v = &1 /\ u dot v = &0 `,
GEN_TAC THEN (CHOOSE_TAC (SPEC` u:real^3 ` EXISTS_OTHOR_VECTOR_DIFFF_VEC0)) THEN 
EXISTS_TAC ` &1 / norm v % ( v:real^3) ` THEN ASM_SIMP_TAC[GSYM NOT_VEC0_UNITABLE; DOT_RMUL; REAL_MUL_RZERO]);;



let  AFF3_TRANSLATION_IMAGE = prove(
` aff (IMAGE (\x. (v:real^N) + x) {v1, v2, v3}) = IMAGE (\x. v + x) ( aff {v1,v2,v3} ) `,
REWRITE_TAC[IMAGE_CLAUSES; aff; AFFINE_HULL_3; FUN_EQ_THM; IN_ELIM_THM] THEN 
GEN_TAC THEN EQ_TAC THENL [PAT_ONCE_REWRITE_TAC ` \x. _ ==> x ` [GSYM IN] THEN 
STRIP_TAC THEN REWRITE_TAC[IN_ELIM_THM; IN_IMAGE] THEN 
EXISTS_TAC ` u % v1 + v' % v2 + w % (v3:real^N)` THEN 
CONJ_TAC THENL [DOWN_TAC THEN SIMP_TAC[REAL_ARITH` a + b = &1 <=> a = &1 - b `] 
THEN DISCH_TAC THEN VECTOR_ARITH_TAC; ASM_MESON_TAC[]]; 
PAT_ONCE_REWRITE_TAC ` \x. x ==> _ ` [GSYM IN]] THEN 
REWRITE_TAC[IN_IMAGE; IN_ELIM_THM] THEN STRIP_TAC THEN EXISTS_TAC `u:real` THEN 
EXISTS_TAC `v':real` THEN EXISTS_TAC `w:real` THEN 
ASM_SIMP_TAC[VECTOR_ARITH` u % (v + v1) + v' % (v + v2) + w % (v + v3) = (u + v' + w ) % v +
  u % v1 + v' % v2 + w % v3 `; VECTOR_MUL_LID]);;


let IMAGE_INTER_AFF3 = prove(`IMAGE (\x. (v:real^N) + x) s INTER aff (IMAGE (\x. v + x) {v1,v2,v3}) =
 IMAGE (\x. v + x) (s INTER aff {v1,v2,v3})`,
SUBGOAL_THEN ` ! x y. (\x. (v:real^N) + x) y = (\x. v + x) x ==> y = x ` MP_TAC THENL [
REWRITE_TAC[BETA_THM; VECTOR_ARITH` a + b = a + c ==> b = (c:real^N)`];
SIMP_TAC[AFF3_TRANSLATION_IMAGE; GSYM IMAGE_INTER_INJ]]);;


let DIHV_TRASABLE = prove(`! (v: real^N). dihV (v + u) (v + w) (v + v1) (v + v2) = dihV u w v1 v2`,
REWRITE_TAC[dihV; VECTOR_ARITH` ((v:real^N) + v1) - (v + u) = v1 - u `]);;


let VECTOR_MUL_R_TO_L = REWRITE_RULE[IMP_IMP] (prove(`!a (x:real^N) y. ~(a = &0) ==> a % x = y ==> x = &1 / a % y`,
REPEAT STRIP_TAC THEN MATCH_MP_TAC VECTOR_MUL_LCANCEL_IMP THEN EXISTS_TAC `a :real` THEN 
ASM_SIMP_TAC[VECTOR_MUL_ASSOC; REAL_FIELD` ~( a = &0) ==> ( a * &1 / a ) = &1 `
  ; VECTOR_MUL_LID]));;


let AFF2_VEC0 = prove(` aff {vec 0, (w: real^N)} = { x | ? k. x = k % w }`,
REWRITE_TAC[AFF2; FUN_EQ_THM; IN_ELIM_THM] THEN 
GEN_TAC THEN EQ_TAC THENL [STRIP_TAC THEN EXISTS_TAC ` &1 - t ` THEN 
EVERY_ASSUM MP_TAC THEN SIMP_TAC[VECTOR_MUL_RZERO; VECTOR_ADD_LID];
STRIP_TAC THEN EXISTS_TAC ` &1 - k ` THEN 
ASM_SIMP_TAC[VECTOR_MUL_RZERO; VECTOR_ADD_LID; REAL_ARITH` a - ( a - b ) = b `]]);;


let PERPENCULAR_PART_IDENT0 = prove(`~(w = vec 0) /\ (w dot w) % v1 - (v1 dot w) % w = vec 0
 ==> v1 IN aff {vec 0, w}`, PAT_REWRITE_TAC `\x. x /\ _ ==> _ `[GSYM DOT_EQ_0] THEN 
REWRITE_TAC[VECTOR_SUB_EQ] THEN NHANH (VECTOR_MUL_R_TO_L) THEN 
REWRITE_TAC[AFF2_VEC0; IN_ELIM_THM; VECTOR_MUL_ASSOC] THEN MESON_TAC[]);;


let INSERT_INTER_EMPTY = SET_RULE` {} INTER s = {} /\ (( a INSERT s ) INTER ss = {} <=>
  ~( a IN ss ) /\ s INTER ss = {} )`;;

(* 

Hi Truong,

There is a related theorem AZIM_SPECIAL_SCALE already there in
"Multivariate/flyspeck.ml". This only covers scaling of one of the
arguments, but the proof can be generalized to handle all of them;
see the proof script below.

Since the definition of "azim" has multiple quantifier alternations, I
handle things in a more automatic way using the same quantifier
modification conversion PARTIAL_EXPAND_QUANTS_CONV that is used inside
the "without loss of generality" tactics.

John.



let COLLINEAR_SCALE_ALL = prove
 (`!a b v w. ~(a = &0) /\ ~(b = &0)
            ==> (collinear {vec 0,a % v,b % w} <=> collinear {vec 0,v,w})`,
 REPEAT STRIP_TAC THEN ASM_SIMP_TAC[COLLINEAR_SPECIAL_SCALE] THEN
 ONCE_REWRITE_TAC[SET_RULE `{a,b,c} = {a,c,b}`] THEN
 ASM_SIMP_TAC[COLLINEAR_SPECIAL_SCALE]);;

let AZIM_SCALE_ALL = prove
 (`!a v w1 w2.
       &0 < a /\ &0 < b /\ &0 < c
       ==> azim (vec 0) (a % v) (b % w1) (c % w2) = azim (vec 0) v w1 w2`,
 let lemma = MESON[REAL_LT_IMP_NZ; REAL_DIV_LMUL]
  `!a. &0 < a ==> (!y. ?x. a * x = y)` in
 let SCALE_QUANT_TAC side asm avoid =
   MP_TAC(MATCH_MP lemma (ASSUME asm)) THEN
   DISCH_THEN(MP_TAC o MATCH_MP QUANTIFY_SURJECTION_THM) THEN
   DISCH_THEN(CONV_TAC o side o PARTIAL_EXPAND_QUANTS_CONV avoid) in
 REPEAT STRIP_TAC THEN
 ASM_SIMP_TAC[azim_def; COLLINEAR_SCALE_ALL; REAL_LT_IMP_NZ] THEN
 COND_CASES_TAC THEN ASM_REWRITE_TAC[VECTOR_SUB_RZERO] THEN
 ASM_SIMP_TAC[DIST_0; NORM_MUL; GSYM VECTOR_MUL_ASSOC] THEN
 ASM_SIMP_TAC[REAL_ARITH `&0 < a ==> abs a = a`; VECTOR_MUL_LCANCEL] THEN
 ASM_SIMP_TAC[VECTOR_MUL_EQ_0; REAL_LT_IMP_NZ] THEN
 SCALE_QUANT_TAC RAND_CONV `&0 < a`  ["psi"; "r1"; "r2"] THEN
 SCALE_QUANT_TAC LAND_CONV `&0 < b`  ["psi"; "h2"; "r2"] THEN
 SCALE_QUANT_TAC LAND_CONV `&0 < c`  ["psi"; "h1"; "r1"] THEN
 ASM_SIMP_TAC[GSYM VECTOR_MUL_ASSOC; GSYM VECTOR_ADD_LDISTRIB;
              VECTOR_MUL_LCANCEL; REAL_LT_IMP_NZ; REAL_LT_MUL_EQ] THEN
 REWRITE_TAC[VECTOR_MUL_ASSOC; REAL_MUL_AC]);;

let AZIM_SCALE_INV_NORM = prove
 (`!w v1 v2.
       ~(w = vec 0) /\ ~(v1 = vec 0) /\ ~(v2 = vec 0)
       ==> azim (vec 0) w v1 v2 =
           azim (vec 0) (&1 / norm w % w) (&1 / norm v1 % v1)
                        (&1 / norm v2 % v2)`,
 REWRITE_TAC[real_div; REAL_MUL_LID] THEN
 SIMP_TAC[REAL_LT_INV_EQ; NORM_POS_LT; AZIM_SCALE_ALL]);;

*)



let ARCV_VEC0_ABS = prove(` ~(ku = &0) /\ ~( kv = &0 ) ==> arcV (vec 0) (u: real^N) v = 
arcV (vec 0) ( abs ku % u ) (abs kv % v)`, STRIP_TAC THEN 
ABBREV_TAC ` ahah = arcV (vec 0) (abs ku % (u: real^N)) (abs kv % v) ` THEN 
FIRST_X_ASSUM (fun x -> ONCE_REWRITE_TAC[MATCH_MP WHEN_K_DIFF0_ARCV x]) THEN 
ONCE_REWRITE_TAC[ARC_SYM] THEN FIRST_X_ASSUM (fun x -> ONCE_REWRITE_TAC[MATCH_MP WHEN_K_DIFF0_ARCV x])
 THEN EXPAND_TAC "ahah" THEN SIMP_TAC[ARC_SYM]);;

let WHEN_A_B_POS_ARCV_STABLE = MESON[ARC_SYM; WHEN_K_POS_ARCV_STABLE]
 ` ! a b (x: real^N) y. &0 < a /\ &0 < b ==> arcV ( vec 0 ) x y = arcV ( vec 0 ) ( a % x ) ( b % y ) `;;

let THREE_POS_IMP_DIHV_STABLE = prove(`!x y z.
     &0 < a /\ &0 < b /\ &0 < c
     ==> dihV (vec 0) x y z = dihV (vec 0) (a % x) (b % y) (c % z)`,
REWRITE_TAC[DIHV_FORMULAR; VECTOR_SUB_RZERO] THEN 
REWRITE_TAC[DOT_LMUL; DOT_RMUL; VECTOR_MUL_ASSOC] THEN 
REWRITE_TAC[REAL_ARITH` ((a * a * xx) * b) = ( a pow 2 * b ) * xx `;
  REAL_ARITH` (b * a * c) * a = ( a pow 2 * b ) * c `] THEN 
ONCE_REWRITE_TAC[GSYM VECTOR_MUL_ASSOC] THEN 
REWRITE_TAC[REAL_ARITH` ((a * a * xx) * b) = ( a pow 2 * b ) * xx `;
  REAL_ARITH` (b * a * c) * a = ( a pow 2 * b ) * c `; GSYM VECTOR_SUB_LDISTRIB] THEN 
REPEAT STRIP_TAC THEN MATCH_MP_TAC WHEN_A_B_POS_ARCV_STABLE  THEN 
CONJ_TAC THENL [MATCH_MP_TAC REAL_LT_MUL THEN 
ASM_SIMP_TAC[POW_2; REAL_LT_MUL];MATCH_MP_TAC REAL_LT_MUL THEN 
ASM_SIMP_TAC[POW_2; REAL_LT_MUL]]);;


let VECTOR_OF_DIHV_ORTHONORMAL = prove(` ((w dot w) % (v1: real^N) - (v1 dot w) % w ) dot w = &0 `,
REWRITE_TAC[DOT_LSUB; DOT_LMUL] THEN REAL_ARITH_TAC);;

let ORTHOGORNAL_UNITIZE = prove(` ! x (y:real^N). x dot y = &0 ==> ( &1 / norm x % x ) dot ( &1 / norm y % y ) = &0 `,
REWRITE_TAC[DOT_LMUL; DOT_RMUL] THEN SIMP_TAC[REAL_MUL_RZERO]);;

let NOT_MUL_EQ0_EQ = MESON[REAL_ENTIRE]`!x y. ~( x * y = &0 ) <=> ~( x = &0 ) /\ ~( y = &0) `;;

let UNITS_NOT_EQ_0 = MESON[NOT_MUL_EQ0_EQ; REAL_ARITH` ~( &1 = &0 )`]`! x y. x * y = &1 ==> ~( x = &0 ) /\ ~( y = &0) `;;

let REAL_MUL_LRINV = 
let t1 = UNDISCH (SPEC_ALL REAL_MUL_LINV) in
let t2 = UNDISCH (SPEC_ALL REAL_MUL_RINV) in
let t3 = CONJ t1 t2 in DISCH ` ~( x = &0 ) ` t3;;

let NOT_EQ0_IMP_NEITHER_INVERT = prove(` ~( a = &0 ) ==> ~( &1 / a = &0 ) `,
REWRITE_TAC[NOT_0_INVERTABLE; REAL_FIELD` &1 / ( &1 / a ) = a `] THEN SIMP_TAC[REAL_MUL_SYM]);;


let PROJECTOR_NOT_EQ_VEC0 = prove(`! w v1. ~( (w:real^N) = vec 0 ) /\ ~(v1 IN aff {vec 0, w}) <=>
  ~( (w dot w) % v1 - (v1 dot w) % w = vec 0 ) `, REPEAT GEN_TAC THEN 
EQ_TAC THENL [REWRITE_TAC[GSYM DE_MORGAN_THM; CONTRAPOS_THM] THEN 
ASM_CASES_TAC ` (w:real^N) = vec 0 ` THENL [ASM_SIMP_TAC[];
ASM_SIMP_TAC[PERPENCULAR_PART_IDENT0]];
ASM_CASES_TAC ` (w:real^N) = vec 0 ` THENL [
ASM_SIMP_TAC[DOT_RZERO; VECTOR_MUL_LZERO; VECTOR_SUB_RZERO];
ASM_SIMP_TAC[CONTRAPOS_THM; AFF2_VEC0; IN_ELIM_THM]] THEN STRIP_TAC THEN 
ASM_SIMP_TAC[VECTOR_MUL_ASSOC; DOT_LMUL; REAL_MUL_SYM; VECTOR_SUB_REFL]]);;

let NOT_EQ_VEC0_IMP_EQU_AFF_COLL = prove(` ! (w:real^N) u. ~( w = vec 0 ) ==> ( u IN aff {vec 0, w } <=> collinear {vec 0, w, u}) `,
REPEAT STRIP_TAC THEN EQ_TAC THENL [REWRITE_TAC[AFF2_VEC0; IN_ELIM_THM; COLLINEAR_LEMMA] THEN 
MESON_TAC[]; REWRITE_TAC[AFF2_VEC0; IN_ELIM_THM; COLLINEAR_LEMMA] THEN 
STRIP_TAC THENL [ASM_MESON_TAC[]; EXISTS_TAC `&0 ` THEN ASM_SIMP_TAC[VECTOR_MUL_LZERO];
ASM_MESON_TAC[]]]);;

(* lemma 1.35. 26 Aug, 2009 *)


let QQZKTXU = prove(`! v w v1 (v2:real^3). let gammma = dihV v w v1 v2 in  {v1,v2} INTER aff {v,w} = {} /\
~( v = w ) ==> cos ( azim v w v1 v2 ) = cos gammma `,
GEOM_ORIGIN_TAC `v:real^3` THEN 
ONCE_REWRITE_TAC[SET_RULE`{a} = {a,a}`] THEN 
REWRITE_TAC[IMAGE_INTER_AFF3] THEN 
REWRITE_TAC[IMAGE_CLAUSES] THEN 
REWRITE_TAC[IMAGE_CLAUSES; IMAGE_EQ_EMPTY; INSERT_INSERT] THEN 
ONCE_REWRITE_TAC[SPEC ` -- v:real^N` (GSYM DIHV_TRASABLE)] THEN 
REWRITE_TAC[VECTOR_ARITH` -- a + a + b = (b:real^N)`] THEN 
REPEAT STRIP_TAC THEN 
LET_TAC THEN 
MP_TAC (SPECL [`(vec 0): real^3`;`w:real^3`; `v1:real^3`;`v2:real^3`] azim) THEN 
REPEAT STRIP_TAC THEN 
EXPAND_TAC "gammma" THEN 
REWRITE_TAC[DIHV_FORMULAR; VECTOR_SUB_RZERO] THEN 
REPLICATE_TAC 2 (FIRST_X_ASSUM MP_TAC) THEN PHA THEN 
REWRITE_TAC[INSERT_INTER_EMPTY] THEN 
DAO THEN NGOAC THEN 
ONCE_REWRITE_TAC[EQ_SYM_EQ] THEN 
NHANH (MATCH_MP (MESON[]`(a /\ b ==> c) ==> ( a /\ ~ c ==> ~ b ) `)
 PERPENCULAR_PART_IDENT0) THEN 
NHANH (MATCH_MP (MESON[]` a dot b = &0 ==> ~( a = vec 0) ==>  a dot b = &0`)
  VECTOR_OF_DIHV_ORTHONORMAL) THEN 
NHANH ORTHOGORNAL_UNITIZE THEN 
REWRITE_TAC[NOT_VEC0_UNITABLE] THEN 
ABBREV_TAC `e11 = &1 / norm ((w dot w) % v1 - (v1 dot w) % w) %
   ((w dot w) % v1 - (v1 dot w) % (w: real^3))` THEN 
ABBREV_TAC ` e33 = &1 / norm w % (w:real^3)` THEN 
STRIP_TAC THEN 
UNDISCH_TAC `e11 dot (e33: real^3) = &0` THEN 
UNDISCH_TAC` norm ( e33: real^3) = &1 ` THEN 
UNDISCH_TAC` norm ( e11: real^3) = &1 ` THEN 
PHA THEN 
NHANH TWO_UNIT_ORTH_VECTORS_IMP_ORTHONORMAL THEN 
EXPAND_TAC "e33" THEN 
REWRITE_TAC[GSYM NOT_VEC0_UNITABLE] THEN 
REWRITE_TAC[GSYM NOT_VEC0_UNITABLE; GSYM NORM_POS_LT] THEN 
NHANH REAL_LT_IMP_NZ THEN 
NHANH NOT_EQ0_IMP_NEITHER_INVERT  THEN 
ASM_REWRITE_TAC[] THEN 
STRIP_TAC THEN 
UNDISCH_TAC ` &1 / norm w % w = (e33:real^3)` THEN 
UNDISCH_TAC ` ~(&1 / norm (w:real^3) = &0)` THEN 
PHA THEN NHANH VECTOR_MUL_R_TO_L THEN 
REWRITE_TAC[REAL_FIELD` &1 / ( &1 / a ) = a `; GSYM DIST_0] THEN 
SUBST_ALL_TAC (MESON[NORM_POS_LT]` &0 < norm (w:real^3) <=> ~(w = vec 0)`) THEN 
SIMP_TAC[DIST_SYM] THEN 
REWRITE_TAC[VECTOR_ARITH` a = b % x <=> b % x = a - vec 0 `] THEN 
STRIP_TAC THEN 
UNDISCH_TAC `~((w:real^3) = vec 0)` THEN 
FIRST_X_ASSUM MP_TAC THEN 
UNDISCH_TAC ` orthonormal e11 e2 e33 ` THEN 
PHA THEN FIRST_X_ASSUM NHANH THEN 
STRIP_TAC THEN 
UNDISCH_TAC ` ~(v1 IN aff {vec 0, (w:real^3)})` THEN 
UNDISCH_TAC ` ~((w:real^3) = vec 0)` THEN 
UNDISCH_TAC `~(v2 IN aff {vec 0, (w:real^3)})` THEN 
ONCE_REWRITE_TAC[MESON[]` ~( a = b ) <=> ~( a = b ) /\ ~( a = b )`] THEN 
PHA THEN 
ONCE_REWRITE_TAC[TAUT` a /\ b/\ c/\ d <=> b /\ ( b /\ a ) /\c /\ d `] THEN 
REWRITE_TAC[PROJECTOR_NOT_EQ_VEC0 ] THEN 
SIMP_TAC[NOT_EQ_IMPCOS_ARC; VECTOR_SUB_RZERO] THEN 
DOWN_TAC THEN 

REWRITE_TAC[NOT_EQ_IMPCOS_ARC; VECTOR_SUB_RZERO] THEN 
ABBREV_TAC ` azz = azim (vec 0) w v1 v2 ` THEN 
STRIP_TAC THEN 
USE_FIRST `v2 =
      (r2 * cos (psi + azz)) % e11 + (r2 * sin (psi + azz)) % e2 + h2 % (w:real^3)` SUBST1_TAC THEN 
USE_FIRST `v1 = (r1 * cos psi) % e11 + (r1 * sin psi) % e2 + h1 % (w:real^3)` SUBST1_TAC THEN 
UNDISCH_TAC ` orthonormal e11 e2 e33 ` THEN 
SIMP_TAC[DOT_LADD; DOT_LMUL; orthonormal] THEN 
ABBREV_TAC ` ww = w dot (w:real^3)` THEN 
EXPAND_TAC "w" THEN 


SIMP_TAC[DOT_SYM; DOT_RMUL; REAL_MUL_RZERO; REAL_ADD_LID; VECTOR_ADD_LDISTRIB] THEN 
SIMP_TAC[VECTOR_MUL_ASSOC; REAL_MUL_SYM; VECTOR_ARITH`(a + c + b ) - b = (a:real^N) + c`] THEN 
SIMP_TAC[vector_norm; DOT_LADD; DOT_RADD; DOT_LMUL; DOT_RMUL; REAL_MUL_RZERO; DOT_SYM;
  REAL_ADD_RID; REAL_MUL_RID; REAL_ADD_LID; GSYM POW_2; REAL_ARITH`( a * b * c ) pow 2 + ( a * b 
  * d ) pow 2 = ( a * b ) pow 2 * ( d pow 2 + c pow 2 ) `; SIN_CIRCLE] THEN 
STRIP_TAC THEN 
UNDISCH_TAC `~(ww % (v2: real^3) - (v2 dot w) % w = vec 0)` THEN 
UNDISCH_TAC `~(ww % (v1: real^3) - (v1 dot w) % w = vec 0)` THEN 
EXPAND_TAC "ww" THEN 
REWRITE_TAC[GSYM PROJECTOR_NOT_EQ_VEC0] THEN 
NHANH (MATCH_MP (MESON[]` (a ==> ( b <=> c )) ==> (a /\ ~ b ==> ~ c) `) (SPEC_ALL NOT_EQ_VEC0_IMP_EQU_AFF_COLL)) THEN 
FIRST_X_ASSUM NHANH THEN 
FIRST_X_ASSUM NHANH THEN 
REWRITE_TAC[GSYM DOT_POS_LT] THEN 
STRIP_TAC THEN 
STRIP_TAC THEN 
ASSUME_TAC2 (SPECL [`(w:real^3) dot w `;` r1: real `] REAL_LT_MUL) THEN 
ASSUME_TAC2 (SPECL [`(w:real^3) dot w `;` r2: real `] REAL_LT_MUL) THEN 
REPLICATE_TAC 2 (FIRST_X_ASSUM MP_TAC) THEN 
NHANH REAL_LT_IMP_LE THEN 
PHA THEN 
SIMP_TAC[POW_2_SQRT] THEN 
REWRITE_TAC[REAL_ARITH` ((w dot w) * r1 * a) * (w dot w) * r2 * b +
     ((w dot w) * r1 * c) * (w dot w) * r2 * d =
     (((w dot w) * r1) * (w dot w) * r2) * (b * a + d * c) `] THEN 
SIMP_TAC[REAL_FIELD` &0 < a /\ &0 < b ==> (( a * b ) * c ) / ( a * b ) = c `] THEN 
REWRITE_TAC[GSYM COS_SUB; REAL_ARITH` (a + b ) - a = b`]);;





(* 
	   
("SIMPLIZE_COS_IF_OTHOR ",
	   
    |- !v0 v1 w p.
	   
           ~(v0 = w) /\
	   
           ~(v0 = v1) /\
	   
           p - v0 = k % (v1 - v0) /\
	   
           (w - p) dot (v1 - v0) = &0
	   
           ==> cos (arcV v0 v1 w) = k * norm (v1 - v0) / norm (w - v0))]
	   
*)
	   

	   

	 

