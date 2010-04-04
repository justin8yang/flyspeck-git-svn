(* ========================================================================= *)
(*                FLYSPECK - BOOK FORMALIZATION                              *)
(*          COMPLEMENT LEMMAS FOR EULER TRIANGLE LEMMA                       *)
(*                                                                           *)
(*                  LEMMA ABOUT DERIVATIVES                                  *)
(*                                                                           *)
(*      Authour : VU KHAC KY                                                 *)
(*                                                                           *)
(* ========================================================================= *)

(* ========================================================================= *)
(*                                                                           *)
(*                    SOME NECESSARY LEMMAS                                  *)
(*                                                                           *)
(* ========================================================================= *)

(* ========================================================================= *)
(*         LEMMA 1                                                           *)
(* ========================================================================= *)

let REDUCE_WITH_DIV_Euler_lemma = prove_by_refinement 
 (`!x y z . ~ (y = &0) /\ ~ (z = &0) ==> x * y / (z * y) = x / z`,
[ (REPEAT STRIP_TAC);
 (MATCH_MP_TAC REAL_EQ_LCANCEL_IMP);
 (EXISTS_TAC `z:real`);
 (ASM_REWRITE_TAC[]);
 (REWRITE_TAC[REAL_ARITH `a * b * c = (a * c) * b`]);

  (SUBGOAL_THEN `z * x / z = x` ASSUME_TAC);
  (MATCH_MP_TAC REAL_DIV_LMUL);
  (ASM_REWRITE_TAC[]);

 (PURE_ONCE_ASM_REWRITE_TAC[]);
 (MATCH_MP_TAC (MESON[REAL_MUL_LID] `a = &1 ==> a * b = b`));
 (REWRITE_TAC[REAL_ARITH `a * b / c = (a * b) / c`]);
 (MATCH_MP_TAC REAL_DIV_REFL);
 (REWRITE_TAC[REAL_ENTIRE; MESON[] `~(a \/ b) <=> ~a /\ ~b`]);
 (ASM_REWRITE_TAC[])]);;


(* ========================================================================= *)
(*         LEMMAS MODIFIED FROM j.HARRISON FILES                             *)
(* ========================================================================= *)

let HAS_REAL_DERIVATIVE_ZERO_CONSTANT2 = prove (

`!f a b c s.
         is_realinterval s /\ (a IN s) /\
         (!x. x IN s ==> (f has_real_derivative &0) (atreal x within s))  /\
         (f a = c )
         ==> (!x. x IN s ==> f x = c)`,
  MP_TAC HAS_REAL_DERIVATIVE_ZERO_CONSTANT THEN 
  MESON_TAC[]);;

(* ------------------------------------------------------------------------- *)

let HAS_REAL_DERIVATIVE_CHAIN2 = prove
  (`!P f g x s.
      (!x. P x ==> (g has_real_derivative g' x) (atreal x))
      ==> ((f has_real_derivative f') (atreal x within s) /\ P (f x))
               ==> ((\x. g (f x)) has_real_derivative f' * g' (f x))
                   (atreal x within s) `,
   REPEAT GEN_TAC THEN 
   MP_TAC HAS_REAL_DERIVATIVE_CHAIN THEN
   MESON_TAC[]);;

(* ========================================================================= *)
(*         LEMMAS ABOUT INTERVALS                                            *)
(* ========================================================================= *)


let INTERVAL_DIVIDE_Euler_lemma = prove_by_refinement 
 (`!c. &0 < (&4 - c) * c ==> &0 < c /\ c < &4`,
[(REPEAT STRIP_TAC);

  (MATCH_MP_TAC (REAL_ARITH `~(&0 <= -- x) ==> &0 < x`));
  STRIP_TAC;
    (SUBGOAL_THEN `(&4 - c) * (-- c) < &0` ASSUME_TAC);
    ASM_REAL_ARITH_TAC;
    (SUBGOAL_THEN `&0 <= (&4 - c) * (-- c)` ASSUME_TAC);
    (MATCH_MP_TAC REAL_LE_MUL);
    (ASM_REWRITE_TAC[]);
    ASM_REAL_ARITH_TAC;
  ASM_REAL_ARITH_TAC;

  (MATCH_MP_TAC (REAL_ARITH `~(&0 <= x - &4) ==> x < &4`));
  STRIP_TAC;
    (SUBGOAL_THEN `(c - &4) * c < &0` ASSUME_TAC);
    ASM_REAL_ARITH_TAC;
    (SUBGOAL_THEN `&0 <= (c - &4) * c` ASSUME_TAC);
    (MATCH_MP_TAC REAL_LE_MUL);
    (ASM_REWRITE_TAC[]);
    ASM_REAL_ARITH_TAC;
  ASM_REAL_ARITH_TAC]);;

(* ---------------------------------------------------------------------------*)

let SQRT_RULE_Euler_lemma = prove 
 (`!x y. x pow 2 = y /\ &0 <= x ==> x = sqrt y`,
 REPEAT STRIP_TAC THEN 
 REWRITE_TAC[GSYM (ASSUME `x pow 2 = y`);REAL_POW_2] THEN   
 ASM_SIMP_TAC[SQRT_MUL] THEN
 ASM_MESON_TAC[GSYM REAL_POW_2;SQRT_POW_2]);;


let REAL_INTERVAL_Euler_lemma = prove
( `!a b.  let P1 = {x| x < a} in 
          let P2 = {x| a < x} in
          let P3 = {x| a < x /\ x < b} in
        is_realinterval P1 /\ is_realinterval P2 /\ is_realinterval P3`,
 REPEAT GEN_TAC THEN
 REPEAT LET_TAC THEN 
 EXPAND_TAC "P1" THEN EXPAND_TAC "P2" THEN EXPAND_TAC "P3" THEN
 REWRITE_TAC[is_realinterval] THEN 
 REWRITE_TAC[IN_ELIM_THM] THEN REAL_ARITH_TAC);;

(* ========================================================================= *)
(*         FIRST LEMMA ABOUT DERIVATIVE                                      *)
(* ========================================================================= *)

  
let DERIVATIVE_WRT_C1_Euler_lemma = prove_by_refinement (

 `!P. is_realinterval P /\ (&2) IN P /\
   (!x. x IN P ==> ~ (x = &0) /\ ~ (&4 - x = &0)) ==>
   (!c. c IN P ==> --pi / &2 - &2 * atn (&1 - c / &2) + 
                  &2 * atn ((&4 - c) / c) = &0) `,

[ (GEN_TAC THEN STRIP_TAC);
 (MATCH_MP_TAC HAS_REAL_DERIVATIVE_ZERO_CONSTANT2 THEN EXISTS_TAC `&2`);
 (ASM_REWRITE_TAC[]); 
 (REWRITE_TAC[REAL_ARITH `&1 - &2 / &2 = &0`;ATN_0]);
 (REWRITE_TAC[REAL_ARITH 
   `(--a / &2 - &2 * &0 + &2 * s = &0) <=> s = a / &4`]);
 (REWRITE_TAC[REAL_ARITH `(&4 - &2) / &2 = &1`;ATN_1]);
 (GEN_TAC THEN STRIP_TAC);

   (SUBGOAL_THEN `~(c = &0) /\ ~(&4 - c = &0)` ASSUME_TAC);
    (* Subgoal 1 *)
   (UP_ASM_TAC THEN ASM_REWRITE_TAC[]);
   (UP_ASM_TAC THEN STRIP_TAC);

 (ABBREV_TAC 
  `f = (\c. --pi / &2 - &2 * atn (&1 - c / &2) + &2 * atn ((&4 - c) / c))`);
 (ABBREV_TAC `F1 = (\c. atn (&1 - c / &2))`);
 (ABBREV_TAC `F2 = (\c. atn ((&4 - c) / c))`);

   (SUBGOAL_THEN 
    `f = (\c:real. --pi / &2 - &2 * F1 c + &2 * F2 c)` ASSUME_TAC);
    (* Subgoal 2 *)
   (EXPAND_TAC "f" THEN EXPAND_TAC "F1" THEN EXPAND_TAC "F2");
   (MESON_TAC[]);

 (ASM_REWRITE_TAC[] THEN DEL_TAC);
 (ABBREV_TAC `g' = (\x. inv (&1 + x pow 2))`);

   (SUBGOAL_THEN 
    `!c. (:real) c ==> (atn has_real_derivative (g':real->real) c) (atreal c)`
     ASSUME_TAC);  
    (* Subgoal 3 *) 
   (EXPAND_TAC "g'");
   (REWRITE_TAC[EQ_UNIV; HAS_REAL_DERIVATIVE_ATN]);

(* ------------------------------------------------------------------------- *)
(*    Compute the derivative of F1                                           *)
(* ------------------------------------------------------------------------- *)

 (ABBREV_TAC `f1 = (\c. &1 - c / &2)`);

   (SUBGOAL_THEN `F1 = (\c:real.  atn (f1 c))` ASSUME_TAC);
    (* Subgoal 4 *)
   (EXPAND_TAC "F1" THEN EXPAND_TAC "f1" THEN MESON_TAC[]);

   (SUBGOAL_THEN 
    `(F1 has_real_derivative (-- &1 / &2) * g' ((f1:real -> real) c)) 
     (atreal c within P)` ASSUME_TAC);
    (* Subgoal 5 *)
   (ONCE_ASM_REWRITE_TAC[]);

     (SUBGOAL_THEN 
      `(f1 has_real_derivative -- &1 / &2) (atreal c within P) /\ 
       (:real) (f1 c)` ASSUME_TAC);
      (* Subgoal 5.1 *)
     CONJ_TAC;  (* break into 2 subgoal 5.1.1 & 5.1.2 *)
       (EXPAND_TAC "f1" THEN REAL_DIFF_TAC THEN REAL_ARITH_TAC); (*End 5.1.1*) 
       (MESON_TAC[EQ_UNIV;IN_UNIV; IN]); (* End 5.1.2 *)
       (* End subgoal 5.1 *)

   (UP_ASM_TAC THEN DEL_TAC THEN DEL_TAC THEN UP_ASM_TAC);
   (MP_TAC HAS_REAL_DERIVATIVE_CHAIN2);
   (MESON_TAC[HAS_REAL_DERIVATIVE_CHAIN2]);
    (* End subgoal 5 *)

   (SUBGOAL_THEN 
    `-- &1 / &2 / (&2 - c + c * c / &4) = -- &1 / &2 * g' ((f1:real -> real) c)`
     ASSUME_TAC);
    (* Subgoal 6 *)
   (EXPAND_TAC "g'" THEN EXPAND_TAC "f1");
   (REWRITE_TAC[REAL_ARITH 
    `&1 + (&1 - c / &2) pow 2 = &2 - c + c * c / &4`]);
   (ABBREV_TAC `m = -- &1 / &2`);
   (ABBREV_TAC `n = (&2 - c + c * c / &4)`);
      
     (SUBGOAL_THEN `m = (m * inv n) * n  ==> (m / n = m * inv n)` ASSUME_TAC);
     (MATCH_MP_TAC (MESON[] `(a <=> b) ==> (b ==> a)`));
     (MATCH_MP_TAC REAL_EQ_LDIV_EQ);
     (EXPAND_TAC "n"); 
     (REWRITE_TAC[REAL_ARITH 
     `&2 - c + c * c / &4 = &1 + (&1 - c / &2) pow 2 `]);
     (MATCH_MP_TAC (REAL_ARITH `&0 <= a ==> &0 < &1 + a`));
     (REWRITE_TAC[REAL_LE_POW_2]);

   (FIRST_X_ASSUM MATCH_MP_TAC);
   (REWRITE_TAC[GSYM REAL_MUL_ASSOC]);
   (MATCH_MP_TAC (MESON[REAL_MUL_RID] `x = &1 ==> a = a * x`)); 
   (MATCH_MP_TAC REAL_MUL_LINV);
   (MATCH_MP_TAC (REAL_ARITH `&0 < x ==> ~ (x = &0)`));
   (EXPAND_TAC "n"); 
   (REWRITE_TAC[REAL_ARITH 
    `&2 - c + c * c / &4 = &1 + (&1 - c / &2) pow 2 `]);
   (MATCH_MP_TAC (REAL_ARITH `&0 <= a ==> &0 < &1 + a`));
   (REWRITE_TAC[REAL_LE_POW_2]);

   (SUBGOAL_THEN 
    `(F1 has_real_derivative -- &1 / &2 / (&2 - c + c * c / &4)) 
     (atreal c within P)` ASSUME_TAC);
    (* Subgoal 7 *)
   (ASM_MESON_TAC[]);
  
 (UP_ASM_TAC THEN REPLICATE_TAC 4 DEL_TAC THEN REPEAT DISCH_TAC);
 SWITCH_TAC;

(* ------------------------------------------------------------------------- *)
(*    Compute the derivative of F2                                           *)
(* ------------------------------------------------------------------------- *)

 (ABBREV_TAC `f2 = (\c. (&4 - c) / c)`);

   (SUBGOAL_THEN `F2 = (\c:real.  atn (f2 c))` ASSUME_TAC);
    (* Subgoal 8 *)
   (EXPAND_TAC "F2" THEN EXPAND_TAC "f2" THEN MESON_TAC[]);

   (SUBGOAL_THEN 
    `(F2 has_real_derivative (-- &4 / (c * c)) * g' ((f2:real -> real) c)) 
     (atreal c within P)` ASSUME_TAC);
    (* Subgoal 9 *)
   (ONCE_ASM_REWRITE_TAC[]);

     (SUBGOAL_THEN 
      `(f2 has_real_derivative (-- &4 / (c * c))) (atreal c within P) /\ 
       (:real) (f2 c)` ASSUME_TAC);
      (* Subgoal 9.1 *)
     CONJ_TAC;  (* Break into 2 subgoals *)
  
       (EXPAND_TAC "f2" THEN REAL_DIFF_TAC);
       (ASM_REWRITE_TAC[]);   
       (REWRITE_TAC[REAL_POW_2]);   
       (AP_THM_TAC THEN AP_TERM_TAC);
       REAL_ARITH_TAC;
       (MESON_TAC[EQ_UNIV;IN_UNIV; IN]);

   (UP_ASM_TAC THEN DEL_TAC THEN DEL_TAC THEN UP_ASM_TAC);
   (MP_TAC HAS_REAL_DERIVATIVE_CHAIN2);
   (MESON_TAC[HAS_REAL_DERIVATIVE_CHAIN2]);

   (SUBGOAL_THEN 
    `-- &1 / &2 / (&2 - c + c * c / &4) =
     -- &4 / (c * c) * g' ((f2:real -> real) c)` ASSUME_TAC);
    (* Subgoal 10 *)
   (EXPAND_TAC "g'" THEN EXPAND_TAC "f2");
   (REWRITE_TAC[REAL_POW_DIV]);

     (SUBGOAL_THEN
      `&1 + (&4 - c) pow 2 / c pow 2 = (&16 - &8 * c + &2 * c * c) / (c * c)`
      ASSUME_TAC);
     (REWRITE_TAC[REAL_ARITH 
      `(&16 - &8 * c + &2 * c * c) = c * c + (&4 - c) pow 2`]);
     (REWRITE_TAC[REAL_ARITH `(a + b) / c = a / c + b / c`]);
     (REWRITE_TAC[REAL_POW_2]);
     (AP_THM_TAC THEN AP_TERM_TAC);   
     (REWRITE_TAC[EQ_SYM_EQ]);
     (MATCH_MP_TAC (REAL_DIV_REFL));
     (REWRITE_TAC[REAL_ENTIRE; MESON[] `~(x \/ y) <=> ~ x /\ ~ y`]);
     (ASM_REWRITE_TAC[]);

   (ASM_REWRITE_TAC[]);
   (REWRITE_TAC[REAL_INV_DIV]);
   (REWRITE_TAC[REAL_ARITH `t / x * y / z = (y / x) * (t / z)`]);
  
     (SUBGOAL_THEN `(c * c) / (c * c) = &1` ASSUME_TAC);
     (MATCH_MP_TAC (REAL_DIV_REFL));
     (REWRITE_TAC[REAL_ENTIRE; MESON[] `~(x \/ y) <=> ~ x /\ ~ y`]);
     (ASM_REWRITE_TAC[]);

   (ASM_REWRITE_TAC[REAL_MUL_LID]);
   (REWRITE_TAC[REAL_ARITH 
    `&16 - &8 * c + &2 * c * c = (&2 - c + c * c / &4) * &8`]);
   (REWRITE_TAC[REAL_ARITH `-- &4 = (-- &1 / &2) * &8`]);
   (REWRITE_TAC[EQ_SYM_EQ]);

   (ABBREV_TAC `m = -- &1 / &2`);
   (ABBREV_TAC `n = (&2 - c + c * c / &4)`);
   (REWRITE_TAC[REAL_ARITH `(a * b) / c = a * (b / c)`]);
   (MATCH_MP_TAC REDUCE_WITH_DIV_Euler_lemma);
   (REWRITE_TAC[REAL_ARITH `~ (&8 = &0)`]);
   (EXPAND_TAC "n");
   (MATCH_MP_TAC (REAL_ARITH `&0 < x ==> ~ (x = &0)`));
   (REWRITE_TAC[REAL_ARITH 
     `&2 - c + c * c / &4 = &1 + (&1 - c / &2) pow 2 `]);
   (MATCH_MP_TAC (REAL_ARITH `&0 <= a ==> &0 < &1 + a`));
   (REWRITE_TAC[REAL_LE_POW_2]);

   (SUBGOAL_THEN 
    `(F2 has_real_derivative
     -- &1 / &2 / (&2 - c + c * c / &4))(atreal c within P)` ASSUME_TAC);
    (* Subgoal 11 *)    
   (ASM_MESON_TAC[]);

 (UP_ASM_TAC THEN REPLICATE_TAC 5 DEL_TAC THEN DISCH_TAC);

(* ------------------------------------------------------------------------- *)
(*    Compute the derivative of f                                            *)
(* ------------------------------------------------------------------------- *)

 (ABBREV_TAC `f' = -- &1 / &2 / (&2 - c + c * c / &4)`);
 (ABBREV_TAC `F3 = (\c:real. F1 c - F2 c)`);

   (SUBGOAL_THEN 
    `(F3 has_real_derivative &0) (atreal c within P)` ASSUME_TAC);
   (EXPAND_TAC "F3");
   (ASM_MESON_TAC[HAS_REAL_DERIVATIVE_SUB; REAL_ARITH `a - a = &0`]);

 (ABBREV_TAC `2F3 = (\c:real. &2 * F3 c)`);

   (SUBGOAL_THEN 
    `(2F3 has_real_derivative (&2) * (&0)) (atreal c within P)` ASSUME_TAC);
   (EXPAND_TAC "2F3");
   (DEL_TAC THEN UP_ASM_TAC);
   (MP_TAC HAS_REAL_DERIVATIVE_LMUL_WITHIN);
   (MESON_TAC[]);

   (SUBGOAL_THEN 
   `(\c:real. --pi / &2 - &2 * F1 c + &2 * F2 c) = (\c:real. --pi / &2 - 2F3 c)`
    ASSUME_TAC);
   (EXPAND_TAC "2F3");
   (EXPAND_TAC "F3");
   (REWRITE_TAC[REAL_ARITH `a - &2 * (x - y) = a - &2 * x + &2 * y`]);

 (ONCE_ASM_REWRITE_TAC[] THEN DEL_TAC);

   (SUBGOAL_THEN `((\c. --pi / &2) has_real_derivative &0)
                   (atreal c within P)` ASSUME_TAC);
   (REAL_DIFF_TAC THEN REAL_ARITH_TAC);
  
 (UP_ASM_TAC THEN UP_ASM_TAC);
 (MP_TAC HAS_REAL_DERIVATIVE_SUB);
 (MESON_TAC [REAL_ARITH `&2 * &0 = &0 /\ &0 - &0 = &0`;   
   HAS_REAL_DERIVATIVE_SUB])]);;





let DERIVATIVE_WRT_A_Euler_lemma = prove_by_refinement (
 `! a b c.
  let d = ups_x a b c - a * b * c in 
 ((&0 < d) /\ (&0 < a /\ &0 < b /\ &0 < c) /\ 
              (a < &4 /\ b < &4 /\ c < &4) ==>
 pi / &2 - atn ((-- &2 * a + &2 * b + &2 * c - b * c) / (&2 * sqrt d)) +
 pi / &2 - atn ((-- &2 * b + &2 * c + &2 * a - c * a) / (&2 * sqrt d)) +
 pi / &2 - atn ((-- &2 * c + &2 * a + &2 * b - a * b) / (&2 * sqrt d)) - pi =
 pi - &2 * atn ((&8 - a - b - c) / sqrt d))`,

[ (REPEAT GEN_TAC THEN LET_TAC THEN STRIP_TAC);
 (REWRITE_TAC[REAL_ARITH ` pi / &2 - x + pi / &2 - y + pi / &2 - z - pi = 
   pi - t <=> -- pi / &2 - x - y - z + t = &0`]);

 (ABBREV_TAC `s = {(x:real) | &0 < ups_x x b c - x * b * c }`);


(* ========================================================================= *)
(*                             The main subgoal.                             *) 
(* ========================================================================= *)

 (SUBGOAL_THEN `!a. (a IN s) ==> --pi / &2 -
 atn
  ((-- &2 * a + &2 * b + &2 * c - b * c) /
  (&2 * sqrt (ups_x a b c - a * b * c))) -
 atn
 ((-- &2 * b + &2 * c + &2 * a - c * a) /
  (&2 * sqrt (ups_x a b c - a * b * c))) -
 atn
 ((-- &2 * c + &2 * a + &2 * b - a * b) /
  (&2 * sqrt (ups_x a b c - a * b * c))) +
 &2 * atn ((&8 - a - b - c) / sqrt (ups_x a b c - a * b * c)) =
 &0` ASSUME_TAC);

 (MATCH_MP_TAC HAS_REAL_DERIVATIVE_ZERO_CONSTANT2 THEN EXISTS_TAC 
  `b + c - (b * c) / & 2`);
 (REPEAT CONJ_TAC);   (* Break into 3 Subgoals *) 

  (EXPAND_TAC "s");
  (ASM_MESON_TAC[EULER_TRIANGLE_REAL_INTERVAL]);  (* End subgoal 1 *)

(* ------------------------------------------------------------------------- *)
(*                b + c - (b * c) / &2 IN s                                  *)
(* ------------------------------------------------------------------------- *)
                  
  (EXPAND_TAC "s" THEN ASM_REWRITE_TAC[IN_ELIM_THM]);
  (ABBREV_TAC `a' = b + c - (b * c) / &2`);
  (MATCH_MP_TAC (REAL_ARITH `&0 < d /\ d <= x ==> &0 < x`));
  (ASM_REWRITE_TAC[]);
  (EXPAND_TAC "d" THEN REWRITE_TAC[ups_x]);
  (ONCE_REWRITE_TAC [REAL_ARITH `a <= b <=> &0 <= b - a `]);

    (SUBGOAL_THEN 
      `(--a' * a' - b * b - c * c + &2 * a' * c + &2 * a' * b + &2 * b * c) -
       a' * b * c -
       ((--a * a - b * b - c * c + &2 * a * c + &2 * a * b + &2 * b * c) -
       a * b * c) =
       (a - a') pow 2`
      ASSUME_TAC);
    (EXPAND_TAC "a'" THEN REAL_ARITH_TAC);

  (ASM_REWRITE_TAC[]);
  (ASM_MESON_TAC[REAL_LE_POW_2]);

(* ========================================================================= *)
(*                                                                           *)
(*                 BEGIN COMPUTE DERIVATIVES                                 *)
(*                                                                           *)
(* ========================================================================= *)
 (GEN_TAC THEN DISCH_TAC); 
 (ABBREV_TAC `Da = (-- &2 * a' + &2 * b + &2 * c - b * c)`); 
 (ABBREV_TAC `Db = (-- &2 * b + &2 * c + &2 * a' - a' * c)`); 
 (ABBREV_TAC `Dc = (-- &2 * c + &2 * a' + &2 * b - a' * b)`); 
 (ABBREV_TAC `D' = ups_x a' b c - a' * b * c`);

  (SUBGOAL_THEN `&0 < D'` ASSUME_TAC);
  (* Subgoal 3.1 *)

  (REPLICATE_TAC 5 UP_ASM_TAC THEN EXPAND_TAC "s");
  (PURE_ASM_REWRITE_TAC[IN_ELIM_THM] THEN MESON_TAC[]);

(* --------------------------------------------------------------------------*)
(*  Subgoal 3.2                                                              *)
(*         Derivative of sqrt (ups_x x b c - x * b * c)                      *)  
(* --------------------------------------------------------------------------*)
 
 (ABBREV_TAC `G = (\x.  sqrt (ups_x x b c - x * b * c))`); 
 (ABBREV_TAC `G' = (-- &2 * a' + &2 * b + &2 * c - b * c) * 
                    inv (&2 * sqrt (ups_x a' b c - a' * b * c))`); 
 (SUBGOAL_THEN ` (G has_real_derivative G') (atreal a' within s)` ASSUME_TAC); 
 (ABBREV_TAC `f = (\x. ups_x x b c - x * b * c)`);
  
  (SUBGOAL_THEN `G = (\x:real. sqrt (f x))` ASSUME_TAC);
    (* Subgoal 3.2.1 *)
  (EXPAND_TAC "f" THEN ASM_REWRITE_TAC[]);
 
 (ABBREV_TAC `g' = (\x. inv (&2 * sqrt x))`); 
 (ABBREV_TAC `f' = -- &2 * a' + &2 * b + &2 * c - b * c`);
 
 (SUBGOAL_THEN `G' = f' * (g' ((f:real->real) a'))` ASSUME_TAC);
    (* Subgoal 3.2.2 *)
  (EXPAND_TAC "G'" THEN EXPAND_TAC "f'");
  (EXPAND_TAC "g'" THEN EXPAND_TAC "f" );
  (REWRITE_TAC[]);
   
 (ABBREV_TAC `P = {x:real | &0 < x}`);

  (SUBGOAL_THEN 
    `!x. P x ==> (sqrt has_real_derivative (g':real->real) x) (atreal x)`
     ASSUME_TAC);
    (* Subgoal 3.2.3 *)
  (EXPAND_TAC "g'" THEN REWRITE_TAC[BETA_THM]);
  (EXPAND_TAC "P" THEN REWRITE_TAC[IN_ELIM_THM]);
  (REWRITE_TAC[HAS_REAL_DERIVATIVE_SQRT]);

  (SUBGOAL_THEN 
   `(f has_real_derivative f') (atreal a' within s) /\ 
    (P:real->bool) ((f:real->real) a')`
     ASSUME_TAC);
    (* Subgoal 3.2.4 *)
  CONJ_TAC;  

    (* Subgoal 3.2.4.1 *)
  (EXPAND_TAC "f" THEN EXPAND_TAC "f'");
  (REWRITE_TAC[ups_x]);
  (REAL_DIFF_TAC THEN REAL_ARITH_TAC);
    (* Subgoal 3.2.4.2 *)
  (EXPAND_TAC "P" THEN REWRITE_TAC[IN_ELIM_THM]);

    (SUBGOAL_THEN `!x. (x:real) IN s ==> &0 < f x` ASSUME_TAC);
      (* Subgoal 3.2.4.1.1 *)
    (EXPAND_TAC "s" THEN REWRITE_TAC[IN_ELIM_THM]);
    (EXPAND_TAC "f" THEN MESON_TAC[]);
    (FIRST_ASSUM MATCH_MP_TAC THEN ASM_REWRITE_TAC[]);

  (ONCE_ASM_REWRITE_TAC[]);
    (* End Subgoal 3.2.4 *)
 
 (REPLICATE_TAC 2 UP_ASM_TAC); 
 (MP_TAC HAS_REAL_DERIVATIVE_CHAIN2 THEN MESON_TAC[]);
(* --------------------------------------------------------------------------*)
(*  Subgoal 3.3                                                              *)
(*         Derivative of &2 * sqrt (ups_x x b c - x * b * c)                 *)  
(* --------------------------------------------------------------------------*)
 
 (ABBREV_TAC `2G = (\x.  &2 * sqrt (ups_x x b c - x * b * c))`);
 
 (SUBGOAL_THEN 
  `(2G has_real_derivative &2 * G') (atreal a' within s)` ASSUME_TAC);

  (SUBGOAL_THEN `2G = (\x:real. &2 * G x)` ASSUME_TAC);
  (EXPAND_TAC "2G" THEN EXPAND_TAC "G" THEN MESON_TAC[]);
 
 (PURE_ONCE_ASM_REWRITE_TAC[]); 
 (DEL_TAC THEN DEL_TAC ); 
 (FIRST_X_ASSUM MP_TAC); 
 (MP_TAC HAS_REAL_DERIVATIVE_LMUL_WITHIN THEN MESON_TAC[]);

(* --------------------------------------------------------------------------*)
(*  Subgoal 3.4                                                              *)
(*         Derivative of  (-- &2 * x + &2 * b + &2 * c - b * c) /            *)
(*                          &2 * sqrt (ups_x x b c - x * b * c)              *)  
(* --------------------------------------------------------------------------*)
 
 (ABBREV_TAC `f1 = (\x. -- &2 * x + &2 * b + &2 * c - b * c)`); 
 (ABBREV_TAC `F12 = (\x. (-- &2 * x + &2 * b + &2 * c - b * c) /
        (&2 * sqrt (ups_x x b c - x * b * c)))`); 
 (SUBGOAL_THEN 
  `(F12 has_real_derivative (-- &2 * 2G (a':real) - (f1 a' * &2 * G')) / 
    2G a' pow 2) (atreal a' within s)` 
   ASSUME_TAC);

  (SUBGOAL_THEN ` F12 = (\x:real. f1 x / 2G x)` ASSUME_TAC);
    (* Subgoal 3.4.1 *)
  (EXPAND_TAC "F12" THEN EXPAND_TAC "2G" THEN EXPAND_TAC "f1");
  (ASM_REWRITE_TAC[]);
 
 (ASM_REWRITE_TAC[]);

  (SUBGOAL_THEN 
    `(f1 has_real_derivative -- &2) (atreal a' within s) /\
     (2G has_real_derivative &2 * G') (atreal a' within s) /\
    ~(2G a' = &0)`
    ASSUME_TAC);
  (* Subgoal 3.4.2 *) 
  (ASM_REWRITE_TAC[]);
  (REPEAT CONJ_TAC);  (* Break into 2 subgoals *)

    (EXPAND_TAC "f1" THEN REAL_DIFF_TAC THEN REAL_ARITH_TAC);
    (EXPAND_TAC "2G");
    (MATCH_MP_TAC 
      (MESON[REAL_ENTIRE] `~ (x = &0) /\ ~ (y = &0) ==> ~ (x * y = &0)`));
    (REWRITE_TAC[REAL_ARITH `~(&2 = &0)`]);
    (MATCH_MP_TAC (REAL_ARITH `&0 < x ==> ~(x = &0)`));
    (MATCH_MP_TAC SQRT_POS_LT);
    (ASM_REWRITE_TAC[]);
 
 (FIRST_X_ASSUM MP_TAC); 
 (MP_TAC HAS_REAL_DERIVATIVE_DIV_WITHIN); 
 (MESON_TAC[]);

(* --------------------------------------------------------------------------*)
(*  Subgoal 3.5                                                              *)
(*         Derivative of  atn ((-- &2 * a + &2 * b + &2 * c - b * c) /       *)
(*                          &2 * sqrt (ups_x x b c - x * b * c))             *)  
(* --------------------------------------------------------------------------*)
 
 (ABBREV_TAC `F1 = (\x. atn ((-- &2 * x + &2 * b + &2 * c - b * c) / (&2 * 
   sqrt (ups_x x b c - x * b * c))))`);
 
 (SUBGOAL_THEN 
   `(F1 has_real_derivative
    (-- &2 * 2G a' - f1 a' * &2 * G') / 2G a' pow 2 * inv (&1 + F12 a' pow 2))
    (atreal a' within s)`
  ASSUME_TAC);

  (SUBGOAL_THEN `F1 = (\x. atn (F12 (x:real)))` ASSUME_TAC);
    (* Subgoal 3.5.1 *)
  (EXPAND_TAC "F1" THEN EXPAND_TAC "F12");
  (REWRITE_TAC[]);
 
 (PURE_ONCE_ASM_REWRITE_TAC[]); 
 (REPLICATE_TAC 2 DEL_TAC); 
 (ABBREV_TAC `g' = (\x. inv (&1 + x pow 2))`); 
 (ABBREV_TAC `f' = (-- &2 * 2G (a':real) - f1 a' * &2 * G') / 2G a' pow 2`);

  (SUBGOAL_THEN 
    `!x. (:real) x ==> (atn has_real_derivative (g':real->real) x) (atreal x)`
    ASSUME_TAC);
    (* Subgoal 3.5.3 *)
  (EXPAND_TAC "g'" THEN REWRITE_TAC[BETA_THM]);
  (REWRITE_TAC[EQ_UNIV; HAS_REAL_DERIVATIVE_ATN]);

  (SUBGOAL_THEN `(F12 has_real_derivative f') (atreal a' within s) /\ 
                   (:real) ((F12:real->real) a')` 
     ASSUME_TAC);
  (ASM_REWRITE_TAC[]);
  (MESON_TAC[EQ_UNIV;IN_UNIV; IN]);

  (SUBGOAL_THEN 
   `inv (&1 + F12 a' pow 2) = g' ((F12:real-> real) a')`
     ASSUME_TAC);
    (* Subgoal 3.5.2 *)
  (EXPAND_TAC "F12" THEN EXPAND_TAC "g'");
  (MESON_TAC[]);
 
 (ONCE_ASM_REWRITE_TAC[]);
 DEL_TAC ; 
 (REPLICATE_TAC 2 UP_ASM_TAC); 
 (MP_TAC HAS_REAL_DERIVATIVE_CHAIN2); 
 (MESON_TAC[]);

(* ========================================================================= *)
(*           THIS PART TO TO REDUCE THE DERIVATIVE OF F1                     *)
(*             Derivative of  F1 is  -- &1 / sqrt d                          *)  
(* ========================================================================= *)

(* --------------------------------------------------------------------------*)
(*     Subgoal 3.6                                                           *)
(*                 (&2 * sqrt D') pow 2 = &4 * D'                            *)
(* --------------------------------------------------------------------------*)

  (SUBGOAL_THEN `(&2 * sqrt D') pow 2 = &4 * D'` ASSUME_TAC);
  (REWRITE_TAC[REAL_POW_2]);
  (REWRITE_TAC[REAL_ARITH `(&2 * a) * &2 * b = &4 * (a * b)`]);
  (REWRITE_TAC[GSYM REAL_POW_2]);
  AP_TERM_TAC;
  (MATCH_MP_TAC SQRT_POW_2 THEN ASM_REAL_ARITH_TAC);

(* --------------------------------------------------------------------------*)
(*     Subgoal 3.7                                                           *)
(*               Reduce:  inv (&1 + F12 a' pow 2)                            *)
(* --------------------------------------------------------------------------*)

  (SUBGOAL_THEN 
    `inv (&1 + F12 (a':real) pow 2)  = (&4 * D') / (&4 * D' + Da pow 2)`   
     ASSUME_TAC);
  (EXPAND_TAC "F12");  
  (REWRITE_TAC[REAL_POW_DIV]);
  (ASM_REWRITE_TAC[]);
  (REWRITE_TAC[MESON[REAL_INV_DIV] 
     `(&4 * D') / (&4 * D' + Da pow 2) = 
      inv ((&4 * D' + Da pow 2) / (&4 * D'))`]);
  AP_TERM_TAC;
  (REWRITE_TAC[REAL_ARITH `(a + b) / c = a / c + b / c`]);
  (AP_THM_TAC THEN AP_TERM_TAC);
  (MATCH_MP_TAC (GSYM REAL_DIV_REFL));
  (REWRITE_TAC[MESON[] `~(a = b) <=> ~(b = a)`;REAL_ENTIRE;
                 MESON[] `~(a \/ b) <=> ~a /\ ~b`]);
  ASM_REAL_ARITH_TAC;

(* --------------------------------------------------------------------------*)
(*     Subgoal 3.8                                                           *)
(*               Reduce:  Derivative of F1                                   *)
(* --------------------------------------------------------------------------*)
 
 (SUBGOAL_THEN 
   `(F1 has_real_derivative -- &1 / sqrt D') (atreal a' within s)`
   ASSUME_TAC);

  (SUBGOAL_THEN `2G (a':real) = &2 * sqrt D'` ASSUME_TAC);
    (* Subgoal 3.8.1 *)
  (EXPAND_TAC "2G" THEN EXPAND_TAC "D'");
  (REWRITE_TAC[]);

  (SUBGOAL_THEN `f1 (a':real) = (Da:real)` ASSUME_TAC);  
    (* Subgoal 3.8.2 *)
  (EXPAND_TAC "f1" THEN EXPAND_TAC "Da");
  (REWRITE_TAC[]);

  (SUBGOAL_THEN `&0 < sqrt D'` ASSUME_TAC);
    (* Subgoal 3.8.3 *)
  (MATCH_MP_TAC SQRT_POS_LT);
  (ASM_REWRITE_TAC[]);

  (SUBGOAL_THEN 
    `(-- &2 * 2G (a':real) - f1 a' * &2 * G') / 2G a' pow 2 *
     inv (&1 + F12 a' pow 2) = 
     -- &1 / sqrt D'` 
    ASSUME_TAC);
    (* Subgoal 3.8.4 *)
  (ASM_REWRITE_TAC[]);
  (REWRITE_TAC[REAL_ARITH `(a / b * b / c) = (a / b * b) / c`]);
  (SIMP_TAC[REAL_DIV_RMUL]);

    (SUBGOAL_THEN `~(&4 * D' = &0)` ASSUME_TAC);
      (* Subgoal 3.8.4.1 *)    
    (MATCH_MP_TAC (REAL_ARITH `&0 < a ==> ~ (a = &0)`));
    (MATCH_MP_TAC REAL_LT_MUL);
    ASM_REAL_ARITH_TAC;      

  (ABBREV_TAC `M = (-- &2 * &2 * sqrt D' - Da * &2 * G')`);

    (SUBGOAL_THEN `G' = Da * inv (&2 * sqrt D')` ASSUME_TAC);  
      (* Subgoal 3.8.4.2 *)
    (EXPAND_TAC "G'" THEN EXPAND_TAC "Da" THEN EXPAND_TAC "D'");
    (AP_THM_TAC THEN AP_TERM_TAC);
    (EXPAND_TAC "f1" THEN REAL_ARITH_TAC);

    (SUBGOAL_THEN `M = -- (&4 * D' + Da pow 2) / sqrt D'` ASSUME_TAC);
      (* Subgoal 3.8.4.3 *)
    (EXPAND_TAC "M");
    (REWRITE_TAC[REAL_ARITH `-- &2 * &2 * x = -- &4 * x`]);
    (ONCE_ASM_REWRITE_TAC[]);
    (ABBREV_TAC `X = -- &4 * sqrt D' - Da * &2 * Da * inv (&2 * sqrt D')`);
    (ABBREV_TAC `Y = --(&4 * D' + Da pow 2)`);
    (ABBREV_TAC `Z = sqrt D'`);
    
       (SUBGOAL_THEN `X * Z = Y ==> X = Y / Z ` ASSUME_TAC);
         (* Subgoal 3.8.4.3.1 *)
       (ASM_SIMP_TAC[REAL_EQ_RDIV_EQ]);
    
    (FIRST_X_ASSUM MATCH_MP_TAC);
    (EXPAND_TAC "X" THEN EXPAND_TAC "Y" THEN EXPAND_TAC "Z");
    (REWRITE_TAC[REAL_SUB_RDISTRIB; REAL_NEG_ADD]);
    (REWRITE_TAC[REAL_ARITH ` (a * b * a * c) * d = a pow 2 * c * b * d`]);

      (SUBGOAL_THEN `inv (&2 * sqrt D') * &2 * sqrt D' = &1` ASSUME_TAC);
      (MATCH_MP_TAC REAL_MUL_LINV);
      (REWRITE_TAC[REAL_ENTIRE; MESON[] `~(a \/ b) <=> ~a /\ ~b`]);
      (REWRITE_TAC[REAL_ARITH `~(&2 = &0)`]);
      (MATCH_MP_TAC (REAL_ARITH `&0 < a ==> ~ (a = &0)`));
      (MATCH_MP_TAC SQRT_POS_LT);
      (ASM_REWRITE_TAC[]);

    (ASM_REWRITE_TAC[]);
    (REWRITE_TAC[REAL_ARITH `a - b = a + --b`;REAL_MUL_RID]);
    (AP_THM_TAC THEN AP_TERM_TAC);
    (REWRITE_TAC[REAL_ARITH `(--a * b) * c = -- (a * (b * c))`]);
    (REPEAT AP_TERM_TAC);
    (REWRITE_TAC[GSYM REAL_POW_2]);
    (EXPAND_TAC "Z");
    (MATCH_MP_TAC SQRT_POW_2);
    (MATCH_MP_TAC (REAL_ARITH `&0 < a ==> &0 <= a`));
    (ASM_REWRITE_TAC[]);

    (SUBGOAL_THEN `M / (&4 * D') * &4 * D' = M` ASSUME_TAC);
      (* Subgoal 3.8.4.4 *)
    (ASM_MESON_TAC[REAL_DIV_RMUL]);

  (ONCE_ASM_REWRITE_TAC[]);
  (ONCE_ASM_REWRITE_TAC[]);
  (ASM_REWRITE_TAC [REAL_ARITH `a / b / c = a / c / b`]);
  (AP_THM_TAC THEN AP_TERM_TAC);
  (MATCH_MP_TAC (REAL_ARITH `a / a = &1 ==> -- a / a = -- &1`));
  (MATCH_MP_TAC REAL_DIV_REFL);
  (MATCH_MP_TAC (REAL_ARITH `&0 < a ==> ~ (a = &0)`));
  (MATCH_MP_TAC REAL_LTE_ADD);
  (REWRITE_TAC[REAL_LE_POW_2]);
  (MATCH_MP_TAC REAL_LT_MUL);
  (ASM_REWRITE_TAC[]);
  (REAL_ARITH_TAC);
    (* End of subgoal 3.8.4 *)
 
 (ASM_MESON_TAC[]);

(* Delete unnecessary assumptions in assumption list  *)
 
 (UP_ASM_TAC THEN REPLICATE_TAC 3 DEL_TAC); 
 (UP_ASM_TAC THEN REPLICATE_TAC 3 DEL_TAC); 
 (REPEAT DISCH_TAC);


(* ================ END DIFF F1 ============================================ *)

(* --------------------------------------------------------------------------*)
(*  Subgoal 3.9                                                              *)
(*         Derivative of  (-- &2 * b + &2 * c + &2 * a - c * a) /            *)
(*                          &2 * sqrt (ups_x x b c - x * b * c)              *)  
(* --------------------------------------------------------------------------*)
 
 (ABBREV_TAC `f2 = (\x. -- &2 * b + &2 * c + &2 * x - c * x)`); 
 (ABBREV_TAC `F22 = (\x. (-- &2 * b + &2 * c + &2 * x - c * x) / (&2 * 
  sqrt (ups_x x b c - x * b * c)))`);

  (SUBGOAL_THEN 
    `(F22 has_real_derivative ((&2 - c) * 2G (a':real) - 
     f2 a' * &2 * G') / 2G a' pow 2) (atreal a' within s)`
     ASSUME_TAC);

    (SUBGOAL_THEN ` F22 = (\x:real. f2 x / 2G x )` ASSUME_TAC);
      (* Subgoal 3.9.1 *)
    (EXPAND_TAC "F22" THEN EXPAND_TAC "2G" THEN EXPAND_TAC "f2");   
    (ASM_REWRITE_TAC[]);

    (SUBGOAL_THEN `(f2 has_real_derivative &2 - c) (atreal a' within s) /\
                     (2G has_real_derivative &2 * G') (atreal a' within s) /\
                    ~(2G a' = &0)` ASSUME_TAC);
      (* Subgoal 3.9.2 *) 
    (ASM_REWRITE_TAC[]);
    (REPEAT CONJ_TAC);  (* Break into 2 subgoals *)

    (EXPAND_TAC "f2" THEN REAL_DIFF_TAC THEN REAL_ARITH_TAC);
    (EXPAND_TAC "2G");
    (MATCH_MP_TAC 
      (MESON[REAL_ENTIRE] `~ (x = &0) /\ ~ (y = &0) ==> ~ (x * y = &0)`));
    (REWRITE_TAC[REAL_ARITH `~(&2 = &0)`]);
    (MATCH_MP_TAC (REAL_ARITH `&0 < x ==> ~(x = &0)`));
    (MATCH_MP_TAC SQRT_POS_LT);
    (ASM_REWRITE_TAC[]);
 
 (ASM_REWRITE_TAC[]); 
 (FIRST_X_ASSUM MP_TAC); 
 (MP_TAC HAS_REAL_DERIVATIVE_DIV_WITHIN); 
 (MESON_TAC[]);

(* --------------------------------------------------------------------------*)
(*  Subgoal 3.10                                                             *)
(*         Derivative of  atn ((-- &2 * b + &2 * c + &2 * a - c * a) /       *)
(*                          &2 * sqrt (ups_x x b c - x * b * c))             *)  
(* --------------------------------------------------------------------------*)
 
 (ABBREV_TAC `F2 = (\x. atn ((-- &2 * b + &2 * c + &2 * x - c * x) /(&2 *    
   sqrt (ups_x x b c - x * b * c))))`);
  
 (SUBGOAL_THEN `(F2 has_real_derivative
  ((&2 - c) * 2G a' - f2 a' * &2 * G') / 2G a' pow 2 * inv (&1 + F22 a' pow 2))
  (atreal a' within s)`
   ASSUME_TAC);

  (SUBGOAL_THEN `F2 = (\x. atn (F22 (x:real)))` ASSUME_TAC);
    (* Subgoal 3.10.1 *) 
  (EXPAND_TAC "F2" THEN EXPAND_TAC "F22");
  (REWRITE_TAC[]); 
 
 (PURE_ONCE_ASM_REWRITE_TAC[]); 
 (REPLICATE_TAC 2 DEL_TAC); 
 (ABBREV_TAC `g' = (\x. inv (&1 + x pow 2))`); 
 (ABBREV_TAC `f' = ((&2 - c) * 2G a' - f2 a' * &2 * G') / 
                    2G (a':real) pow 2`);

  (SUBGOAL_THEN 
    `!x. (:real) x ==> (atn has_real_derivative (g':real->real) x) (atreal x)`
    ASSUME_TAC);
    (* Subgoal 3.10.2 *)
  (EXPAND_TAC "g'" THEN REWRITE_TAC[BETA_THM]);
  (REWRITE_TAC[EQ_UNIV;HAS_REAL_DERIVATIVE_ATN]);

  (SUBGOAL_THEN `(F22 has_real_derivative f') (atreal a' within s) /\ 
                   (:real) ((F22:real->real) a')` 
     ASSUME_TAC);
  (ASM_REWRITE_TAC[]);
  (MESON_TAC[EQ_UNIV;IN_UNIV;IN]);

  (SUBGOAL_THEN 
   `inv (&1 + F22 a' pow 2) = g' ((F22:real-> real) a')`
     ASSUME_TAC);
    (* Subgoal 3.10.3 *)
  (EXPAND_TAC "F22" THEN EXPAND_TAC "g'");
  (REWRITE_TAC[]);
 
 (ONCE_ASM_REWRITE_TAC[]);
 DEL_TAC ; 
 (REPLICATE_TAC 2 UP_ASM_TAC); 
 (MP_TAC HAS_REAL_DERIVATIVE_CHAIN2); 
 (MESON_TAC[]);

(* ========================================================================= *)
(*           THIS PART TO TO REDUCE THE DERIVATIVE OF F2                     *)
(*             Derivative of  F2 is  ..... / sqrt d                          *)  
(* ========================================================================= *)

(* --------------------------------------------------------------------------*)
(*     Subgoal 3.11                                                           *)
(*                 (&2 * sqrt D') pow 2 = &4 * D'                            *)
(* --------------------------------------------------------------------------*)

  (SUBGOAL_THEN `(&2 * sqrt D') pow 2 = &4 * D'` ASSUME_TAC);
  (REWRITE_TAC[REAL_POW_2]);
  (REWRITE_TAC[REAL_ARITH `(&2 * a) * &2 * b = &4 * (a * b)`]);
  (REWRITE_TAC[GSYM REAL_POW_2]);
  AP_TERM_TAC;
  (MATCH_MP_TAC SQRT_POW_2 THEN ASM_REAL_ARITH_TAC);

(* --------------------------------------------------------------------------*)
(*     Subgoal 3.12                                                           *)
(*               Reduce:  inv (&1 + F22 a' pow 2)                            *)
(* --------------------------------------------------------------------------*)

  (SUBGOAL_THEN 
    `inv (&1 + F22 (a':real) pow 2)  = (&4 * D') / (&4 * D' + Db pow 2)`   
     ASSUME_TAC);
  (EXPAND_TAC "F22");  
  (REWRITE_TAC[REAL_POW_DIV]);
  (ASM_REWRITE_TAC[]);
  (REWRITE_TAC[MESON[REAL_INV_DIV] 
     `(&4 * D') / (&4 * D' + Db pow 2) = 
      inv ((&4 * D' + Db pow 2) / (&4 * D'))`]);
  AP_TERM_TAC;
  (REWRITE_TAC[REAL_ARITH `(a + b) / c = a / c + b / c`]);
  (EXPAND_TAC "Db");
  (REWRITE_TAC[REAL_ARITH `a + b + c - x * y = a + b + c - y * x`]);
  (AP_THM_TAC THEN AP_TERM_TAC);
  (MATCH_MP_TAC (GSYM REAL_DIV_REFL));
  (REWRITE_TAC[MESON[] `~(a = b) <=> ~(b = a)`;REAL_ENTIRE;
                 MESON[] `~(a \/ b) <=> ~a /\ ~b`]);
  ASM_REAL_ARITH_TAC;


(* --------------------------------------------------------------------------*)
(*     Subgoal 3.13                                                          *)
(*               Reduce:  Derivative of F2                                   *)
(* --------------------------------------------------------------------------*)
 
 (SUBGOAL_THEN 
   `(F2 has_real_derivative 
    (-- &2 * c + &2 * a' + &2 * b - a' * b) / (a' * (&4 - a')) / sqrt D')
    (atreal a' within s)`
   ASSUME_TAC);

  (SUBGOAL_THEN `2G (a':real) = &2 * sqrt D'` ASSUME_TAC);
    (* Subgoal 3.13.1 *)
  (EXPAND_TAC "2G" THEN EXPAND_TAC "D'");
  (REWRITE_TAC[]);

  (SUBGOAL_THEN `f2 (a':real) = (Db:real)` ASSUME_TAC);  
    (* Subgoal 3.13.2 *)
  (EXPAND_TAC "f2" THEN EXPAND_TAC "Db");
  (REAL_ARITH_TAC);

  (SUBGOAL_THEN `&0 < sqrt D'` ASSUME_TAC);
    (* Subgoal 3.13.3 *)
  (MATCH_MP_TAC SQRT_POS_LT);
  (ASM_REWRITE_TAC[]);

  (SUBGOAL_THEN `
    ((&2 - c) * 2G a' - f2 a' * &2 * G') / 2G a' pow 2 *
    inv (&1 + F22 a' pow 2) = 
    (-- &2 * c + &2 * a' + &2 * b - a' * b) / (a' * (&4 - a')) / sqrt D' `
    ASSUME_TAC);
    (* Subgoal 3.13.4 *)
  (ASM_REWRITE_TAC[]);
  (REWRITE_TAC[REAL_ARITH `(a / b * b / c) = (a / b * b) / c`]);
  (SIMP_TAC[REAL_DIV_RMUL]);


    (SUBGOAL_THEN `~(&4 * D' = &0)` ASSUME_TAC);
      (* Subgoal 3.13.4.1 *)    
    (MATCH_MP_TAC (REAL_ARITH `&0 < a ==> ~ (a = &0)`));
    (MATCH_MP_TAC REAL_LT_MUL);
    ASM_REAL_ARITH_TAC;      

  (ABBREV_TAC `M = (&2 - c) * &2 * sqrt D' - Db * &2 * G'`);

    (SUBGOAL_THEN `G' = Da * inv (&2 * sqrt D')` ASSUME_TAC);  
      (* Subgoal 3.13.4.2 *)
    (EXPAND_TAC "G'" THEN EXPAND_TAC "Da" THEN EXPAND_TAC "D'");
    (REWRITE_TAC[]);

    (SUBGOAL_THEN `M = ((&4 - &2 * c) * D' - Da * Db) / sqrt D'` ASSUME_TAC);
      (* Subgoal 3.13.4.3 *)
    (EXPAND_TAC "M");
    (REWRITE_TAC[REAL_ARITH `(&2 - c) * &2 * x = (&4 - &2 * c) * x`]);
    (ONCE_ASM_REWRITE_TAC[]);
    (ABBREV_TAC `X = (&4 - &2 * c) * sqrt D' - 
                       Db * &2 * Da * inv (&2 * sqrt D')`);
    (ABBREV_TAC `Y = (&4 - &2 * c) * D' - Da * Db`);
    (ABBREV_TAC `Z = sqrt D'`);
    
       (SUBGOAL_THEN `X * Z = Y ==> X = Y / Z ` ASSUME_TAC);
         (* Subgoal 3.13.4.3.1 *)
       (ASM_SIMP_TAC[REAL_EQ_RDIV_EQ]);


    (FIRST_X_ASSUM MATCH_MP_TAC);
    (EXPAND_TAC "X" THEN EXPAND_TAC "Y" THEN EXPAND_TAC "Z");
    (ABBREV_TAC `m = &4 - &2 * c`);
    (REWRITE_TAC[REAL_SUB_RDISTRIB;REAL_NEG_ADD]);
    (REWRITE_TAC[REAL_ARITH ` (a * b * c * d) * e = (c * a) * (d * b * e)`]);

      (SUBGOAL_THEN `inv (&2 * sqrt D') * &2 * sqrt D' = &1` ASSUME_TAC);
         (* Subgoal 3.13.4.3.2 *)
      (MATCH_MP_TAC REAL_MUL_LINV);
      (REWRITE_TAC[REAL_ENTIRE; MESON[] `~(a \/ b) <=> ~a /\ ~b`]);
      (REWRITE_TAC[REAL_ARITH `~(&2 = &0)`]);
      (MATCH_MP_TAC (REAL_ARITH `&0 < a ==> ~ (a = &0)`));
      (ASM_REWRITE_TAC[]);

    (PURE_ONCE_ASM_REWRITE_TAC[]);
    (EXPAND_TAC "Y");
    (REWRITE_TAC[REAL_MUL_RID]);
    (AP_THM_TAC THEN AP_TERM_TAC);
    (EXPAND_TAC "m" THEN EXPAND_TAC "Z");
    (REWRITE_TAC[REAL_ARITH `(a * b) * c = a * b * c`]);
    (REPEAT AP_TERM_TAC);
    (REWRITE_TAC[GSYM REAL_POW_2]);
    (MATCH_MP_TAC SQRT_POW_2);
    (MATCH_MP_TAC (REAL_ARITH `&0 < a ==> &0 <= a`));
    (ASM_REWRITE_TAC[]);
      (* End of Subgoal 3.13.4.3 *)


    (SUBGOAL_THEN `M / (&4 * D') * &4 * D' = M` ASSUME_TAC);
      (* Subgoal 3.13.4.4 *)
    (ASM_SIMP_TAC[REAL_DIV_RMUL]);

  (PURE_ONCE_ASM_REWRITE_TAC[] THEN DEL_TAC);  

    (SUBGOAL_THEN 
      `M = ((-- &2 * c + &2 * a' + &2 * b - a' * b) * (&4 - c) * c)/ sqrt D'`
       ASSUME_TAC);
      (* Subgoal 3.13.4.5 *)
    (ONCE_ASM_REWRITE_TAC[]);
    (AP_THM_TAC THEN AP_TERM_TAC);
    (EXPAND_TAC "D'" THEN REWRITE_TAC[ups_x]);
    (EXPAND_TAC "Da" THEN EXPAND_TAC "Db" THEN EXPAND_TAC "f2");
    (EXPAND_TAC "Dc");
    REAL_ARITH_TAC;

  (UP_ASM_TAC THEN DEL_TAC THEN REPEAT DISCH_TAC);
  (ONCE_ASM_REWRITE_TAC[]);
  (EXPAND_TAC "Dc");
  (REWRITE_TAC[REAL_ARITH `a / b / c = a / c / b`]);
  (AP_THM_TAC THEN AP_TERM_TAC);

    (SUBGOAL_THEN 
       `&4 * D' + Db pow 2 = a' * (&4 - a') * (&4 - c) * c` ASSUME_TAC);
      (* Subgoal 3.13.4.6 *)      
    (EXPAND_TAC "Db" THEN EXPAND_TAC "f2" THEN REWRITE_TAC[POW_2] );
    (EXPAND_TAC "D'" THEN REWRITE_TAC[ups_x]);
     REAL_ARITH_TAC;
  
  (ONCE_ASM_REWRITE_TAC[]);
  (ONCE_REWRITE_TAC[REAL_ARITH `(a * b) / c = a * b / c`]);

     (* --------------------------------------------------------------- *)
     (*       ~ ( c = &4) /\ ~ (c = &0)                                 *)
     (* --------------------------------------------------------------- *)

      (SUBGOAL_THEN `~ (c = &4) /\ ~ (c = &0)` ASSUME_TAC);
      ASM_REAL_ARITH_TAC;
      (SUBGOAL_THEN `~ ((&4 - c) * c = &0)` ASSUME_TAC); 
      (REWRITE_TAC[REAL_ENTIRE;MESON[] `~(a \/ b) <=> ~a /\ ~b`]);
      (ASM_REWRITE_TAC[REAL_ARITH ` ~(a - b = &0) <=> ~ (a = b)`]);

      (* --------------------------------------------------------------- *)
      (*       ~ ( a' = &4) /\ ~ (a' = &0)                               *)
      (* --------------------------------------------------------------- *)

      (SUBGOAL_THEN `~ (a' = &4) /\ ~ (a' = &0)` ASSUME_TAC);
      (REPEAT STRIP_TAC);  (* 2 Subgoals *)

        (SUBGOAL_THEN ` D' = -- ((c + b - &4) pow 2)` ASSUME_TAC);
        (EXPAND_TAC "D'" );
        (REWRITE_TAC[ups_x]);
        (ONCE_ASM_REWRITE_TAC[]);
        REAL_ARITH_TAC;
        (SUBGOAL_THEN `D' <= &0` ASSUME_TAC);
        (ASM_REWRITE_TAC[REAL_ARITH `-- c <= &0 <=> &0 <= c`]);
        (MESON_TAC[REAL_LE_POW_2]);
        (MP_TAC (ASSUME `&0 < D'`));      
        (FIRST_X_ASSUM MP_TAC THEN REAL_ARITH_TAC);


        (SUBGOAL_THEN ` D' = -- ((c - b) pow 2)` ASSUME_TAC);
        (EXPAND_TAC "D'" );
        (REWRITE_TAC[ups_x]);
        (ONCE_ASM_REWRITE_TAC[]);
        REAL_ARITH_TAC;
        (SUBGOAL_THEN `D' <= &0` ASSUME_TAC);
        (ASM_REWRITE_TAC[REAL_ARITH `-- c <= &0 <=> &0 <= c`]);
        (MESON_TAC[REAL_LE_POW_2]);
        (MP_TAC (ASSUME `&0 < D'`));      
        (FIRST_X_ASSUM MP_TAC THEN REAL_ARITH_TAC);


     (SUBGOAL_THEN `~ (a' * (&4 - a') = &0)` ASSUME_TAC);
     (REWRITE_TAC[REAL_ENTIRE;MESON[] `~(a \/ b) <=> ~a /\ ~b`]);
     (ASM_REWRITE_TAC[REAL_ARITH ` ~(a - b = &0) <=> ~ (a = b)`]);

      (* --------------------------------------------------------------- *)
      (*       continue                                                  *)
      (* --------------------------------------------------------------- *)

  (ABBREV_TAC `x = -- &2 * c + &2 * a' + &2 * b - a' * b`);
  (ABBREV_TAC `y = (&4 - c) * c`);
  (REWRITE_TAC[REAL_ARITH `a * b * c = (a * b) * c`]);
  (ABBREV_TAC `z = a' * (&4 - a')`);
  (ASM_SIMP_TAC[REDUCE_WITH_DIV_Euler_lemma]);
  (ASM_MESON_TAC[]);
 
 (UP_ASM_TAC THEN REPLICATE_TAC 3 DEL_TAC); 
 (UP_ASM_TAC THEN REPLICATE_TAC 3 DEL_TAC THEN REPEAT DISCH_TAC);

(* ================ END DIFF 2 ============================================= *)



(* --------------------------------------------------------------------------*)
(* Subgoal 14                                                                *)
(*         Derivative of  (-- &2 * c + &2 * a + &2 * b - a * b) /            *)
(*                          &2 * sqrt (ups_x x b c - x * b * c)              *)  
(* --------------------------------------------------------------------------*)
 
 (ABBREV_TAC `f3 = (\x. -- &2 * c + &2 * x + &2 * b - x * b)`); 
 (ABBREV_TAC `F32 = (\x. (-- &2 * c + &2 * x + &2 * b - x * b) /
        (&2 * sqrt (ups_x x b c - x * b * c)))`);

  (SUBGOAL_THEN 
    `(F32 has_real_derivative ((&2 - b) * 2G (a':real) - 
     f3 a' * &2 * G') / 2G a' pow 2) (atreal a' within s)`
     ASSUME_TAC);

    (SUBGOAL_THEN ` F32 = (\x:real. f3 x / 2G x )` ASSUME_TAC);
      (* Subgoal 3.14.1 *)
    (EXPAND_TAC "F32" THEN EXPAND_TAC "2G" THEN EXPAND_TAC "f3");   
    (ASM_REWRITE_TAC[]);

    (SUBGOAL_THEN `(f3 has_real_derivative &2 - b) (atreal a' within s) /\
                     (2G has_real_derivative &2 * G') (atreal a' within s) /\
                    ~(2G a' = &0)` ASSUME_TAC);
      (* Subgoal 3.14.2 *) 
    (ASM_REWRITE_TAC[]);
    (REPEAT CONJ_TAC);  (* Break into 2 subgoals *)

    (EXPAND_TAC "f3" THEN REAL_DIFF_TAC THEN REAL_ARITH_TAC);
    (EXPAND_TAC "2G");
    (MATCH_MP_TAC 
      (MESON[REAL_ENTIRE] `~ (x = &0) /\ ~ (y = &0) ==> ~ (x * y = &0)`));
    (REWRITE_TAC[REAL_ARITH `~(&2 = &0)`]);
    (MATCH_MP_TAC (REAL_ARITH `&0 < x ==> ~(x = &0)`));
    (MATCH_MP_TAC SQRT_POS_LT);
    (ASM_REWRITE_TAC[]);
 
 (ASM_REWRITE_TAC[]); 
 (FIRST_X_ASSUM MP_TAC); 
 (MP_TAC HAS_REAL_DERIVATIVE_DIV_WITHIN); 
 (MESON_TAC[]);


(* --------------------------------------------------------------------------*)
(*  Subgoal 3.15                                                             *)
(*         Derivative of  atn ((-- &2 * c + &2 * a + &2 * b - a * b) /       *)
(*                          &2 * sqrt (ups_x x b c - x * b * c))             *)  
(* --------------------------------------------------------------------------*)
 
 (ABBREV_TAC `F3 = (\x. atn ((-- &2 * c + &2 * x + &2 * b - x * b) /(&2 *    
   sqrt (ups_x x b c - x * b * c))))`);
  
 (SUBGOAL_THEN `(F3 has_real_derivative
  ((&2 - b) * 2G a' - f3 a' * &2 * G') / 2G a' pow 2 * inv (&1 + F32 a' pow 2))
  (atreal a' within s)`
   ASSUME_TAC);

  (SUBGOAL_THEN `F3 = (\x. atn (F32 (x:real)))` ASSUME_TAC);
    (* Subgoal 3.15.1 *) 
  (EXPAND_TAC "F3" THEN EXPAND_TAC "F32");
  (REWRITE_TAC[]); 
 
 (PURE_ONCE_ASM_REWRITE_TAC[]); 
 (REPLICATE_TAC 2 DEL_TAC); 
 (ABBREV_TAC `g' = (\x. inv (&1 + x pow 2))`); 
 (ABBREV_TAC `f' = ((&2 - b) * 2G a' - f3 a' * &2 * G') / 
                    2G (a':real) pow 2`);

  (SUBGOAL_THEN 
    `!x. (:real) x ==> (atn has_real_derivative (g':real->real) x) (atreal x)`
    ASSUME_TAC);
    (* Subgoal 3.15.2 *)
  (EXPAND_TAC "g'" THEN REWRITE_TAC[BETA_THM]);
  (REWRITE_TAC[EQ_UNIV;HAS_REAL_DERIVATIVE_ATN]);

  (SUBGOAL_THEN `(F32 has_real_derivative f') (atreal a' within s) /\ 
                   (:real) ((F32:real->real) a')` 
     ASSUME_TAC);
  (ASM_REWRITE_TAC[]);
  (MESON_TAC[EQ_UNIV;IN_UNIV;IN]);

  (SUBGOAL_THEN 
   `inv (&1 + F32 a' pow 2) = g' ((F32:real-> real) a')`
     ASSUME_TAC);
    (* Subgoal 3.15.3 *)
  (EXPAND_TAC "F32" THEN EXPAND_TAC "g'");
  (REWRITE_TAC[]);
 
 (ONCE_ASM_REWRITE_TAC[]);
    DEL_TAC ; 
 (REPLICATE_TAC 2 UP_ASM_TAC); 
 (MP_TAC HAS_REAL_DERIVATIVE_CHAIN2); 
 (MESON_TAC[]);

(* ========================================================================= *)
(*           THIS PART TO TO REDUCE THE DERIVATIVE OF F3                     *)
(*             Derivative of  F3 is  ..... / sqrt d                          *)  
(* ========================================================================= *)


(* --------------------------------------------------------------------------*)
(*     Subgoal 3.16                                                          *)
(*                 (&2 * sqrt D') pow 2 = &4 * D'                            *)
(* --------------------------------------------------------------------------*)

  (SUBGOAL_THEN `(&2 * sqrt D') pow 2 = &4 * D'` ASSUME_TAC);
  (REWRITE_TAC[REAL_POW_2]);
  (REWRITE_TAC[REAL_ARITH `(&2 * a) * &2 * b = &4 * (a * b)`]);
  (REWRITE_TAC[GSYM REAL_POW_2]);
      AP_TERM_TAC;
  (MATCH_MP_TAC SQRT_POW_2 THEN ASM_REAL_ARITH_TAC);

(* --------------------------------------------------------------------------*)
(*     Subgoal 3.17                                                          *)
(*               Reduce:  inv (&1 + F32 a' pow 2)                            *)
(* --------------------------------------------------------------------------*)

  (SUBGOAL_THEN 
    `inv (&1 + F32 (a':real) pow 2)  = (&4 * D') / (&4 * D' + Dc pow 2)`   
     ASSUME_TAC);
  (EXPAND_TAC "F32");  
  (REWRITE_TAC[REAL_POW_DIV]);
  (ASM_REWRITE_TAC[]);
  (REWRITE_TAC[MESON[REAL_INV_DIV] 
     `(&4 * D') / (&4 * D' + Dc pow 2) = 
      inv ((&4 * D' + Dc pow 2) / (&4 * D'))`]);
      AP_TERM_TAC;
  (REWRITE_TAC[REAL_ARITH `(a + b) / c = a / c + b / c`]);
  (EXPAND_TAC "Dc");
  (REWRITE_TAC[REAL_ARITH `a + b + c - x * y = a + b + c - y * x`]);
  (AP_THM_TAC THEN AP_TERM_TAC);
  (MATCH_MP_TAC (GSYM REAL_DIV_REFL));
  (REWRITE_TAC[MESON[] `~(a = b) <=> ~(b = a)`;REAL_ENTIRE;
                 MESON[] `~(a \/ b) <=> ~a /\ ~b`]);
      ASM_REAL_ARITH_TAC;

(* --------------------------------------------------------------------------*)
(*     Subgoal 3.18                                                          *)
(*               Reduce:  Derivative of F3                                   *)
(* --------------------------------------------------------------------------*)
 
 (SUBGOAL_THEN 
   `(F3 has_real_derivative 
    (-- &2 * b + &2 * a' + &2 * c - a' * c) / (a' * (&4 - a')) / sqrt D')
    (atreal a' within s)`
   ASSUME_TAC);

  (SUBGOAL_THEN `2G (a':real) = &2 * sqrt D'` ASSUME_TAC);
    (* Subgoal 3.18.1 *)
  (EXPAND_TAC "2G" THEN EXPAND_TAC "D'");
  (REWRITE_TAC[]);

  (SUBGOAL_THEN `f3 (a':real) = (Dc:real)` ASSUME_TAC);  
    (* Subgoal 3.18.2 *)
  (EXPAND_TAC "f3" THEN EXPAND_TAC "Dc");
  (REAL_ARITH_TAC);

  (SUBGOAL_THEN `&0 < sqrt D'` ASSUME_TAC);
    (* Subgoal 3.18.3 *)
  (MATCH_MP_TAC SQRT_POS_LT);
  (ASM_REWRITE_TAC[]);

  (SUBGOAL_THEN `
    ((&2 - b) * 2G a' - f3 a' * &2 * G') / 2G a' pow 2 *
    inv (&1 + F32 a' pow 2) = 
    (-- &2 * b + &2 * a' + &2 * c - a' * c) / (a' * (&4 - a')) / sqrt D' `
    ASSUME_TAC);
    (* Subgoal 3.18.4 *)
  (ASM_REWRITE_TAC[]);
  (REWRITE_TAC[REAL_ARITH `(a / b * b / c) = (a / b * b) / c`]);
  (SIMP_TAC[REAL_DIV_RMUL]);

    (SUBGOAL_THEN `~(&4 * D' = &0)` ASSUME_TAC);
      (* Subgoal 3.18.4.1 *)    
    (MATCH_MP_TAC (REAL_ARITH `&0 < a ==> ~ (a = &0)`));
    (MATCH_MP_TAC REAL_LT_MUL);
    (ASM_REWRITE_TAC[] THEN REAL_ARITH_TAC);      

  (ABBREV_TAC `M = (&2 - b) * &2 * sqrt D' - Dc * &2 * G'`);

    (SUBGOAL_THEN `G' = Da * inv (&2 * sqrt D')` ASSUME_TAC);  
      (* Subgoal 3.18.4.2 *)
    (EXPAND_TAC "G'" THEN EXPAND_TAC "Da" THEN EXPAND_TAC "D'");
    (REWRITE_TAC[]);

    (SUBGOAL_THEN `M = ((&4 - &2 * b) * D' - Da * Dc) / sqrt D'` ASSUME_TAC);
      (* Subgoal 3.18.4.3 *)
    (EXPAND_TAC "M");
    (REWRITE_TAC[REAL_ARITH `(&2 - b) * &2 * x = (&4 - &2 * b) * x`]);
    (ONCE_ASM_REWRITE_TAC[]);
    (ABBREV_TAC `X = (&4 - &2 * b) * sqrt D' - 
                       Dc * &2 * Da * inv (&2 * sqrt D')`);
    (ABBREV_TAC `Y = (&4 - &2 * b) * D' - Da * Dc`);
    (ABBREV_TAC `Z = sqrt D'`);
    
      (SUBGOAL_THEN `X * Z = Y ==> X = Y / Z ` ASSUME_TAC);
         (* Subgoal 3.18.4.3.1 *)
      (ASM_SIMP_TAC[REAL_EQ_RDIV_EQ]);

    (FIRST_X_ASSUM MATCH_MP_TAC);
    (EXPAND_TAC "X" THEN EXPAND_TAC "Y" THEN EXPAND_TAC "Z");
    (ABBREV_TAC `m = &4 - &2 * b`);
    (REWRITE_TAC[REAL_SUB_RDISTRIB;REAL_NEG_ADD]);
    (REWRITE_TAC[REAL_ARITH ` (a * b * c * d) * e = (c * a) * (d * b * e)`]);

     (SUBGOAL_THEN `inv (&2 * sqrt D') * &2 * sqrt D' = &1` ASSUME_TAC);
         (* Subgoal 3.18.4.3.2 *)
     (MATCH_MP_TAC REAL_MUL_LINV);
     (REWRITE_TAC[REAL_ENTIRE;MESON[] `~(a \/ b) <=> ~a /\ ~b`]);
     (REWRITE_TAC[REAL_ARITH `~(&2 = &0)`]);
     (MATCH_MP_TAC (REAL_ARITH `&0 < a ==> ~ (a = &0)`));
     (ASM_REWRITE_TAC[]);

    (PURE_ONCE_ASM_REWRITE_TAC[]);
    (EXPAND_TAC "Y");
    (REWRITE_TAC[REAL_MUL_RID]);
    (AP_THM_TAC THEN AP_TERM_TAC);
    (EXPAND_TAC "m" THEN EXPAND_TAC "Z");
    (REWRITE_TAC[REAL_ARITH `(a * b) * c = a * b * c`]);
    (REPEAT AP_TERM_TAC);
    (REWRITE_TAC[GSYM REAL_POW_2]);
    (MATCH_MP_TAC SQRT_POW_2);
    (MATCH_MP_TAC (REAL_ARITH `&0 < a ==> &0 <= a`));
    (ASM_REWRITE_TAC[]);
      (* End of Subgoal 3.18.4.3 *)

    (SUBGOAL_THEN `M / (&4 * D') * &4 * D' = M` ASSUME_TAC);
      (* Subgoal 3.18.4.4 *)
    (ASM_SIMP_TAC[REAL_DIV_RMUL]);
  
  (PURE_ONCE_ASM_REWRITE_TAC[] THEN DEL_TAC);  

    (SUBGOAL_THEN 
      `M = ((-- &2 * b + &2 * a' + &2 * c - a' * c) * (&4 - b) * b)/ sqrt D'`
       ASSUME_TAC);
      (* Subgoal 3.18.4.5 *)
    (ONCE_ASM_REWRITE_TAC[]);
    (AP_THM_TAC THEN AP_TERM_TAC);
    (EXPAND_TAC "D'" THEN REWRITE_TAC[ups_x]);
    (EXPAND_TAC "Da" THEN EXPAND_TAC "Dc" THEN EXPAND_TAC "f3");
    REAL_ARITH_TAC;

  (UP_ASM_TAC THEN DEL_TAC THEN REPEAT DISCH_TAC);
  (ONCE_ASM_REWRITE_TAC[]);
  (EXPAND_TAC "Dc");
  (REWRITE_TAC[REAL_ARITH `a / b / c = a / c / b`]);
  (AP_THM_TAC THEN AP_TERM_TAC);

    (SUBGOAL_THEN 
       `&4 * D' + f3 a' pow 2 = a' * (&4 - a') * (&4 - b) * b` ASSUME_TAC);
      (* Subgoal 3.18.4.6 *)      
    (EXPAND_TAC "f3" THEN REWRITE_TAC[POW_2] );
    (EXPAND_TAC "D'" THEN REWRITE_TAC[ups_x]);
   REAL_ARITH_TAC;

  (ONCE_ASM_REWRITE_TAC[]);
  (ONCE_REWRITE_TAC[REAL_ARITH `(a * b) / c = a * b / c`]);

     (* --------------------------------------------------------------- *)
     (*       ~ ( b = &4) /\ ~ (b = &0)                                 *)
     (* --------------------------------------------------------------- *)

    (SUBGOAL_THEN `~ (b = &4) /\ ~ (b = &0)` ASSUME_TAC);
    (ASM_REAL_ARITH_TAC);

     (SUBGOAL_THEN `~ ((&4 - b) * b = &0)` ASSUME_TAC); 
     (REWRITE_TAC[REAL_ENTIRE;MESON[] `~(a \/ b) <=> ~a /\ ~b`]);
     (ASM_REWRITE_TAC[REAL_ARITH ` ~(a - b = &0) <=> ~ (a = b)`]);

      (* --------------------------------------------------------------- *)
      (*       ~ ( a' = &4) /\ ~ (a' = &0)                               *)
      (* --------------------------------------------------------------- *)

     (SUBGOAL_THEN `~ (a' = &4) /\ ~ (a' = &0)` ASSUME_TAC);
     (REPEAT STRIP_TAC);  (* 2 Subgoals *)

        (SUBGOAL_THEN ` D' = -- ((c + b - &4) pow 2)` ASSUME_TAC);
        (EXPAND_TAC "D'" );
        (REWRITE_TAC[ups_x]);
        (ONCE_ASM_REWRITE_TAC[]);
         REAL_ARITH_TAC;
        (SUBGOAL_THEN `D' <= &0` ASSUME_TAC);
        (ASM_REWRITE_TAC[REAL_ARITH `-- c <= &0 <=> &0 <= c`]);
        (MESON_TAC[REAL_LE_POW_2]);
        (MP_TAC (ASSUME `&0 < D'`));
        (FIRST_ASSUM MP_TAC THEN REAL_ARITH_TAC);

        (SUBGOAL_THEN ` D' = -- ((c - b) pow 2)` ASSUME_TAC);
        (EXPAND_TAC "D'" );
        (REWRITE_TAC[ups_x]);
        (ONCE_ASM_REWRITE_TAC[]);
         REAL_ARITH_TAC;
        (SUBGOAL_THEN `D' <= &0` ASSUME_TAC);
        (ASM_REWRITE_TAC[REAL_ARITH `-- c <= &0 <=> &0 <= c`]);
        (MESON_TAC[REAL_LE_POW_2]);
        (MP_TAC (ASSUME `&0 < D'`));
        (FIRST_ASSUM MP_TAC THEN REAL_ARITH_TAC);

     (SUBGOAL_THEN `~ (a' * (&4 - a') = &0)` ASSUME_TAC);
     (REWRITE_TAC[REAL_ENTIRE; MESON[] `~(a \/ b) <=> ~a /\ ~b`]);
     (ASM_REWRITE_TAC[REAL_ARITH ` ~(a - b = &0) <=> ~ (a = b)`]);

      (* --------------------------------------------------------------- *)
      (*       continue                                                  *)
      (* --------------------------------------------------------------- *)

  (ABBREV_TAC `x = -- &2 * b + &2 * a' + &2 * c - a' * c`);
  (ABBREV_TAC `y = (&4 - b) * b`);
  (REWRITE_TAC[REAL_ARITH `a * b * c = (a * b) * c`]);
  (ABBREV_TAC `z = a' * (&4 - a')`);
  (ASM_SIMP_TAC[REDUCE_WITH_DIV_Euler_lemma]);
  (ASM_MESON_TAC[]);
 
 (UP_ASM_TAC THEN REPLICATE_TAC 3 DEL_TAC); 
 (UP_ASM_TAC THEN REPLICATE_TAC 3 DEL_TAC THEN REPEAT DISCH_TAC);

(* ================ END DIFF 3 ============================================= *)


(* --------------------------------------------------------------------------*)
(*    Subgoal 3.19.                                                          *)
(*       Derivative of  (&8 - a - b - c) / sqrt (ups_x a b c - a * b * c)    *)  
(* --------------------------------------------------------------------------*)
 
 (ABBREV_TAC `f4 = (\x. (&8 - x - b - c))`); 
 (ABBREV_TAC `F42 = (\x. (&8 - x - b - c) / sqrt (ups_x x b c - x * b * c))`);
 
 (SUBGOAL_THEN 
  `(F42 has_real_derivative (-- &1 * G a' - f4 a' * G') / G a' pow 2)
   (atreal a' within s)`
   ASSUME_TAC);

  (SUBGOAL_THEN ` F42 = (\x:real. f4 x / G x)` ASSUME_TAC);
    (* Subgoal 3.19.1  *)
  (EXPAND_TAC "F42" THEN EXPAND_TAC "G" THEN EXPAND_TAC "f4");
  (REWRITE_TAC[]);
 
 (PURE_ONCE_ASM_REWRITE_TAC[] THEN REPLICATE_TAC 2 DEL_TAC);

  (SUBGOAL_THEN `(f4 has_real_derivative -- &1) (atreal a' within s) /\
                   (G has_real_derivative G') (atreal a' within s) /\
                   ~(G a' = &0)` ASSUME_TAC);
    (* Subgoal 3.19.2 *)
  (ASM_REWRITE_TAC[]);
  CONJ_TAC;  (* Break into 2 subgoals *)
  
    (EXPAND_TAC "f4" THEN REAL_DIFF_TAC THEN REAL_ARITH_TAC);
      (* End one of 2 subgoals *)
    (EXPAND_TAC "G");
    (MATCH_MP_TAC (REAL_ARITH `&0 < a ==> ~ (a = &0)`));
    (MATCH_MP_TAC SQRT_POS_LT);
    (ASM_REWRITE_TAC[]);
 
 (FIRST_X_ASSUM MP_TAC); 
 (MP_TAC HAS_REAL_DERIVATIVE_DIV_WITHIN); 
 (MESON_TAC[]);

(* --------------------------------------------------------------------------*)
(*    Subgoal 3.20.                                                          *)
(*  Derivative of  atn ((&8 - a - b - c) / sqrt (ups_x a b c - a * b * c))   *) 
(* --------------------------------------------------------------------------*)
 
 (ABBREV_TAC 
  `F4 = (\x. atn ((&8 - x - b - c) / (sqrt (ups_x x b c - x * b * c))))`);
 
 (SUBGOAL_THEN 
  `(F4 has_real_derivative
    (-- &1 * G a' - f4 a' * G') / G a' pow 2 * inv (&1 + F42 a' pow 2))
   (atreal a' within s)`
  ASSUME_TAC);

  (SUBGOAL_THEN `F4 = (\x. atn (F42 (x:real)))` ASSUME_TAC);
    (* Subgoal 3.20.1 *)
  (EXPAND_TAC "F4" THEN EXPAND_TAC "F42");
  (REWRITE_TAC[]); 
 
 (PURE_ONCE_ASM_REWRITE_TAC[]); 
 (REPLICATE_TAC 2 DEL_TAC); 
 (ABBREV_TAC `g' = (\x. inv (&1 + x pow 2))`); 
 (ABBREV_TAC `f' = ( -- &1 * G (a':real) - f4 a' * G') / G  a' pow 2`);

  (SUBGOAL_THEN 
     `inv (&1 + F42 a' pow 2) = g' ((F42:real-> real) a')`
     ASSUME_TAC);
    (* Subgoal 3.20.2 *)
  (EXPAND_TAC "F42" THEN EXPAND_TAC "g'");
  (REWRITE_TAC[]);

  (SUBGOAL_THEN 
   `!x. (:real) x ==> (atn has_real_derivative (g':real->real) x) (atreal x)`
     ASSUME_TAC);
    (* Subgoal 3.20.3 *)
  (EXPAND_TAC "g'" THEN REWRITE_TAC[BETA_THM]);
  (REWRITE_TAC[EQ_UNIV;HAS_REAL_DERIVATIVE_ATN]);

  (SUBGOAL_THEN 
   `(F42 has_real_derivative f') (atreal a' within s) /\ 
    (:real) ((F42:real->real) a')`
    ASSUME_TAC);
    (* Subgoal 3.20.4 *)
  (ASM_REWRITE_TAC[]);
  (MESON_TAC[EQ_UNIV;IN_UNIV;IN]);
 
 (ONCE_ASM_REWRITE_TAC[]); 
 (REPLICATE_TAC 2 UP_ASM_TAC); 
 (MP_TAC HAS_REAL_DERIVATIVE_CHAIN2); 
 (MESON_TAC[]);


(* ========================================================================= *)
(*           THIS PART TO TO REDUCE THE DERIVATIVE OF F4                     *)
(*             Derivative of  F4 is  ..... ........                          *)  
(* ========================================================================= *)
(*          Subgoal 3.21                                                     *)
(* ------------------------------------------------------------------------- *)
 
 (SUBGOAL_THEN 
   `(F4 has_real_derivative (a' - b - c) / &2 / (&4 - a') / sqrt D')
    (atreal a' within s)`
  ASSUME_TAC);

  (SUBGOAL_THEN `G (a':real) = sqrt D'` ASSUME_TAC);
    (* Subgoal 3.21.1 *)
  (EXPAND_TAC "G" THEN EXPAND_TAC "D'");
  (REWRITE_TAC[]);
 
 (ABBREV_TAC `D4 = &8 - a' - b - c`);

  (SUBGOAL_THEN `f4 (a':real) = (D4:real)` ASSUME_TAC);  
    (* Subgoal 3.21.2 *)
  (EXPAND_TAC "f4" THEN EXPAND_TAC "D4");
  (REWRITE_TAC[]);

  (SUBGOAL_THEN `&0 < sqrt D'` ASSUME_TAC);
    (* Subgoal 3.21.3 *)
  (MATCH_MP_TAC SQRT_POS_LT);
  (ASM_REWRITE_TAC[]); 

  (SUBGOAL_THEN 
   `(-- &1 * G a' - f4 a' * G') / G a' pow 2 * inv (&1 + F42 a' pow 2) =
    (a' - b - c) / &2 / (&4 - a') / sqrt D'`
    ASSUME_TAC);
    (* Subgoal 3.21.4 *)
  (ASM_REWRITE_TAC[]);

    (SUBGOAL_THEN `sqrt D' pow 2 = D'` ASSUME_TAC);
      (* Subgoal 3.21.4.1 *)
    (MATCH_MP_TAC SQRT_POW_2);
    (MATCH_MP_TAC (REAL_ARITH `&0 < a ==> &0 <= a`));
    (ASM_REWRITE_TAC[]);
 
    (SUBGOAL_THEN 
      `inv (&1 + F42 (a':real) pow 2)  = D' / (D' + D4 pow 2)` ASSUME_TAC);
      (* Subgoal 3.21.4.2 *)
    (EXPAND_TAC "F42");
    (ONCE_ASM_REWRITE_TAC[]);
    (REWRITE_TAC[REAL_POW_DIV]);
    (ONCE_ASM_REWRITE_TAC[]);
    (PURE_ONCE_REWRITE_TAC[GSYM REAL_INV_DIV]);
    AP_TERM_TAC;
    (PURE_ONCE_REWRITE_TAC[REAL_INV_DIV]);
    (REWRITE_TAC[REAL_ARITH `(a + b) / c = a / c + b / c`]);
    (AP_THM_TAC THEN AP_TERM_TAC);    
    (MATCH_MP_TAC (GSYM REAL_DIV_REFL));
    (MATCH_MP_TAC (REAL_ARITH `&0 < a ==> ~ (&0 = a)`));
    (ASM_REWRITE_TAC[]);    

  (ONCE_ASM_REWRITE_TAC[] THEN DEL_TAC THEN DEL_TAC);
  (PURE_REWRITE_TAC[REAL_ARITH `-- &1 * x = -- x`]);
  (ABBREV_TAC `M = -- sqrt D' - D4 * G'`);

    (SUBGOAL_THEN
      `D' + D4 pow 2 = (&4 - a') * (&4 - b) * (&4 - c)` ASSUME_TAC);
      (* Subgoal 3.21.4.3 *)
    (EXPAND_TAC "D4");
    (EXPAND_TAC "D'" THEN REWRITE_TAC[ups_x]);
    (EXPAND_TAC "f4");
    REAL_ARITH_TAC;
 
    (SUBGOAL_THEN `G' = Da * inv (&2 * sqrt D')` ASSUME_TAC);  
      (* Subgoal 3.21.4.4 *)
    (EXPAND_TAC "G'" THEN EXPAND_TAC "Da");
    (REPEAT AP_TERM_TAC);
    (ASM_REWRITE_TAC[]);

    (SUBGOAL_THEN 
     `M = (a' - b - c) * ((&4 - b) * (&4 - c)) / &2 / sqrt D'` ASSUME_TAC);
      (* Subgoal 3.21.4.5 *)
    (EXPAND_TAC "M");
    (UP_ASM_TAC THEN UP_ASM_TAC THEN DEL_TAC THEN REPEAT DISCH_TAC);
    (ONCE_ASM_REWRITE_TAC[]);
    (ABBREV_TAC `X = --sqrt D' - D4 * Da * inv (&2 * sqrt D') `);
    (REWRITE_TAC[REAL_ARITH `a * (b * c) / d / e = ((a * b * c) / d) / e`]);
    (ABBREV_TAC `Y = ((a' - b - c) * (&4 - b) * (&4 - c)) / &2`);
    (ABBREV_TAC `Z = sqrt D'`);

     (SUBGOAL_THEN `X * Z = Y ==> X = Y / Z ` ASSUME_TAC);
        (* Subgoal 3.21.4.5.1 *)
     (ASM_SIMP_TAC[REAL_EQ_RDIV_EQ]);

    (FIRST_ASSUM MATCH_MP_TAC);
    (EXPAND_TAC "X" THEN EXPAND_TAC "Y" THEN EXPAND_TAC "Z");
    (REWRITE_TAC[REAL_SUB_RDISTRIB]);

     (SUBGOAL_THEN `--sqrt D' * sqrt D' = -- D'` ASSUME_TAC);
        (* Subgoal 3.21.4.5.2 *)
     (MATCH_MP_TAC (REAL_ARITH `a * b = c ==> -- a * b = -- c`));
     (REWRITE_TAC[GSYM REAL_POW_2]);
     (MATCH_MP_TAC SQRT_POW_2);
     (MATCH_MP_TAC (REAL_ARITH `&0 < x ==> &0 <= x`));
     (ASM_REWRITE_TAC[]);

     (SUBGOAL_THEN 
        `(D4 * Da * inv (&2 * sqrt D')) * sqrt D' = D4 * Da / &2` ASSUME_TAC);
        (* Subgoal 3.21.4.5.3 *)
     (REWRITE_TAC[REAL_INV_MUL]);
     (REWRITE_TAC[REAL_ARITH 
       `(a * b * c * d) * e = (a * b * c) * (d * e)`]);
         
         (SUBGOAL_THEN `inv (sqrt D') * sqrt D' = &1 ` ASSUME_TAC);
         (MATCH_MP_TAC REAL_MUL_LINV);
         (MATCH_MP_TAC (REAL_ARITH `&0 < x ==> ~(x = &0)`));
         (MATCH_MP_TAC SQRT_POS_LT);
         (ASM_REWRITE_TAC[]);

     (ASM_REWRITE_TAC[REAL_MUL_RID]);
      REAL_ARITH_TAC;

    (ASM_REWRITE_TAC[]);
    (EXPAND_TAC "D'" THEN EXPAND_TAC "D4" THEN EXPAND_TAC "Da");
    (REWRITE_TAC[ups_x]);
    (EXPAND_TAC "f4");
    (REAL_ARITH_TAC);
   (* End Subgoal 3.21.4.5 *)

  (REWRITE_TAC[REAL_ARITH `a / b * c / d = (a / b * c) / d`]);

    (SUBGOAL_THEN `(M / D' * D') = M` ASSUME_TAC);
    (MATCH_MP_TAC REAL_DIV_RMUL);
    (MATCH_MP_TAC (REAL_ARITH `&0 < x ==> ~ ( x = &0) `));
    (ASM_REWRITE_TAC[]);

  (ASM_REWRITE_TAC[]);
  (REWRITE_TAC[REAL_ARITH `(a * x / b / c) / d = (a * x / d) / b / c`]);
  (AP_THM_TAC THEN AP_TERM_TAC);
  (ONCE_REWRITE_TAC[REAL_ARITH ` a/ &2 / b = a / b / &2`]);
  (AP_THM_TAC THEN AP_TERM_TAC);
  (ABBREV_TAC `S = (&4 - b) * (&4 - c)`);

        (* ----------------------------------------------------- *)
        (*       ~ ( c = &4)                                     *)
        (* ----------------------------------------------------- *)
         (SUBGOAL_THEN `~ (&4 - b = &0) /\ ~ (&4 - c = &0)` ASSUME_TAC);
          ASM_REAL_ARITH_TAC;

        (* ----------------------------------------------------- *)
        (*        ~ (a' = &4)                                     *)
        (* ----------------------------------------------------- *)

         (SUBGOAL_THEN `~ (&4 - a' = &0)` ASSUME_TAC);
         (MATCH_MP_TAC (REAL_ARITH `~ (x = &4) ==> ~ (&4 - x = &0)`));
          STRIP_TAC;
         
           (SUBGOAL_THEN ` D' = -- ((b + c - &4) pow 2)` ASSUME_TAC);
           (EXPAND_TAC "D'" );
           (REWRITE_TAC[ups_x]);
           (ONCE_ASM_REWRITE_TAC[]);
            REAL_ARITH_TAC;

           (SUBGOAL_THEN `D' <= &0` ASSUME_TAC);
           (ASM_REWRITE_TAC[REAL_ARITH `-- a <= &0 <=> &0 <= a`]);
           (MESON_TAC[REAL_LE_POW_2]);

           (MP_TAC (ASSUME `&0 < D'`));
           (FIRST_X_ASSUM MP_TAC THEN REAL_ARITH_TAC);

(* ===================================================================== *)

        (* ----------------------------------------------------- *)
        (*        Continue                                       *)
        (* ----------------------------------------------------- *)

    (SUBGOAL_THEN `~ (S = &0)` ASSUME_TAC);
    (EXPAND_TAC "S");
    (REWRITE_TAC [REAL_ENTIRE;MESON[] `~(a \/ b) <=> ~a /\ ~b `]);
    (ASM_REWRITE_TAC[]);

  (ASM_MESON_TAC[REDUCE_WITH_DIV_Euler_lemma]);
    (* End of subgoal  *)
 
 (ASM_MESON_TAC[]); 
 (UP_ASM_TAC); 
 (DEL_TAC THEN UP_ASM_TAC); 
 (DEL_TAC THEN DEL_TAC THEN DEL_TAC); 
 (REPEAT DISCH_TAC);


(* ================ END DIFF 4 ============================================== *)


(* ========================================================================= *)
(*               END OF THE FIRST GOAL                                       *)
(* ========================================================================= *)

(* ------------------------------------------------------------------------- *)
(*          Subgoal 3.22                                                     *)
(* ------------------------------------------------------------------------- *)
 
 (ABBREV_TAC `FUNCTION = (\a. --pi / &2 -
       atn
       ((-- &2 * a + &2 * b + &2 * c - b * c) /
        (&2 * sqrt (ups_x a b c - a * b * c))) -
       atn
       ((-- &2 * b + &2 * c + &2 * a - c * a) /
        (&2 * sqrt (ups_x a b c - a * b * c))) -
       atn
       ((-- &2 * c + &2 * a + &2 * b - a * b) /
        (&2 * sqrt (ups_x a b c - a * b * c))) +
       &2 * atn ((&8 - a - b - c) / sqrt (ups_x a b c - a * b * c)))`);

  (SUBGOAL_THEN 
    `FUNCTION = (\(a:real). --pi / &2 - F1 a - F2 a - F3 a + &2 * F4 a)`
     ASSUME_TAC);
  (EXPAND_TAC "FUNCTION");
  (EXPAND_TAC "F1" THEN EXPAND_TAC "F2");
  (EXPAND_TAC "F3" THEN EXPAND_TAC "F4");
  (REWRITE_TAC[]); 
 
 (ABBREV_TAC `F1' = -- &1 / sqrt D'`); 
 (ABBREV_TAC `F2' = 
  (-- &2 * c + &2 * a' + &2 * b - a' * b) / (a' * (&4 - a')) / sqrt D'`); 
 (ABBREV_TAC `F3' = 
  (-- &2 * b + &2 * a' + &2 * c - a' * c) / (a' * (&4 - a')) / sqrt D'`); 
 (ABBREV_TAC `F4' = (a' - b - c) / &2 / (&4 - a') / sqrt D'`);

(* ------------------------------------------------------------------------- *)
(*          Subgoal 3.23                                                     *)
(* ------------------------------------------------------------------------- *)

  (SUBGOAL_THEN ` &0 - F1' - F2' - F3' + &2 * F4' = &0` ASSUME_TAC);
  (EXPAND_TAC "F1'" THEN EXPAND_TAC "F2'");
  (EXPAND_TAC "F3'" THEN EXPAND_TAC "F4'");
  (REWRITE_TAC[REAL_ARITH `&0 - a - b - c + d = &0 <=> a + b + c = d `]);
  (REWRITE_TAC[REAL_ARITH `a / x + b / x = (a + b) / x`]);
  (REWRITE_TAC[REAL_ARITH `a * b / c / d / e  = ((a * b / c) / d) / e`]);
  (AP_THM_TAC THEN AP_TERM_TAC);
  (REWRITE_TAC[REAL_ARITH 
      `(-- &2 * c + &2 * a' + &2 * b - a' * b) + 
        -- &2 * b + &2 * a' + &2 * c - a' * c = 
        a' * (&4 - b - c)`]);

    (* --------------------------------------------------------------- *)
    (*       ~ ( a' = &4) /\ ~ (a' = &0)                               *)
    (* --------------------------------------------------------------- *)

    (SUBGOAL_THEN `~ (&4 - a' = &0) /\ ~ (a' = &0)` ASSUME_TAC);
    (REWRITE_TAC[REAL_ARITH `~ (&4 - a' = &0) <=> ~ (a' = &4)`]);
    (REPEAT STRIP_TAC);  (* 2 Subgoals *)

     (SUBGOAL_THEN ` D' = -- ((c + b - &4) pow 2)` ASSUME_TAC);
     (EXPAND_TAC "D'" );
     (REWRITE_TAC[ups_x]);
     (ONCE_ASM_REWRITE_TAC[]);
      REAL_ARITH_TAC;
     (SUBGOAL_THEN `D' <= &0` ASSUME_TAC);
     (ASM_REWRITE_TAC[REAL_ARITH `-- c <= &0 <=> &0 <= c`]);
     (MESON_TAC[REAL_LE_POW_2]);
     (MP_TAC (ASSUME `&0 < D'`));
     (FIRST_ASSUM MP_TAC THEN REAL_ARITH_TAC);

     (SUBGOAL_THEN ` D' = -- ((c - b) pow 2)` ASSUME_TAC);
     (EXPAND_TAC "D'" );
     (REWRITE_TAC[ups_x]);
     (ONCE_ASM_REWRITE_TAC[]);
      REAL_ARITH_TAC;
     (SUBGOAL_THEN `D' <= &0` ASSUME_TAC);
     (ASM_REWRITE_TAC[REAL_ARITH `-- c <= &0 <=> &0 <= c`]);
     (MESON_TAC[REAL_LE_POW_2]);
     (MP_TAC (ASSUME `&0 < D'`));
     (FIRST_ASSUM MP_TAC THEN REAL_ARITH_TAC);

    (SUBGOAL_THEN `~ (a' * (&4 - a') = &0)` ASSUME_TAC);
    (REWRITE_TAC[REAL_ENTIRE;MESON[] `~(a \/ b) <=> ~a /\ ~b`]);
    (ASM_REWRITE_TAC[]);

  (REWRITE_TAC[REAL_ARITH `&2 * x / &2 = x`]);

    (SUBGOAL_THEN `-- &1 = -- (&4 - a') / (&4 - a')` ASSUME_TAC);
    (MATCH_MP_TAC (REAL_ARITH `(a = b/c) ==> (-- a = -- b/c)`));
    (ASM_SIMP_TAC[REAL_DIV_REFL]);
  
  (ASM_REWRITE_TAC[]);
  (REWRITE_TAC[REAL_ARITH `(-- x /y + z = t / y) <=> (z = (t + x) / y)`]);
  (REWRITE_TAC[REAL_ARITH `a - x - y + z - a = z - x - y`]);
  (REWRITE_TAC[REAL_ARITH `(x * y) / (x * z) = y * x / (z * x)`]); 
  (MATCH_MP_TAC REDUCE_WITH_DIV_Euler_lemma);
  (ASM_REWRITE_TAC[]);
 
 (UP_ASM_TAC THEN REPLICATE_TAC 4 DEL_TAC); 
 (REPLICATE_TAC 5 (UP_ASM_TAC THEN DEL_TAC)); 
 (REPEAT DISCH_TAC);

(* ------------------------------------------------------------------------- *)
(*          Subgoal 3.24                                                     *)
(* ------------------------------------------------------------------------- *)
 
 (ABBREV_TAC `FUNC1 = (\(a:real). F1 a + F2 a + F3 a)`); 
 (ABBREV_TAC `FUNC2 = (\(a:real). --pi / &2 + &2 * F4 a)`);

  (SUBGOAL_THEN 
     `(FUNC1 has_real_derivative F1' + F2' + F3') (atreal a' within s)`
     ASSUME_TAC);
  (ABBREV_TAC `X = (\(a:real). F2 a + F3 a)`);
  (ABBREV_TAC `X' = F2' + F3'`);

    (SUBGOAL_THEN 
      `(X has_real_derivative X') (atreal a' within s)` ASSUME_TAC);
      (* Subgoal 3.24.1 *)  
    (EXPAND_TAC "X" THEN EXPAND_TAC "X'");
    (ASM_SIMP_TAC[HAS_REAL_DERIVATIVE_ADD]);

    (SUBGOAL_THEN `FUNC1 = (\(a:real). F1 a + X a)` ASSUME_TAC);
      (* Subgoal 3.24.2 *)  
    (EXPAND_TAC "X");
    (ASM_REWRITE_TAC[]);

    (ASM_REWRITE_TAC[]);
    (ASM_SIMP_TAC[HAS_REAL_DERIVATIVE_ADD]);

(* ------------------------------------------------------------------------- *)
(*          Subgoal 3.25                                                     *)
(* ------------------------------------------------------------------------- *)

  (SUBGOAL_THEN 
    `(FUNC2 has_real_derivative &0 + &2 * F4') (atreal a' within s)`
     ASSUME_TAC);
  (ABBREV_TAC `X = (\(a:real). -- pi / &2)`);
  (ABBREV_TAC `Y = (\(a:real). &2 * F4 a)`);

    (SUBGOAL_THEN 
     `(X has_real_derivative &0) (atreal a' within s)` ASSUME_TAC);
      (* Subgoal 3.25.1 *)  
    (EXPAND_TAC "X");
    (REAL_DIFF_TAC);
    (REWRITE_TAC[]);

    (SUBGOAL_THEN 
      `(Y has_real_derivative &2 * F4') (atreal a' within s)` ASSUME_TAC);
      (* Subgoal 3.25.2 *)  
    (EXPAND_TAC "Y");
    (MATCH_MP_TAC HAS_REAL_DERIVATIVE_LMUL_WITHIN);
    (ASM_REWRITE_TAC[]);

    (SUBGOAL_THEN `FUNC2 = (\(a:real). X a + Y a)` ASSUME_TAC);
      (* Subgoal 3.25.3 *)  
    (EXPAND_TAC "X" THEN EXPAND_TAC "Y");
    (ASM_REWRITE_TAC[]);

  (ASM_REWRITE_TAC[]);
  (ASM_SIMP_TAC[HAS_REAL_DERIVATIVE_ADD]);

(* ------------------------------------------------------------------------- *)
(*          Subgoal 3.26                                                     *)
(* ------------------------------------------------------------------------- *)

  (SUBGOAL_THEN `FUNCTION = (\(a:real). FUNC2 a - FUNC1 a)` ASSUME_TAC);
  (EXPAND_TAC "FUNC1" THEN EXPAND_TAC "FUNC2");
  (REWRITE_TAC[REAL_ARITH `(a + b) - (c + d + e) = a - c - d - e + b`]);
  (ASM_REWRITE_TAC[]);

(* ------------------------------------------------------------------------- *)
(*          Subgoal 3.27                                                     *)
(* ------------------------------------------------------------------------- *)

  (SUBGOAL_THEN 
   `(FUNCTION has_real_derivative &0 - F1' - F2' - F3' + &2 * F4')
    (atreal a' within s)`
    ASSUME_TAC);
  (REWRITE_TAC[REAL_ARITH `a - c - d - e + b = (a + b) - (c + d + e)`]);
  (ASM_MESON_TAC[HAS_REAL_DERIVATIVE_SUB]);
 
 (ASM_MESON_TAC[]);


(* ========================================================================= *)
(*                                                                           *)
(*                 FINISH COMPUTE FIRST DERIVATIVES                          *)
(*                                                                           *)
(* ========================================================================= *)


(* ------------------------------------------------------------------------- *)
(*       SUBGOAL 4.1                                                         *)
(*       ~ ( c = &4) /\ ~ (c = &0)                                           *)
(* ------------------------------------------------------------------------- *)

  (SUBGOAL_THEN `~ (c = &4) /\ ~ (c = &0)` ASSUME_TAC);
  ASM_REAL_ARITH_TAC;

(* ------------------------------------------------------------------------- *)
(*       SUBGOAL 4.2                                                         *)
(*                     Reduce the expression                                 *)
(* ------------------------------------------------------------------------- *)
 
 (PURE_REWRITE_TAC[REAL_ARITH 
  `&8 - (b + c - (b * c) / &2) - b - c = 
   &8 + (b * c) / &2 - &2 * b  - &2 * c`]); 
 (PURE_REWRITE_TAC[REAL_ARITH 
    `-- &2 * (b + c - (b * c) / &2) + &2 * b + &2 * c - b * c = &0 `]); 
 (REWRITE_TAC[REAL_ARITH `&0 * x = &0 /\ &0 / x = &0`; 
               ATN_0; REAL_ARITH `a - &0 = a`]); 
 (PURE_REWRITE_TAC[REAL_ARITH 
  `-- &2 * b + &2 * c + &2 * (b + c - (b * c) / &2) - 
   c * (b + c - (b * c) / &2) = 
  (&1 - b / &2) * (&4 - c) * c `]); 
 (PURE_REWRITE_TAC[REAL_ARITH 
  `-- &2 * c + &2 * (b + c - (b * c) / &2) + 
   &2 * b - (b + c - (b * c) / &2) * b = 
   (&1 - c / &2) * (&4 - b) * b`]); 
 (PURE_REWRITE_TAC[ups_x]); 
 (PURE_REWRITE_TAC[REAL_ARITH 
   `(--(b + c - (b * c) / &2) * (b + c - (b * c) / &2) - b * b - c * c +
    &2 * (b + c - (b * c) / &2) * c +
    &2 * (b + c - (b * c) / &2) * b +
    &2 * b * c) -
    (b + c - (b * c) / &2) * b * c = 
   (((&4 - b) * b) * (&4 - c) * c) / &4`]);
 

(* ------------------------------------------------------------------------- *)
(*       SUBGOAL 4.                                                           *)
(*                                                                            *)
(* ------------------------------------------------------------------------- *)

 
 (SUBGOAL_THEN 
  `!r b. c IN r /\
     is_realinterval r /\
     b IN r /\
     (!y. y IN r ==> &0 < ((&4 - y) * y) * (&4 - c) * c)
     ==> --pi / &2 -
         atn
         (((&1 - b / &2) * (&4 - c) * c) /
          (&2 * sqrt ((((&4 - b) * b) * (&4 - c) * c) / &4))) -
         atn
         (((&1 - c / &2) * (&4 - b) * b) /
          (&2 * sqrt ((((&4 - b) * b) * (&4 - c) * c) / &4))) +
         &2 *
         atn
         ((&8 + (b * c) / &2 - &2 * b - &2 * c) /
          sqrt ((((&4 - b) * b) * (&4 - c) * c) / &4)) =
         &0`
 ASSUME_TAC);
 
 (REPEAT GEN_TAC  THEN STRIP_TAC);
 SWITCH_TAC; 
 (FIRST_X_ASSUM MP_TAC THEN SPEC_TAC (`b':real`, `x:real`) ); 
 (MATCH_MP_TAC HAS_REAL_DERIVATIVE_ZERO_CONSTANT2 THEN EXISTS_TAC `c:real`); 
 (ASM_REWRITE_TAC[]); 
 STRIP_TAC;  (* Break into 2 Subgoals *)
 
  (* The first one *)
  (ABBREV_TAC `C = (&4 - c) * c`);
  (ABBREV_TAC 
     `FUNCTION = (\x. --pi / &2 -
           atn
           (((&1 - x / &2) * C) / (&2 * sqrt ((((&4 - x) * x) * C) / &4))) -
           atn
           (((&1 - c / &2) * (&4 - x) * x) /
            (&2 * sqrt ((((&4 - x) * x) * C) / &4))) +
           &2 *
           atn
           ((&8 + (x * c) / &2 - &2 * x - &2 * c) /
            sqrt ((((&4 - x) * x) * C) / &4)))`);
  (ABBREV_TAC 
    `F1 = (\x. atn 
    (((&1 - x / &2) * C) / (&2 * sqrt ((((&4 - x) * x) * C) / &4))))`);
  (ABBREV_TAC 
    `F2 = (\x. atn
           (((&1 - c / &2) * (&4 - x) * x) / 
            (&2 * sqrt ((((&4 - x) * x) * C) / &4))))`);
  (ABBREV_TAC 
    `F3 = (\x. atn
           ((&8 + (x * c) / &2 - &2 * x - &2 * c) /
            sqrt ((((&4 - x) * x) * C) / &4)))`);

  (SUBGOAL_THEN 
    `FUNCTION = (\(x:real). --pi / &2 - F1 x - F2 x + &2 * F3 x)`
     ASSUME_TAC);
  (EXPAND_TAC "F1" THEN EXPAND_TAC "F2" THEN EXPAND_TAC "F3");
  (EXPAND_TAC "FUNCTION");
  (REWRITE_TAC[]);
 
 (GEN_TAC THEN DISCH_TAC);


(* ------------------------------------------------------------------------- *)
(*       SUBGOAL 4.                                                           *)
(*                                                                            *)
(* ------------------------------------------------------------------------- *)
 
 (ABBREV_TAC `D' = (((&4 - x) * x) * C) / &4`);
  (SUBGOAL_THEN `&0 < D'` ASSUME_TAC);
    (* Subgoal *) 
  (EXPAND_TAC "D'" THEN DEL_TAC);
  (MATCH_MP_TAC (REAL_ARITH `&0 < a ==> &0 < a / &4`));
   UP_ASM_TAC;
  (ASM_MESON_TAC[]);

(* --------------------------------------------------------------------------*)
(*         Derivativ of sqrt ((((&4 - x) * x) * C) / &4)                *)  
(* --------------------------------------------------------------------------*)
 
 (ABBREV_TAC `G = (\x.  sqrt ((((&4 - x) * x) * C) / &4))`); 
 (ABBREV_TAC `G' = 
  (((&4 - &2 * x) * C) / &4) * inv (&2 * sqrt ((((&4 - x) * x) * C) / &4))`);
  
  (SUBGOAL_THEN `(G has_real_derivative G') (atreal x within r)` ASSUME_TAC);
    (* Subgoal *)

  (ABBREV_TAC `f = (\x. (((&4 - x) * x) * C) / &4)`);

    (SUBGOAL_THEN `G = (\x:real. sqrt (f x))` ASSUME_TAC);
      (* Subgoal *)
    (EXPAND_TAC "f" THEN ASM_REWRITE_TAC[]);

  (ABBREV_TAC `g' = (\x. inv (&2 * sqrt x))`);
  (ABBREV_TAC `f' = ((&4 - &2 * x) * C)/ &4 `);
  (ABBREV_TAC `P = {x:real | &0 < x}`);

    (SUBGOAL_THEN 
     `!x. P x ==> (sqrt has_real_derivative (g':real->real) x) (atreal x)`
      ASSUME_TAC);
      (* Subgoal *)
    (EXPAND_TAC "g'" THEN REWRITE_TAC[BETA_THM]); 
    (EXPAND_TAC "P" THEN REWRITE_TAC[IN_ELIM_THM]);
    (REWRITE_TAC[HAS_REAL_DERIVATIVE_SQRT]);

    (SUBGOAL_THEN 
       `(f has_real_derivative f') (atreal x within r) /\ 
        (P:real->bool) (f x)` ASSUME_TAC);
      (* Subgoal *)

      CONJ_TAC;   
       (EXPAND_TAC "f" THEN EXPAND_TAC "f'");
       (REAL_DIFF_TAC THEN REAL_ARITH_TAC);
       (EXPAND_TAC "P" THEN REWRITE_TAC[IN_ELIM_THM]);
       (EXPAND_TAC "f");
       (ASM_REWRITE_TAC[]);

    (SUBGOAL_THEN `G' = f' * (g' ((f:real->real) x))` ASSUME_TAC);
      (* Subgoal *)
    (EXPAND_TAC "G'" THEN EXPAND_TAC "f'");
    (EXPAND_TAC "g'" THEN EXPAND_TAC "f" );
    (REWRITE_TAC[]);
    
  (ONCE_ASM_REWRITE_TAC[]);
  (DEL_TAC THEN UP_ASM_TAC THEN UP_ASM_TAC);
  (MP_TAC HAS_REAL_DERIVATIVE_CHAIN2 THEN MESON_TAC[]);

(* --------------------------------------------------------------------------*)
(*         Derivative of &2 * sqrt ((((&4 - x) * x) * C) / &4)           *)  
(* --------------------------------------------------------------------------*)
 
 (ABBREV_TAC `2G = (\x.  &2 * sqrt ((((&4 - x) * x) * C) / &4))`);
  (SUBGOAL_THEN 
    `(2G has_real_derivative &2 * G') (atreal x within r)` ASSUME_TAC);
  
    (SUBGOAL_THEN `2G = (\x:real. &2 * G x)` ASSUME_TAC);
    (EXPAND_TAC "2G" THEN EXPAND_TAC "G" THEN MESON_TAC[]); 
  
  (ONCE_ASM_REWRITE_TAC[]);
  (DEL_TAC THEN DEL_TAC );
  (FIRST_X_ASSUM MP_TAC);
  (MP_TAC HAS_REAL_DERIVATIVE_LMUL_WITHIN THEN MESON_TAC[]);

(* --------------------------------------------------------------------------*)
(*         Derivative of  ((&1 - x / &2) * C) /                          *)
(*            (&2 * sqrt ((((&4 - x) * x) * C) / &4))                    *)  
(* --------------------------------------------------------------------------*)
 
 (ABBREV_TAC `f1 = (\x. (&1 - x / &2) * C)`); 
 (ABBREV_TAC `F12 = 
  (\x. ((&1 - x / &2) * C) / (&2 * sqrt ((((&4 - x) * x) * C) / &4)))`);

  (SUBGOAL_THEN 
    `(F12 has_real_derivative
     ((-- &1 / &2 * C) * 2G x - f1 x * &2 * G') / 2G x pow 2)
     (atreal x within r)`
     ASSUME_TAC);

    (SUBGOAL_THEN `F12 = (\x:real.  f1 x / 2G x)` ASSUME_TAC);
      (* Subgoal *) 
    (EXPAND_TAC "F12" THEN EXPAND_TAC "2G" THEN EXPAND_TAC "f1");
    (REWRITE_TAC[]);

  (ASM_REWRITE_TAC[] THEN DEL_TAC);

    (SUBGOAL_THEN 
      `(f1 has_real_derivative (-- &1 / &2) * C) (atreal x within r) /\ 
       (2G has_real_derivative &2 * G') (atreal x within r) /\ ~(2G x = &0)`
       ASSUME_TAC);
      (*  Subgoal *)
    (ASM_REWRITE_TAC[]);    
     CONJ_TAC;  (* Break into 2 subgoals *)

      (EXPAND_TAC "f1" THEN REAL_DIFF_TAC THEN REAL_ARITH_TAC);
      (EXPAND_TAC "2G");
      (MATCH_MP_TAC (MESON[REAL_ENTIRE] 
         `~ (x = &0) /\ ~ (y = &0) ==> ~ (x * y = &0)`));
      (REWRITE_TAC[REAL_ARITH `~(&2 = &0)`]);
      (MATCH_MP_TAC (REAL_ARITH `&0 < a ==> ~ (a = &0)`));
      (MATCH_MP_TAC SQRT_POS_LT);
      (ASM_REWRITE_TAC[]);

   UP_ASM_TAC;
   (MP_TAC HAS_REAL_DERIVATIVE_DIV_WITHIN);
   (MESON_TAC[]);

(* --------------------------------------------------------------------------*)
(*         Derivative of  atn ((&1 - x / &2) * C) /                      *)
(*            (&2 * sqrt ((((&4 - x) * x) * C) / &4))                    *)  
(* --------------------------------------------------------------------------*)

  (SUBGOAL_THEN 
    `(F1 has_real_derivative
     ((-- &1 / &2 * C) * 2G x - f1 x * &2 * G') / 2G x pow 2 *
     inv (&1 + F12 x pow 2))
     (atreal x within r)`
     ASSUME_TAC);

    (SUBGOAL_THEN `F1 = (\x:real. atn (F12 x))` ASSUME_TAC);
      (* Subgoal *)
    (EXPAND_TAC "F1" THEN EXPAND_TAC "F12");
    (REWRITE_TAC[]); 

  (ONCE_ASM_REWRITE_TAC[]);
   DEL_TAC;
  (ABBREV_TAC `g' = (\x. inv (&1 + x pow 2))`);
  (ABBREV_TAC `f' = 
    ((-- &1 / &2 * C) * 2G (x:real) - f1 x * &2 * G') / 2G x pow 2`);

    (SUBGOAL_THEN 
      `inv (&1 + F12 x pow 2) = g' ((F12:real-> real) x)`
       ASSUME_TAC);
      (* Subgoal *)
    (EXPAND_TAC "F12" THEN EXPAND_TAC "g'");
    (REWRITE_TAC[]);
 
  (ONCE_ASM_REWRITE_TAC[]);

    (SUBGOAL_THEN 
     `!x. (:real) x ==> (atn has_real_derivative (g':real->real) x) (atreal x)`
      ASSUME_TAC);   
      (* Subgoal *)
    (EXPAND_TAC "g'");
    (REWRITE_TAC[EQ_UNIV; HAS_REAL_DERIVATIVE_ATN]);


    (SUBGOAL_THEN 
      `(F12 has_real_derivative f') (atreal x within r) /\ 
       (:real) (F12 x)` ASSUME_TAC);
      (* Subgoal *)
    (ASM_REWRITE_TAC[]);
    (MESON_TAC[EQ_UNIV;IN_UNIV; IN]);

  (REPLICATE_TAC 2 UP_ASM_TAC);
  (MP_TAC HAS_REAL_DERIVATIVE_CHAIN2);
  (MESON_TAC[]);

(* --------------------------------------------------------------------------*)
(*                                                                           *)
(*                                                                           *)  
(* --------------------------------------------------------------------------*)

  (ABBREV_TAC `X = (&4 - x) * x`);
  (SUBGOAL_THEN `~(X = &0)` ASSUME_TAC);
   STRIP_TAC;
    (SUBGOAL_THEN `D' = &0` ASSUME_TAC);
    (EXPAND_TAC "D'");
    (REWRITE_TAC[REAL_ARITH `(a * x)/ &4 = a * (x / &4)`]);
    (ONCE_ASM_REWRITE_TAC[]);
     REAL_ARITH_TAC;
  (MP_TAC (ASSUME `&0 < D'`));
  (FIRST_ASSUM MP_TAC THEN REAL_ARITH_TAC);

  (SUBGOAL_THEN `~(&4 - x = &0) /\ ~(x = &0)` ASSUME_TAC);
  (UP_ASM_TAC THEN EXPAND_TAC "X");
  (REWRITE_TAC[REAL_ENTIRE]);
  (MESON_TAC[]);

  (SUBGOAL_THEN 
    `inv (&1 + F12 (x:real) pow 2) = X / (X + C - X * C / &4)`
     ASSUME_TAC);
  (ONCE_REWRITE_TAC[GSYM REAL_INV_DIV]);
   AP_TERM_TAC;
  (REWRITE_TAC[REAL_ARITH `(a + b)/ c = a / c + b / c`]);
    
    (SUBGOAL_THEN `X / X = &1` ASSUME_TAC);
    (ASM_SIMP_TAC[REAL_DIV_REFL]);
 
  (ONCE_ASM_REWRITE_TAC[]); 
  (AP_TERM_TAC);
  (EXPAND_TAC "F12");
  (REWRITE_TAC[REAL_POW_DIV]);
  (REWRITE_TAC[REAL_POW_2]);
  (REWRITE_TAC[REAL_ARITH `(&2 * a) * &2 * a = &4 * a pow 2`]);
  (ONCE_ASM_REWRITE_TAC[]);

    (SUBGOAL_THEN `sqrt ((X * C) / &4) pow 2 = (X * C) / &4` ASSUME_TAC);
    (MATCH_MP_TAC SQRT_POW_2);
    (MATCH_MP_TAC (REAL_ARITH `&0 < x ==> &0 <= x`));
    (ASM_REWRITE_TAC[]);
 
  (ONCE_ASM_REWRITE_TAC[]);
  (REWRITE_TAC[REAL_ARITH `&4 * (X * C) / & 4 = X * C`]);
  (REWRITE_TAC[REAL_ARITH 
    `((&1 - x / &2) * C) * (&1 - x / &2) * C = 
     ((&1 - ((&4 - x) * x) / &4) * C) * C`]);
  (ONCE_ASM_REWRITE_TAC[]);

  (SUBGOAL_THEN `~(C = &0)` ASSUME_TAC);
   STRIP_TAC;
    (SUBGOAL_THEN `D' = &0` ASSUME_TAC);
    (EXPAND_TAC "D'");
    (REWRITE_TAC[REAL_ARITH `(a * x)/ &4 = (a / &4) * x`]);
    (ONCE_ASM_REWRITE_TAC[]);
     REAL_ARITH_TAC;
  (MP_TAC (ASSUME `&0 < D'`));
  (FIRST_ASSUM MP_TAC THEN REAL_ARITH_TAC);

    (SUBGOAL_THEN 
      `(((&1 - X / &4) * C) * C) / (X * C) = ((&1 - X / &4) * C) / X`
      ASSUME_TAC);
    (ONCE_REWRITE_TAC[REAL_ARITH `((a * b) * c) / d = (a * b) * c / d`]);
    (MATCH_MP_TAC REDUCE_WITH_DIV_Euler_lemma);
    (ASM_REWRITE_TAC[]);

  (ONCE_ASM_REWRITE_TAC[]);
  (AP_THM_TAC THEN AP_TERM_TAC);
   REAL_ARITH_TAC;

(* --------------------------------------------------------------------------*)
(*                                                                           *)
(*                                                                           *)  
(* --------------------------------------------------------------------------*)

(SUBGOAL_THEN `&2 * sqrt ((X * C) / &4) = sqrt (X * C)` ASSUME_TAC);
(MATCH_MP_TAC (REAL_ARITH 
    `(&2 * sqrt x = sqrt (&4) * sqrt x) /\ (sqrt (&4) * sqrt x = y)
      ==> &2 * sqrt x = y`));
(ASM_REWRITE_TAC[]);
 CONJ_TAC;

  (AP_THM_TAC THEN AP_TERM_TAC);
  (REWRITE_TAC[REAL_ARITH `&4 = &2 * &2`]);
  (SIMP_TAC[REAL_ARITH `&0 <= &2`; SQRT_MUL]);
  (SIMP_TAC[GSYM REAL_POW_2; GSYM SQRT_POW_2; REAL_ARITH `&0 <= &2`]);
  
  (PURE_ONCE_REWRITE_TAC[REAL_ARITH `X * C = &4 * (X * C) / &4`]);
  (ASM_REWRITE_TAC[]);
  (PURE_ONCE_REWRITE_TAC[REAL_ARITH `&4 * (a * b) / &4 = a * b`]);
  (MATCH_MP_TAC (GSYM SQRT_MUL));
  (REWRITE_TAC[REAL_ARITH `&0 <= &4`]);
  (MATCH_MP_TAC (REAL_ARITH `&0 < a ==> &0 <= a`));
  (ASM_REWRITE_TAC[]);

(* --------------------------------------------------------------------------*)
(*                                                                           *)
(* --------------------------------------------------------------------------*)

  (SUBGOAL_THEN `2G (x:real) = sqrt (X * C)` ASSUME_TAC);  
  (EXPAND_TAC "2G");
  (ONCE_ASM_REWRITE_TAC[]);
  (ASM_REWRITE_TAC[]);

  (SUBGOAL_THEN 
    `G' = ((&4 - &2 * x) * C) / &4 * inv (sqrt (X * C))` ASSUME_TAC);
  (EXPAND_TAC "G'");
  (REPEAT AP_TERM_TAC);
  (ASM_REWRITE_TAC[]);

  (SUBGOAL_THEN `&0 < X * C` ASSUME_TAC);
  (EXPAND_TAC "X" THEN ASM_MESON_TAC[]);

  (SUBGOAL_THEN 
    `(-- &1 / &2 * C) * 2G (x:real) - f1 x * &2 * G' = 
      -- &2 * C * C / sqrt (X * C)` ASSUME_TAC);
  (ONCE_ASM_REWRITE_TAC[]);
  (EXPAND_TAC "f1");
  (ONCE_REWRITE_TAC[REAL_ARITH 
    `a * &2 * b / &4 * c = (a * &2 * b / &4) * c`]);
  (ONCE_REWRITE_TAC[REAL_ARITH 
    `((&1 - x / &2) * C) * &2 * ((&4 - &2 * x) * C) / &4 = 
     (&4 - (&4 - x) * x) * C * C / &2`]);
  (ONCE_ASM_REWRITE_TAC[]);    

  (SUBGOAL_THEN 
    `(-- &1 / &2 * C) * sqrt (X * C) = (-- &1 / &2 * C * X * C) / sqrt (X * C)`
     ASSUME_TAC);
  (REWRITE_TAC[REAL_ARITH 
    `(-- &1 / &2 * C * X * C) / Y = (-- &1 / &2 * C) * (X * C) / Y `]);
   AP_TERM_TAC;


    (SUBGOAL_THEN 
      `sqrt (X * C) * sqrt (X * C) = (X * C) ==> 
       sqrt (X * C) = (X * C) / sqrt (X * C)` ASSUME_TAC);
    (MATCH_MP_TAC (MESON[] `(a <=> b) ==> (a ==> b)`));
    (MATCH_MP_TAC (GSYM REAL_EQ_RDIV_EQ));
    (MATCH_MP_TAC SQRT_POS_LT);
    (ASM_REWRITE_TAC[]);    

  (FIRST_X_ASSUM MATCH_MP_TAC); 
  (REWRITE_TAC[GSYM REAL_POW_2]);
  (MATCH_MP_TAC SQRT_POW_2);
  (MATCH_MP_TAC (REAL_ARITH `&0 < a ==> &0 <= a`));
  (ASM_REWRITE_TAC[]);

 (ASM_REWRITE_TAC[]);
 (REWRITE_TAC[REAL_ARITH `-- a *  b * c / x = -- (a * b * c) / x`]);
 (REWRITE_TAC[REAL_ARITH `a / x - y = -- b / x <=> (a + b) / x = y`]);
 (REWRITE_TAC[REAL_ARITH 
   `-- &1 / &2 * C * X * C + &2 * C * C = (&4 - X) * C * C / &2`]);
 (ABBREV_TAC `m = (&4 - X) * C * C / &2`);
 (ABBREV_TAC `n = sqrt (X * C)`);

    (SUBGOAL_THEN `m = (m * inv n) * n  ==> m / n = m * inv n` ASSUME_TAC);
    (MATCH_MP_TAC (MESON[] `(a <=> b) ==> (a ==> b)`));
    (MATCH_MP_TAC (GSYM REAL_EQ_LDIV_EQ));
    (EXPAND_TAC "n");
    (MATCH_MP_TAC SQRT_POS_LT);
    (ASM_REWRITE_TAC[]);    

  (FIRST_X_ASSUM MATCH_MP_TAC); 
  (REWRITE_TAC[REAL_ARITH `(m * inv n) * n = m * (inv n * n)`]);
  (MATCH_MP_TAC (MESON[REAL_MUL_RID] 
                  `inv n * n = &1 ==> m = m * inv n * n`));
  (MATCH_MP_TAC REAL_MUL_LINV);
  (MATCH_MP_TAC (REAL_ARITH `&0 < n ==> ~ (n = &0)`));
  (EXPAND_TAC "n");
  (MATCH_MP_TAC SQRT_POS_LT);
  (ASM_REWRITE_TAC[]);    

(* --------------------------------------------------------------------------*)
(*                                                                           *)
(*                                                                           *)  
(* --------------------------------------------------------------------------*)

(SUBGOAL_THEN 
 `(F1 has_real_derivative -- &2 * C / (X + C - X * C / &4) / sqrt (X * C)) 
  (atreal x within r)`
  ASSUME_TAC);

  (SUBGOAL_THEN `2G (x:real) pow 2 = X * C` ASSUME_TAC);
  (MATCH_MP_TAC (REAL_ARITH 
    `2G (x:real) pow 2 = &4 * D' /\ &4 * D' = X * C ==> 
     2G (x:real) pow 2 = X * C`));
  (ASM_REWRITE_TAC[REAL_ARITH `(&4 * z = x * y) <=> ((x * y) / &4 = z)`]);  
  (EXPAND_TAC "D'");  
  (REWRITE_TAC[REAL_ARITH `&4 * (X * C) / &4 = X * C`]);
  (MATCH_MP_TAC SQRT_POW_2);
  (MATCH_MP_TAC (REAL_ARITH `&0 < x ==> &0 <= x`));
  (ASM_REWRITE_TAC[]);

  (SUBGOAL_THEN 
    `((-- &1 / &2 * C) * 2G (x:real) - f1 x * &2 * G') / 2G x pow 2 *
     inv (&1 + F12 x pow 2) = 
     -- &2 * C / (X + C - X * C / &4) / sqrt (X * C)`
     ASSUME_TAC);
  (ASM_REWRITE_TAC[]);
  (ABBREV_TAC `m = X + C - X * C / &4`);
  (REWRITE_TAC[REAL_ARITH `-- &2 * C / m / n = (-- &2 * C) / m / n`]);  
  (REWRITE_TAC[REAL_ARITH 
    `(-- a * b * c / d) / e * f / g = (-- a * b * c * f) / e / g / d`]);
  (REPEAT (AP_THM_TAC THEN AP_TERM_TAC));
  (REWRITE_TAC[REAL_ARITH 
    `(-- a * b * c * d) / e = (-- a * b) * (d * c) / e`]);
  (MATCH_MP_TAC (MESON[REAL_MUL_RID] `x = &1 ==> (y * x = y)`));
  (MATCH_MP_TAC REAL_DIV_REFL);
  (MATCH_MP_TAC (REAL_ARITH `&0 < x ==> ~(x = &0)`));
  (ASM_REWRITE_TAC[]);  

(ASM_MESON_TAC[]);

(UP_ASM_TAC THEN DEL_TAC THEN UP_ASM_TAC THEN REPLICATE_TAC 4 DEL_TAC);
(REPLICATE_TAC 3 UP_ASM_TAC THEN REPLICATE_TAC 4 DEL_TAC);
(REPEAT DISCH_TAC);

(* --------------------------------------------------------------------------*)
(*                                                                           *)
(*                                                                           *)
(* --------------------------------------------------------------------------*)

(ABBREV_TAC `f2 = (\x. (&1 - c / &2) * (&4 - x) * x)`);
(ABBREV_TAC 
   `F22 = (\x. ((&1 - c / &2) * (&4 - x) * x) / 
          (&2 * sqrt ((((&4 - x) * x) * C) / &4)))`);

  (SUBGOAL_THEN 
    `(F22 has_real_derivative
     (((&1 - c / &2) * (&4 - &2 * x)) * 2G x - f2 x * &2 * G') / 2G x pow 2)
     (atreal x within r)`
     ASSUME_TAC);

    (SUBGOAL_THEN `F22 = (\x:real.  f2 x / 2G x)` ASSUME_TAC);
      (* Subgoal *) 
    (EXPAND_TAC "F22" THEN EXPAND_TAC "2G" THEN EXPAND_TAC "f2");
    (REWRITE_TAC[]);

  (ONCE_ASM_REWRITE_TAC[] THEN DEL_TAC);

    (SUBGOAL_THEN 
      `(f2 has_real_derivative (&1 - c / &2) * (&4 - &2 * x)) 
       (atreal x within r) /\ 
       (2G has_real_derivative &2 * G') (atreal x within r) /\ ~(2G x = &0)`
       ASSUME_TAC);
      (*  Subgoal *)
    (ASM_REWRITE_TAC[]);    
     CONJ_TAC;  (* Break into 2 subgoals *)

      (EXPAND_TAC "f2" THEN REAL_DIFF_TAC THEN REAL_ARITH_TAC);
      (MATCH_MP_TAC (REAL_ARITH `&0 < a ==> ~ (a = &0)`));
      (EXPAND_TAC "2G");
      (MATCH_MP_TAC (REAL_ARITH `&0 < &2 /\ &0 < x ==> &0 < &2 * x`));
      (REWRITE_TAC[REAL_ARITH `&0 < &2`]);
      (MATCH_MP_TAC SQRT_POS_LT);
      (MATCH_MP_TAC (REAL_ARITH `&0 < x  ==> &0 < x / &4`));
      (ASM_REWRITE_TAC[]);

   UP_ASM_TAC;
  (MP_TAC HAS_REAL_DERIVATIVE_DIV_WITHIN);
  (MESON_TAC[]);


(* --------------------------------------------------------------------------*)
(*         Derivative of  atn ((&1 - c / &2) * (&4 - x) * x) /               *)
(*            (&2 * sqrt ((((&4 - x) * x) * C) / &4))                        *)  
(* --------------------------------------------------------------------------*)

  (SUBGOAL_THEN 
    `(F2 has_real_derivative
     (((&1 - c / &2) * (&4 - &2 * x)) * 2G x - f2 x * &2 * G') / 2G x pow 2 *
     inv (&1 + F22 x pow 2))
     (atreal x within r)`
     ASSUME_TAC);

    (SUBGOAL_THEN `F2 = (\x:real. atn (F22 x))` ASSUME_TAC);
      (* Subgoal *)
    (EXPAND_TAC "F2" THEN EXPAND_TAC "F22");
    (REWRITE_TAC[]); 

  (ONCE_ASM_REWRITE_TAC[]);
   DEL_TAC;
  (ABBREV_TAC `g' = (\x. inv (&1 + x pow 2))`);
  (ABBREV_TAC `f' = 
    (((&1 - c / &2) * (&4 - &2 * x)) * 2G x - f2 x * &2 * G') / 2G x pow 2`);

    (SUBGOAL_THEN 
      `inv (&1 + F22 x pow 2) = g' ((F22:real-> real) x)`
       ASSUME_TAC);
      (* Subgoal *)
    (EXPAND_TAC "F22" THEN EXPAND_TAC "g'");
    (MESON_TAC[]);
 
  (ONCE_ASM_REWRITE_TAC[]);

    (SUBGOAL_THEN 
     `!x. (:real) x ==> (atn has_real_derivative (g':real->real) x) (atreal x)`
      ASSUME_TAC);   
      (* Subgoal *)
    (EXPAND_TAC "g'");
    (REWRITE_TAC[EQ_UNIV; HAS_REAL_DERIVATIVE_ATN]);


    (SUBGOAL_THEN 
      `(F22 has_real_derivative f') (atreal x within r) /\ 
       (:real) (F22 x)` ASSUME_TAC);
      (* Subgoal *)
    (ASM_REWRITE_TAC[]);
    (MESON_TAC[EQ_UNIV;IN_UNIV; IN]);

  (REPLICATE_TAC 2 UP_ASM_TAC);
  (MP_TAC HAS_REAL_DERIVATIVE_CHAIN2);
  (MESON_TAC[]);

(* --------------------------------------------------------------------------*)
(*                                                                           *)
(*                                                                           *)  
(* --------------------------------------------------------------------------*)

  (SUBGOAL_THEN 
    `inv (&1 + F22 (x:real) pow 2) = C / (X + C - X * C / &4)`
     ASSUME_TAC);
  (ONCE_REWRITE_TAC[GSYM REAL_INV_DIV]);
   AP_TERM_TAC;
  (REWRITE_TAC[REAL_ARITH `(a + b - d)/ c = b / c + (a - d) / c`]);

    (SUBGOAL_THEN `C / C = &1` ASSUME_TAC);
    (MATCH_MP_TAC REAL_DIV_REFL);
    (EXPAND_TAC "C");
    (REWRITE_TAC[REAL_ENTIRE; MESON[] `~ (a \/ b) <=> ~a /\ ~b`]);
    (ASM_REWRITE_TAC[REAL_ARITH `~ (&4 - x = &0) <=> ~(x = &4)`]);
 
  (ONCE_ASM_REWRITE_TAC[]); 
  (AP_TERM_TAC);
  (EXPAND_TAC "F22");
  (REWRITE_TAC[REAL_POW_DIV]);
  (REWRITE_TAC[REAL_POW_2]);
  (REWRITE_TAC[REAL_ARITH `(x * a) * x * a = x pow 2 * a pow 2`]);
  (ONCE_ASM_REWRITE_TAC[]);

    (SUBGOAL_THEN `sqrt ((X * C) / &4) pow 2 = (X * C) / &4` ASSUME_TAC);
    (MATCH_MP_TAC SQRT_POW_2);
    (MATCH_MP_TAC (REAL_ARITH `&0 < x ==> &0 <= x`));
    (ASM_REWRITE_TAC[]);
 
  (ONCE_ASM_REWRITE_TAC[]);
  (REWRITE_TAC[REAL_ARITH `&2 pow 2 * (X * C) / & 4 = X * C`]);

    (SUBGOAL_THEN 
      `((&1 - c / &2) pow 2 * X pow 2) / (X * C) = 
       ((&1 - C / &4) * X) * X / (C * X)` ASSUME_TAC);    
    (EXPAND_TAC "C");
    (REWRITE_TAC[REAL_ARITH 
                  `(&1 - c / &2) pow 2 = &1 - ((&4 - c) * c) / &4`]);
    (REWRITE_TAC[REAL_ARITH `a * b pow 2 = (a * b) * b`]);
    (ONCE_REWRITE_TAC[REAL_ARITH `((a * d) * b) / c = (a * d) * (b / c)`]);
    (REPEAT AP_TERM_TAC);
    (REWRITE_TAC[REAL_MUL_SYM]);

  (ONCE_ASM_REWRITE_TAC[]);   
  (REWRITE_TAC[REAL_ARITH `(a - a * b) / c = ((&1 - b) * a) / c`]);
  (MATCH_MP_TAC REDUCE_WITH_DIV_Euler_lemma);
  (ASM_REWRITE_TAC[]);
  (EXPAND_TAC "C");
  (REWRITE_TAC[REAL_ENTIRE; MESON[] `~ (a \/ b) <=> ~a /\ ~b`]);
  (ASM_REWRITE_TAC[REAL_ARITH `~ (&4 - x = &0) <=> ~(x = &4)`]);

(* --------------------------------------------------------------------------*)
(*                                                                           *)
(*                                                                           *)  
(* --------------------------------------------------------------------------*)

(SUBGOAL_THEN `&2 * sqrt ((X * C) / &4) = sqrt (X * C)` ASSUME_TAC);
(MATCH_MP_TAC (REAL_ARITH 
    `(&2 * sqrt x = sqrt (&4) * sqrt x) /\ (sqrt (&4) * sqrt x = y)
      ==> &2 * sqrt x = y`));
(ASM_REWRITE_TAC[]);
 CONJ_TAC;

  (AP_THM_TAC THEN AP_TERM_TAC);
  (REWRITE_TAC[REAL_ARITH `&4 = &2 * &2`]);
  (SIMP_TAC[REAL_ARITH `&0 <= &2`; SQRT_MUL]);
  (SIMP_TAC[GSYM REAL_POW_2; GSYM SQRT_POW_2; REAL_ARITH `&0 <= &2`]);
  
  (PURE_ONCE_REWRITE_TAC[REAL_ARITH `X * C = &4 * (X * C) / &4`]);
  (ASM_REWRITE_TAC[]);
  (PURE_ONCE_REWRITE_TAC[REAL_ARITH `&4 * (a * b) / &4 = a * b`]);
  (MATCH_MP_TAC (GSYM SQRT_MUL));
  (REWRITE_TAC[REAL_ARITH `&0 <= &4`]);
  (MATCH_MP_TAC (REAL_ARITH `&0 < a ==> &0 <= a`));
  (ASM_REWRITE_TAC[]);

(* --------------------------------------------------------------------------*)
(*                                                                           *)
(* --------------------------------------------------------------------------*)

  (SUBGOAL_THEN `2G (x:real) = sqrt (X * C)` ASSUME_TAC);  
  (EXPAND_TAC "2G");
  (ONCE_ASM_REWRITE_TAC[]);
  (ASM_REWRITE_TAC[]);

  (SUBGOAL_THEN 
    `G' = ((&4 - &2 * x) * C) / &4 * inv (sqrt (X * C))` ASSUME_TAC);
  (EXPAND_TAC "G'");
  (REPEAT AP_TERM_TAC);
  (ASM_REWRITE_TAC[]);

  (SUBGOAL_THEN 
    `((&1 - c / &2) * (&4 - &2 * x)) * 2G x - f2 x * &2 * G' = 
     ((&1 - c / &2) * (&4 - &2 * x)) * (X * C) / &2 / sqrt (X * C)`
      ASSUME_TAC);

  (ONCE_ASM_REWRITE_TAC[]);
  (EXPAND_TAC "f2");
  (ONCE_REWRITE_TAC[REAL_ARITH 
    `(a * b) * &2 * (c * d) / &4 * e = (a * c) * (b * d * e) / &2`]);
  (ABBREV_TAC `m = (&1 - c / &2) * (&4 - &2 * x)`);
  (ONCE_REWRITE_TAC[REAL_ARITH `m * x - m * y = m * (x - y)`]);
   AP_TERM_TAC;
  (ONCE_ASM_REWRITE_TAC[]);    

  (SUBGOAL_THEN `sqrt (X * C) = (X * C) / sqrt (X * C)` ASSUME_TAC);
    (SUBGOAL_THEN 
      `sqrt (X * C) * sqrt (X * C) = (X * C) ==> 
       sqrt (X * C) = (X * C) / sqrt (X * C)` ASSUME_TAC);
    (MATCH_MP_TAC (MESON[] `(a <=> b) ==> (a ==> b)`));
    (MATCH_MP_TAC (GSYM REAL_EQ_RDIV_EQ));
    (MATCH_MP_TAC SQRT_POS_LT);
    (ASM_REWRITE_TAC[]);    

  (FIRST_X_ASSUM MATCH_MP_TAC); 
  (REWRITE_TAC[GSYM REAL_POW_2]);
  (MATCH_MP_TAC SQRT_POW_2);
  (MATCH_MP_TAC (REAL_ARITH `&0 < a ==> &0 <= a`));
  (ASM_REWRITE_TAC[]);

 (ABBREV_TAC `n = (X * C) / &2 / sqrt (X * C)`);
 (ABBREV_TAC `n' = inv (sqrt (X * C))`);
 (PURE_ONCE_ASM_REWRITE_TAC[]);
 (EXPAND_TAC "n" THEN EXPAND_TAC "n'");
 (REWRITE_TAC[REAL_ARITH `a / x - y = a / &2 / x <=> a / & 2 / x = y`]);
 (REWRITE_TAC[REAL_ARITH `(a *  b * c) / x = (a * b) / x  * c`]);
 (ABBREV_TAC `t = (X * C) / &2`);
 (ABBREV_TAC `r' = sqrt (X * C)`);

    (SUBGOAL_THEN `t = (t * inv r') * r'  ==> t / r' = t * inv r'`
       ASSUME_TAC);
    (MATCH_MP_TAC (MESON[] `(a <=> b) ==> (a ==> b)`));
    (MATCH_MP_TAC (GSYM REAL_EQ_LDIV_EQ));
    (EXPAND_TAC "r'");
    (MATCH_MP_TAC SQRT_POS_LT);
    (ASM_REWRITE_TAC[]);

  (FIRST_X_ASSUM MATCH_MP_TAC); 
  (REWRITE_TAC[REAL_ARITH `(m * inv n) * n = m * (inv n * n)`]);
  (MATCH_MP_TAC (MESON[REAL_MUL_RID] 
                  `inv r' * r' = &1 ==> m = m * inv r' * r'`));
  (MATCH_MP_TAC REAL_MUL_LINV);
  (MATCH_MP_TAC (REAL_ARITH `&0 < n ==> ~ (n = &0)`));
  (EXPAND_TAC "r'");
  (MATCH_MP_TAC SQRT_POS_LT);
  (ASM_REWRITE_TAC[]);


(* --------------------------------------------------------------------------*)
(*                                                                           *)
(*                                                                           *)  
(* --------------------------------------------------------------------------*)

(SUBGOAL_THEN 
  `(F2 has_real_derivative
   ((&2 - c) * (&2 - x)) * C / &2 / (X + C - X * C / &4) / sqrt (X * C))
   (atreal x within r)`
   ASSUME_TAC);

  (SUBGOAL_THEN `2G (x:real) pow 2 = X * C` ASSUME_TAC);
  (MATCH_MP_TAC (REAL_ARITH 
    `2G (x:real) pow 2 = &4 * D' /\ &4 * D' = X * C ==> 
     2G (x:real) pow 2 = X * C`));
  (ASM_REWRITE_TAC[REAL_ARITH `(&4 * z = x * y) <=> ((x * y) / &4 = z)`]);  
  (EXPAND_TAC "D'");  
  (REWRITE_TAC[REAL_ARITH `&4 * (X * C) / &4 = X * C`]);
  (MATCH_MP_TAC SQRT_POW_2);
  (MATCH_MP_TAC (REAL_ARITH `&0 < x ==> &0 <= x`));
  (ASM_REWRITE_TAC[]);

  (SUBGOAL_THEN 
    `(((&1 - c / &2) * (&4 - &2 * x)) * 2G x - f2 x * &2 * G') / 2G x pow 2 *
       inv (&1 + F22 x pow 2) = 
     ((&2 - c) * (&2 - x)) * C / &2 / (X + C - X * C / &4) / sqrt (X * C)`
     ASSUME_TAC);
  (ASM_REWRITE_TAC[]);
  (ABBREV_TAC `m = X + C - X * C / &4`);
  (REWRITE_TAC[REAL_ARITH 
    `(a * b / c / d) / e * f / g = (a * f * (b / e)) / c / g / d`]);  
  (REWRITE_TAC[REAL_ARITH 
    `(a * b / c / d / e)= (a * b) / c / d / e`]);  

  (REPEAT(AP_THM_TAC THEN AP_TERM_TAC));
  (REWRITE_TAC[REAL_ARITH 
    `((&1 - c / &2) * (&4 - &2 * x)) = ((&2 - c) * (&2 - x))`]);
   AP_TERM_TAC;
  (MATCH_MP_TAC (MESON[REAL_MUL_RID] `x = &1 ==> (y * x = y)`));
  (MATCH_MP_TAC REAL_DIV_REFL);
  (MATCH_MP_TAC (REAL_ARITH `&0 < x ==> ~(x = &0)`));
  (ASM_REWRITE_TAC[]);  

(ASM_MESON_TAC[]);
(UP_ASM_TAC THEN REPLICATE_TAC 9 DEL_TAC);
(REPEAT DISCH_TAC);

(* Begin Diff 3 *)

(ABBREV_TAC `f3 = (\x. (&8 + (x * c) / &2 - &2 * x - &2 * c))`);
(ABBREV_TAC 
   `F32 = (\x.(&8 + (x * c) / &2 - &2 * x - &2 * c) /
            sqrt ((((&4 - x) * x) * C) / &4))`);

  (SUBGOAL_THEN 
    `(F32 has_real_derivative
     ((c / &2 - &2) * G x - f3 x * G') / G x pow 2) (atreal x within r)`
     ASSUME_TAC);

    (SUBGOAL_THEN `F32 = (\x:real.  f3 x / G x)` ASSUME_TAC);
      (* Subgoal *) 
    (EXPAND_TAC "F32" THEN EXPAND_TAC "G" THEN EXPAND_TAC "f3");
    (REWRITE_TAC[]);

  (ONCE_ASM_REWRITE_TAC[] THEN DEL_TAC);

    (SUBGOAL_THEN 
      `(f3 has_real_derivative (c / &2 - &2)) 
       (atreal x within r) /\ 
       (G has_real_derivative G') (atreal x within r) /\ ~(G x = &0)`
       ASSUME_TAC);
      (*  Subgoal *)
    (ASM_REWRITE_TAC[]);    
     CONJ_TAC;  (* Break into 2 subgoals *)

      (EXPAND_TAC "f3" THEN REAL_DIFF_TAC THEN REAL_ARITH_TAC);
      (MATCH_MP_TAC (REAL_ARITH `&0 < a ==> ~ (a = &0)`));
      (EXPAND_TAC "G");
      (MATCH_MP_TAC SQRT_POS_LT);
      (ASM_REWRITE_TAC[]);

   UP_ASM_TAC;
  (MP_TAC HAS_REAL_DERIVATIVE_DIV_WITHIN);
  (MESON_TAC[]);


(* --------------------------------------------------------------------------*)
(*         Derivative of  atn (....)                                         *)  
(* --------------------------------------------------------------------------*)

  (SUBGOAL_THEN 
    `(F3 has_real_derivative
     ((c / &2 - &2) * G x - f3 x * G') / G x pow 2 * inv (&1 + F32 x pow 2))
     (atreal x within r)`
     ASSUME_TAC);

    (SUBGOAL_THEN `F3 = (\x:real. atn (F32 x))` ASSUME_TAC);
      (* Subgoal *)
    (EXPAND_TAC "F3" THEN EXPAND_TAC "F32");
    (REWRITE_TAC[]); 

  (ONCE_ASM_REWRITE_TAC[]);
   DEL_TAC;
  (ABBREV_TAC `g' = (\x. inv (&1 + x pow 2))`);
  (ABBREV_TAC `f' = ((c / &2 - &2) * G (x:real) - f3 x * G') / G x pow 2`);

    (SUBGOAL_THEN 
      `inv (&1 + F32 x pow 2) = g' ((F32:real-> real) x)`
       ASSUME_TAC);
      (* Subgoal *)
    (EXPAND_TAC "F32" THEN EXPAND_TAC "g'");
    (MESON_TAC[]);
 
  (ONCE_ASM_REWRITE_TAC[]);

    (SUBGOAL_THEN 
     `!x. (:real) x ==> (atn has_real_derivative (g':real->real) x) (atreal x)`
      ASSUME_TAC);   
      (* Subgoal *)
    (EXPAND_TAC "g'");
    (REWRITE_TAC[EQ_UNIV; HAS_REAL_DERIVATIVE_ATN]);

    (SUBGOAL_THEN 
      `(F32 has_real_derivative f') (atreal x within r) /\ 
       (:real) (F32 x)` ASSUME_TAC);
      (* Subgoal *)
    (ASM_REWRITE_TAC[]);
    (MESON_TAC[EQ_UNIV;IN_UNIV; IN]);

  (REPLICATE_TAC 2 UP_ASM_TAC);
  (MP_TAC HAS_REAL_DERIVATIVE_CHAIN2);
  (MESON_TAC[]);

(* --------------------------------------------------------------------------*)
(*                                                                           *)
(*                                                                           *)  
(* --------------------------------------------------------------------------*)

  (SUBGOAL_THEN 
    `inv (&1 + F32 (x:real) pow 2) = (x * c) / (x * c + (&4 - x) * (&4 - c))`
     ASSUME_TAC);
  (ONCE_REWRITE_TAC[GSYM REAL_INV_DIV]);
   AP_TERM_TAC;
  (REWRITE_TAC[REAL_ARITH `(a + b) / c = a / c + b / c`]);

    (SUBGOAL_THEN `(x * c) / (x * c) = &1` ASSUME_TAC);
    (MATCH_MP_TAC REAL_DIV_REFL);
    (REWRITE_TAC[REAL_ENTIRE; MESON[] `~ (a \/ b) <=> ~a /\ ~b`]);
    (ASM_REWRITE_TAC[]);
 
  (ONCE_ASM_REWRITE_TAC[]); 
  (AP_TERM_TAC);
  (EXPAND_TAC "F32");
  (REWRITE_TAC[REAL_POW_DIV]);
  (ONCE_ASM_REWRITE_TAC[]);

    (SUBGOAL_THEN `sqrt ((X * C) / &4) pow 2 = (X * C) / &4` ASSUME_TAC);
    (MATCH_MP_TAC SQRT_POW_2);
    (MATCH_MP_TAC (REAL_ARITH `&0 < x ==> &0 <= x`));
    (ASM_REWRITE_TAC[]);
  (ONCE_ASM_REWRITE_TAC[]);
  (REWRITE_TAC[REAL_ARITH `(x * a) * x * a = x pow 2 * a pow 2`]);
  (REWRITE_TAC[REAL_ARITH 
     `&8 + (x * c) / &2 - &2 * x - &2 * c = ((&4 - x) * (&4 - c)) / &2`]);
  (REWRITE_TAC[REAL_POW_DIV]);
  (REWRITE_TAC[REAL_ARITH `&2 pow 2 = &4`]);
  (ABBREV_TAC `m = ((&4 - x) * (&4 - c)) pow 2 / &4`);
  (ABBREV_TAC `n = ((X * C) / &4)`);
  (ABBREV_TAC `p = ((&4 - x) * (&4 - c)) / (x * c)`);

    (SUBGOAL_THEN `m = p * n ==> (m / n = p)` ASSUME_TAC); 
    (MATCH_MP_TAC (MESON[] `(b <=> a) ==> (a ==> b)`));
    (MATCH_MP_TAC REAL_EQ_LDIV_EQ);
    (EXPAND_TAC "n");    
    (ASM_REWRITE_TAC[]);

  (FIRST_X_ASSUM MATCH_MP_TAC);
  (EXPAND_TAC "m" THEN EXPAND_TAC "n" THEN EXPAND_TAC "p");
  (REWRITE_TAC[REAL_ARITH `(a / x) * (b / y) = (a * b) / x / y`]);
  (AP_THM_TAC THEN AP_TERM_TAC);
  (REWRITE_TAC[REAL_ARITH `(a * b * c) / x = a * (b * c) / x`]);
  (REWRITE_TAC[REAL_POW_2]);
   AP_TERM_TAC;
  (EXPAND_TAC "X" THEN EXPAND_TAC "C");
  (REWRITE_TAC[REAL_ARITH `((a * b) * c * d) / e = (a * c) * (b * d) / e`]);
  (MATCH_MP_TAC (MESON[REAL_MUL_RID] `y = &1 ==> x = x * y`));
  (MATCH_MP_TAC REAL_DIV_REFL);
  (REWRITE_TAC[REAL_ENTIRE; MESON[] `~ (a \/ b) <=> ~a /\ ~b`]);
  (ASM_REWRITE_TAC[]);

(* --------------------------------------------------------------------------*)
(*                                                                           *)
(*                                                                           *)  
(* --------------------------------------------------------------------------*)


  (SUBGOAL_THEN `G (x:real) = sqrt ((X * C) / &4)` ASSUME_TAC);  
  (EXPAND_TAC "G");
  (ONCE_ASM_REWRITE_TAC[]);
  (ASM_REWRITE_TAC[]);

  (SUBGOAL_THEN 
    `G' = ((&4 - &2 * x) * C) / &4 * inv (sqrt (X * C))` ASSUME_TAC);
  (EXPAND_TAC "G'");
  (REPEAT AP_TERM_TAC);
  (MATCH_MP_TAC (REAL_ARITH 
    `(&2 * sqrt x = sqrt (&4) * sqrt x) /\ (sqrt (&4) * sqrt x = y)
      ==> &2 * sqrt x = y`));
  (ASM_REWRITE_TAC[]);
   CONJ_TAC;

  (AP_THM_TAC THEN AP_TERM_TAC);
  (REWRITE_TAC[REAL_ARITH `&4 = &2 * &2`]);
  (SIMP_TAC[REAL_ARITH `&0 <= &2`; SQRT_MUL]);
  (SIMP_TAC[GSYM REAL_POW_2; GSYM SQRT_POW_2; REAL_ARITH `&0 <= &2`]);
  
  (PURE_ONCE_REWRITE_TAC[REAL_ARITH `X * C = &4 * (X * C) / &4`]);
  (ASM_REWRITE_TAC[]);
  (PURE_ONCE_REWRITE_TAC[REAL_ARITH `&4 * (a * b) / &4 = a * b`]);
  (MATCH_MP_TAC (GSYM SQRT_MUL));
  (REWRITE_TAC[REAL_ARITH `&0 <= &4`]);
  (MATCH_MP_TAC (REAL_ARITH `&0 < x ==> &0 <= x`));
  (ASM_REWRITE_TAC[]);

  (SUBGOAL_THEN 
    `(c / &2 - &2) * G x - f3 x * G' = 
     (--C * ((&4 - x) * (&4 - c))) / &2 / sqrt (X * C)` ASSUME_TAC);

  (ONCE_ASM_REWRITE_TAC[]);
  (EXPAND_TAC "f3");

  (SUBGOAL_THEN `sqrt ((X * C) / &4) = sqrt (X * C) / &2` ASSUME_TAC);
    (SUBGOAL_THEN `&2 = sqrt (&4) ` ASSUME_TAC); 
    (MATCH_MP_TAC (REAL_ARITH 
      `(&2) = sqrt (&2) * sqrt (&2) /\ sqrt (&2) * sqrt (&2) = sqrt (&4) ==> 
       &2 = sqrt (&4)`));
     CONJ_TAC;
      (REWRITE_TAC[GSYM REAL_POW_2]);
      (MATCH_MP_TAC (GSYM SQRT_POW_2));
       REAL_ARITH_TAC;

      (REWRITE_TAC[REAL_ARITH `&4 = &2 * &2`]);
      (MESON_TAC[SQRT_MUL; REAL_ARITH `&0 <= &2`]);
  (ONCE_ASM_REWRITE_TAC[]);
  (EXPAND_TAC "D'");
  (MATCH_MP_TAC SQRT_DIV);
  (REWRITE_TAC[REAL_ARITH `&0 <= &4`]);
  (MATCH_MP_TAC (REAL_ARITH `&0 < x ==> &0 <= x`));
  (ASM_REWRITE_TAC[]);

(ONCE_ASM_REWRITE_TAC[]);
(REWRITE_TAC[REAL_ARITH 
  `(c / &2 - &2) * x / &2 = --(&4 - c) / &4 * x`]);
(REWRITE_TAC[REAL_ARITH 
  `(&8 + (x * c) / &2 - &2 * x - &2 * c) * s / &4 * r = 
   ((&4 - x) * (&4 - c)) * s / &8 * r`]);

  (SUBGOAL_THEN `--(&4 - c) / &4 * sqrt (X * C) =     
    (--(&4 - c) / &4 * (X * C)) / sqrt (X * C)` ASSUME_TAC);

  (REWRITE_TAC[REAL_ARITH 
    `(--(&4 - c) / &4 * X * C) / Y = (--(&4 - c) / &4) * (X * C) / Y `]);
   AP_TERM_TAC;

    (SUBGOAL_THEN 
      `sqrt (X * C) * sqrt (X * C) = (X * C) ==> 
       sqrt (X * C) = (X * C) / sqrt (X * C)` ASSUME_TAC);
    (MATCH_MP_TAC (MESON[] `(a <=> b) ==> (a ==> b)`));
    (MATCH_MP_TAC (GSYM REAL_EQ_RDIV_EQ));
    (MATCH_MP_TAC SQRT_POS_LT);
    (ASM_REWRITE_TAC[]);    

  (FIRST_X_ASSUM MATCH_MP_TAC); 
  (REWRITE_TAC[GSYM REAL_POW_2]);
  (MATCH_MP_TAC SQRT_POW_2);
  (MATCH_MP_TAC (REAL_ARITH `&0 < x ==> &0 <= x`));
  (ASM_REWRITE_TAC[]);
 
 (PURE_ONCE_ASM_REWRITE_TAC[]);
 (REWRITE_TAC[REAL_ARITH `a / x - y = b / x <=> (a - b) / x = y`]);
 (EXPAND_TAC "X" THEN EXPAND_TAC "C");
 (REWRITE_TAC[REAL_ARITH 
   `((&4 - x) * (&4 - c)) *
    ((&4 - &2 * x) * (&4 - c) * c) / &8 * N = (((&4 - x) * (&4 - c)) *
    ((&4 - &2 * x) * (&4 - c) * c) / &8) * N `]);
(ABBREV_TAC 
  `m = ((&4 - x) * (&4 - c)) * ((&4 - &2 * x) * (&4 - c) * c) / &8`);
(ASM_REWRITE_TAC[]);
(ABBREV_TAC `n = sqrt (X * C)`);
 
  (SUBGOAL_THEN 
    `(--(&4 - c) / &4 * X * C - (--C * (&4 - x) * (&4 - c)) / &2) = m`
    ASSUME_TAC);
  (EXPAND_TAC "X" THEN EXPAND_TAC "C" THEN EXPAND_TAC "m");
   REAL_ARITH_TAC;    
  
(ONCE_ASM_REWRITE_TAC[]);

  (SUBGOAL_THEN `m = (m * inv n) * n  ==> m / n = m * inv n` ASSUME_TAC);
  (MATCH_MP_TAC (MESON[] `(a <=> b) ==> (a ==> b)`));
  (MATCH_MP_TAC (GSYM REAL_EQ_LDIV_EQ));
  (EXPAND_TAC "n");
  (MATCH_MP_TAC SQRT_POS_LT);
  (ASM_REWRITE_TAC[]);    

  (FIRST_X_ASSUM MATCH_MP_TAC); 
  (REWRITE_TAC[REAL_ARITH `(m * inv n) * n = m * (inv n * n)`]);
  (MATCH_MP_TAC (MESON[REAL_MUL_RID] 
                  `inv r' * r' = &1 ==> m = m * inv r' * r'`));
  (MATCH_MP_TAC REAL_MUL_LINV);
  (MATCH_MP_TAC (REAL_ARITH `&0 < n ==> ~ (n = &0)`));
  (EXPAND_TAC "n");
  (MATCH_MP_TAC SQRT_POS_LT);
   ASM_REAL_ARITH_TAC;    
  (ASM_REWRITE_TAC[]);    

(* --------------------------------------------------------------------------*)
(*                                                                           *)
(*                                                                           *)  
(* --------------------------------------------------------------------------*)


(ABBREV_TAC `F12 = 
  (\x. ((&1 - x / &2) * C) / (&2 * sqrt ((((&4 - x) * x) * C) / &4)))`);

    (SUBGOAL_THEN `sqrt ((X * C) / &4) pow 2 = (X * C) / &4` ASSUME_TAC);
    (MATCH_MP_TAC SQRT_POW_2);
    (MATCH_MP_TAC (REAL_ARITH `&0 < x ==> &0 <= x`));
    (ASM_REWRITE_TAC[]);

  (SUBGOAL_THEN 
    `X + C - X * C / &4 = (&1 + F12 (x:real) pow 2 ) * X` ASSUME_TAC);

  (EXPAND_TAC "X" THEN EXPAND_TAC "C" THEN EXPAND_TAC "F12");
  (ONCE_ASM_REWRITE_TAC[]);
  (ONCE_REWRITE_TAC[REAL_POW_DIV]);
  (ONCE_REWRITE_TAC[REAL_POW_2]);
  (ONCE_REWRITE_TAC[REAL_ARITH `(&2 * a) * &2 * a = &4 * a pow 2`]);
  (ONCE_ASM_REWRITE_TAC[]);
  (ONCE_REWRITE_TAC[REAL_ARITH `&4 * x / &4 = x`]);
  (ONCE_REWRITE_TAC[REAL_ARITH 
    `((&1 - x / &2) * C) * (&1 - x / &2) * C = 
     (&1 - ((&4 - x) * x) / &4) * C * C`]);
  (ONCE_ASM_REWRITE_TAC[]);
  
    (SUBGOAL_THEN `&1 = (X * C) / (X * C)` ASSUME_TAC); 
    (REWRITE_TAC[EQ_SYM_EQ]);
    (MATCH_MP_TAC REAL_DIV_REFL);
    (MATCH_MP_TAC (REAL_ARITH `&0 < x ==> ~ (x = &0)`));
    (ASM_REWRITE_TAC[]);    

  (ONCE_REWRITE_TAC[REAL_ARITH `(&1 - x) * y = y - x * y`]);
  (ONCE_ASM_REWRITE_TAC[]);
  (ONCE_REWRITE_TAC[REAL_ARITH `a / x + b / x = (a + b) / x`]);
  (ONCE_REWRITE_TAC[REAL_ARITH 
    `X * C + C * C - X / &4 * C * C = (X + C - X * C / &4) * C`]);
  (ONCE_REWRITE_TAC[REAL_ARITH `(a * b) / c * d = a * (d * b) / c`]);
  (MATCH_MP_TAC (MESON[REAL_MUL_RID] `x = &1 ==> (a = a * x)`));
  (MATCH_MP_TAC REAL_DIV_REFL);
  (MATCH_MP_TAC (REAL_ARITH `&0 < x ==> ~ (x = &0)`));
  (ASM_REWRITE_TAC[]);    

  (SUBGOAL_THEN `~ (X + C - X * C / &4 = &0)` ASSUME_TAC);
  (ONCE_ASM_REWRITE_TAC[]);
  (REWRITE_TAC[REAL_ENTIRE; MESON[] `~(a \/ b) <=> ~ a /\ ~ b`]);
  (ASM_REWRITE_TAC[]);
  (MATCH_MP_TAC (REAL_ARITH `&0 < x ==> ~ (x = &0)`));
  (MATCH_MP_TAC (REAL_ARITH `&0 <= x ==> &0 < &1 + x`));
  (REWRITE_TAC[REAL_LE_POW_2]);

  (UP_ASM_TAC THEN DEL_TAC THEN DEL_TAC THEN DEL_TAC THEN REPEAT DISCH_TAC);    

(* --------------------------------------------------------------------------*)
(*                                                                           *)
(*                                                                           *)  
(* --------------------------------------------------------------------------*)


(SUBGOAL_THEN 
  `(F3 has_real_derivative
   (-- &2 * C * (&2 * x + &2 * c - x * c)) / &8 / (X + C - X * C / &4) /
    sqrt (X * C)) (atreal x within r)`
   ASSUME_TAC);

  (SUBGOAL_THEN `G (x:real) pow 2 = (X * C) / &4` ASSUME_TAC);
  (EXPAND_TAC "G");  
  (ASM_REWRITE_TAC[]);
  (MATCH_MP_TAC SQRT_POW_2);
  (MATCH_MP_TAC (REAL_ARITH `&0 < x ==> &0 <= x`));
  (ASM_REWRITE_TAC[]);    

  (SUBGOAL_THEN 
    `((c / &2 - &2) * G x - f3 x * G') / G x pow 2 * inv (&1 + F32 x pow 2) =
     (-- &2 * C * (&2 * x + &2 * c - x * c)) / &8 / (X + C - X * C / &4) /
     sqrt (X * C)` ASSUME_TAC);
  (ONCE_ASM_REWRITE_TAC[] THEN DEL_TAC);
  (REWRITE_TAC[REAL_ARITH 
    `(a / b / c / d) * f / g = (a * f) / b / d / g / c `]);  
  (REPEAT(AP_THM_TAC THEN AP_TERM_TAC));

  (ABBREV_TAC 
    `x1 = (x * c + (&4 - x) * (&4 - c))`);
  (ABBREV_TAC 
    `x2 = &2 * x + &2 * c - x * c`);

  (SUBGOAL_THEN 
    `X + C - X * C / &4 = x1 * x2 / &8` ASSUME_TAC);
  (EXPAND_TAC "X" THEN EXPAND_TAC "C" THEN EXPAND_TAC "x1" THEN EXPAND_TAC "x2");
  (REAL_ARITH_TAC);

(ONCE_ASM_REWRITE_TAC[]);
(REWRITE_TAC[REAL_ARITH `(--x * a * b) * c * d = --x * (a * c) * (b * d)`]);
(ASM_REWRITE_TAC[]);

(SUBGOAL_THEN `~ (x1 = &0) /\ ~ (x2 = &0)` ASSUME_TAC);
(REPEAT STRIP_TAC);
  
  (SUBGOAL_THEN `X + C - X * C / &4 = &0` ASSUME_TAC);
  (MATCH_MP_TAC 
  (MESON[REAL_MUL_LZERO] `(x = x1 * x2 / &8) /\ (x1 = &0) ==> (x = &0)`));
  (ASM_REWRITE_TAC[]);  
  (MP_TAC (ASSUME `~(X + C - X * C / &4 = &0)`));
  (FIRST_X_ASSUM MP_TAC THEN REAL_ARITH_TAC);

  (SUBGOAL_THEN `X + C - X * C / &4 = &0` ASSUME_TAC);
  (MATCH_MP_TAC 
    (MESON[REAL_MUL_RZERO; REAL_ARITH `&0 / x = &0`] 
    `(x = x1 * x2 / &8) /\ (x2 = &0) ==> (x = &0)`));
  (ASM_REWRITE_TAC[]);  
  (MP_TAC (ASSUME `~(X + C - X * C / &4 = &0)`));
  (FIRST_X_ASSUM MP_TAC THEN REAL_ARITH_TAC);

(REWRITE_TAC[EQ_SYM_EQ]);
(REWRITE_TAC[REAL_ARITH `(-- &2 * C * x2) / &8 / (x1 * x2 / &8) =
                           (-- &2 * C) * (x2 / &8) / (x1 * x2 / &8)`]);
(SUBGOAL_THEN 
  `(-- &2 * C) * x2 / &8 / (x1 * x2 / &8) = (-- &2 * C) / x1 ` ASSUME_TAC);
(MATCH_MP_TAC REDUCE_WITH_DIV_Euler_lemma);
(ASM_REWRITE_TAC[]);
(MATCH_MP_TAC (REAL_ARITH `~(x = &0) ==> ~(x / &8 = &0)`));
(ASM_REWRITE_TAC[]);
(ASM_REWRITE_TAC[]);
(EXPAND_TAC "D'");
(AP_THM_TAC THEN AP_TERM_TAC);
(REWRITE_TAC[REAL_ARITH `x / &2  = (x * &2) / &4 `]);
(PURE_ONCE_REWRITE_TAC[REAL_ARITH `a / (b / &4) = a / (&1 * b / &4) `]);
(PURE_ONCE_REWRITE_TAC[REAL_ARITH `((--C * X * C) * &2) / &4 = 
                                     (-- &2 * C) * (X * C) / &4 `]);
(PURE_REWRITE_TAC[EQ_SYM_EQ]);
(PURE_REWRITE_TAC[REAL_ARITH `(a * b / c) / d = a * (b/ c/ d)`]);
(PURE_ONCE_REWRITE_TAC[REAL_ARITH `a = b <=> a = b / &1`]);
(MATCH_MP_TAC REDUCE_WITH_DIV_Euler_lemma);
(REWRITE_TAC[REAL_ARITH `~(&1 = &0)`]);
(MATCH_MP_TAC (REAL_ARITH `&0 < x  ==> ~ (x / &4 = &0)`));
(ASM_REWRITE_TAC[]);

(ASM_MESON_TAC[]);
(UP_ASM_TAC THEN UP_ASM_TAC THEN REPLICATE_TAC 8 DEL_TAC THEN REPEAT DISCH_TAC);


(ABBREV_TAC `F1' = -- &2 * C / (X + C - X * C / &4) / sqrt (X * C)`);
(ABBREV_TAC `F2' = 
  ((&2 - c) * (&2 - x)) * C / &2 / (X + C - X * C / &4) / sqrt (X * C)`);

(ABBREV_TAC `F3' = 
   (-- &2 * C * (&2 * x + &2 * c - x * c)) / &8 /
   (X + C - X * C / &4) / sqrt (X * C)`);


(SUBGOAL_THEN `&0 - (F1' + F2') + &2 * F3' = &0` ASSUME_TAC);
(REWRITE_TAC[REAL_ARITH `&0 - (a + b) + c = &0 <=> a + b - c = &0`]);
(EXPAND_TAC "F1'" THEN EXPAND_TAC "F2'" THEN EXPAND_TAC "F3'");
(ONCE_REWRITE_TAC[REAL_ARITH `--a / x + b / x - &2 * c / x = (--a + b - &2 * c) / x`]);


(ABBREV_TAC `m = sqrt (X * C)`);
(ABBREV_TAC `n = X + C - X * C / &4`);
(REWRITE_TAC[REAL_ARITH `-- &2 * x / a  + y * z / a - &2 * t / a = 
(-- &2 * x + y * z - &2 * t) / a `]);

(SUBGOAL_THEN `(-- &2 * C +
  ((&2 - c) * (&2 - x)) * C / &2 -
  &2 * (-- &2 * C * (&2 * x + &2 * c - x * c)) / &8) = &0 ` ASSUME_TAC);
(EXPAND_TAC "C");
 REAL_ARITH_TAC;
(ASM_REWRITE_TAC[]);

(SUBGOAL_THEN `&0 / n = &0 ` ASSUME_TAC);
(MATCH_MP_TAC (REAL_ARITH `~(x = &0) ==> &0 / x = &0`));
(ASM_REWRITE_TAC[]);

(ASM_REWRITE_TAC[]); 
 (MATCH_MP_TAC (REAL_ARITH `~(x = &0) ==> &0 / x = &0`)); 
 (EXPAND_TAC "m"); 
 (MATCH_MP_TAC (REAL_ARITH `&0 < a ==> ~(a = &0)`)); 
 (MATCH_MP_TAC SQRT_POS_LT); 
 (ASM_REWRITE_TAC[]);
 
 (ABBREV_TAC `FUN1 = (\x:real. --pi / &2 - F1 x - F2 x)`); 
 (ABBREV_TAC `FUN2 = (\x:real. F1 x + F2 x)`);
 
 (SUBGOAL_THEN `(FUN2 has_real_derivative F1' + F2') (atreal x within r)` ASSUME_TAC); 
 (EXPAND_TAC "FUN2"); 
 (ASM_SIMP_TAC[HAS_REAL_DERIVATIVE_ADD]);
 
 (SUBGOAL_THEN `(FUN1 has_real_derivative &0 - (F1' + F2')) (atreal x within r)` ASSUME_TAC);
    (SUBGOAL_THEN `FUN1 = (\x:real. --pi / &2 - FUN2 x)` ASSUME_TAC);
    (EXPAND_TAC "FUN1" THEN EXPAND_TAC "FUN2");
    (REWRITE_TAC[REAL_ARITH `a - (b + c) = a - b - c`]);
 
 (ASM_REWRITE_TAC[]);
 
 (SUBGOAL_THEN `((\x:real. --pi / &2) has_real_derivative &0 ) 
                 (atreal x within r)` ASSUME_TAC);
(REAL_DIFF_TAC); 
 (MESON_TAC[]);
 
 (UP_ASM_TAC THEN DEL_TAC THEN UP_ASM_TAC); 
 (MP_TAC HAS_REAL_DERIVATIVE_SUB THEN MESON_TAC[]);
 
 (ABBREV_TAC `FUN3 = (\x:real. &2 * F3 x)`); 
 (SUBGOAL_THEN `(FUN3 has_real_derivative &2 * F3') (atreal x within r)` ASSUME_TAC); 
 (EXPAND_TAC "FUN3"); 
 (MP_TAC (ASSUME `(F3 has_real_derivative F3') (atreal x within r)`));  
 (MP_TAC HAS_REAL_DERIVATIVE_LMUL_WITHIN THEN MESON_TAC[]);

 
 (SUBGOAL_THEN `(FUNCTION has_real_derivative &0 - (F1' + F2') + &2 * F3') (atreal x within r)` ASSUME_TAC);

    (SUBGOAL_THEN `(\x. --pi / &2 - F1 x - F2 x + &2 * F3 x) = (\x:real. FUN1 x + FUN3 x)` ASSUME_TAC);
    (EXPAND_TAC "FUN1" THEN EXPAND_TAC "FUN3");
    (MESON_TAC[]);

    (ASM_REWRITE_TAC[]); 
 (ASM_MESON_TAC[HAS_REAL_DERIVATIVE_ADD]); 
 (ASM_MESON_TAC[]);

(* ========================================================================= *)
 
 (SUBGOAL_THEN `&0 < (&4 - c) * c` ASSUME_TAC); 
 (MATCH_MP_TAC REAL_LT_MUL);
 ASM_REAL_ARITH_TAC;
 
 (SUBGOAL_THEN `sqrt ((((&4 - c) * c) * (&4 - c) * c) / &4) = 
                 ((&4 - c) * c) / &2` ASSUME_TAC); 
 (ONCE_REWRITE_TAC[EQ_SYM_EQ]); 
 (MATCH_MP_TAC SQRT_RULE_Euler_lemma);
 ASM_REAL_ARITH_TAC;
 
 (ASM_REWRITE_TAC[REAL_ARITH `&2 * x / &2 = x`]); 
 (REWRITE_TAC[REAL_ARITH 
 `&8 + (c * c) / &2 - &2 * c - &2 * c = (&4 - c) * ((&4 - c) / &2)`]); 
 (REWRITE_TAC[REAL_ARITH `((&4 - c) * c) / &2 = c * ((&4 - c) / &2)`]); 
 (REWRITE_TAC[REAL_ARITH `(a * b) / (c * d) = a * b / (c * d)`]);
 
 (SUBGOAL_THEN `(&4 - c) * (&4 - c) / &2 / (c * (&4 - c) / &2) = (&4 - c) / c` ASSUME_TAC);
 
 (MATCH_MP_TAC REDUCE_WITH_DIV_Euler_lemma); 
 (ASM_REWRITE_TAC[]);
 ASM_REAL_ARITH_TAC;
 
 (ONCE_ASM_REWRITE_TAC[]);
 
 (SUBGOAL_THEN `(&1 - c / &2) * (&4 - c) * c / ((&4 - c) * c) = (&1 - c / &2)` ASSUME_TAC); 
 (REWRITE_TAC[REAL_ARITH `a * b * c / d = a * (b * c) / d`]); 
 (MATCH_MP_TAC (MESON[REAL_MUL_RID] `x = &1 ==> a * x = a`)); 
 (MATCH_MP_TAC REAL_DIV_REFL); 
 (REWRITE_TAC[REAL_ENTIRE; MESON[] `~ (a \/ b) <=>  ~a /\ ~b`]);
 ASM_REAL_ARITH_TAC;
 
 (ASM_REWRITE_TAC[REAL_ARITH `a - b - b = a - &2 * b`]);
 
 (ABBREV_TAC `P = {x| &0 < x /\ x < &4}`);
 
 (SUBGOAL_THEN `is_realinterval P` ASSUME_TAC); 
 (EXPAND_TAC "P"); 
 (MP_TAC REAL_INTERVAL_Euler_lemma); 
 (REPEAT LET_TAC); 
 (UP_ASM_TAC THEN MESON_TAC[]);
 
 (SUBGOAL_THEN `&2 IN P` ASSUME_TAC); 
 (EXPAND_TAC "P"); 
 (REWRITE_TAC [IN_ELIM_THM]);
 REAL_ARITH_TAC;
 
 (SUBGOAL_THEN `!x. x IN P ==> ~(x = &0) /\ ~(&4 - x = &0)` ASSUME_TAC); 
 (GEN_TAC THEN EXPAND_TAC "P"); 
 (REWRITE_TAC [IN_ELIM_THM]);
 REAL_ARITH_TAC;
 
 (SUBGOAL_THEN `(c:real) IN P` ASSUME_TAC); 
 (EXPAND_TAC "P"); 
 (ASM_REWRITE_TAC [IN_ELIM_THM]);
 
 (REPLICATE_TAC 4 UP_ASM_TAC); 
 (MP_TAC DERIVATIVE_WRT_C1_Euler_lemma); 
 (MESON_TAC[DERIVATIVE_WRT_C1_Euler_lemma]);
 
 (ABBREV_TAC `R = {x:real| &0 < x /\ x < &4}`);
 
 (SUBGOAL_THEN `(c:real) IN R` ASSUME_TAC); 
 (EXPAND_TAC"R" THEN ASM_REWRITE_TAC[IN_ELIM_THM]); 
 (SUBGOAL_THEN `is_realinterval R` ASSUME_TAC); 
 (EXPAND_TAC"R" THEN REWRITE_TAC[is_realinterval]); 
 (REWRITE_TAC[IN_ELIM_THM]); 
 (REPEAT STRIP_TAC);
  (MATCH_MP_TAC (REAL_ARITH `&0 < a' /\ a' <= c ==> &0 < c`));
  (ASM_REWRITE_TAC[]);
  (MATCH_MP_TAC (REAL_ARITH `c' <= b' /\ b' < &4 ==> c' < &4`));
  (ASM_REWRITE_TAC[]);
 
 (SUBGOAL_THEN `!y. y IN R ==> &0 < ((&4 - y) * y) * (&4 - c) * c` ASSUME_TAC);
 
 (GEN_TAC THEN EXPAND_TAC "R" THEN REWRITE_TAC[IN_ELIM_THM]);
 STRIP_TAC; 
 (MATCH_MP_TAC REAL_LT_MUL);
  STRIP_TAC; 
 (MATCH_MP_TAC REAL_LT_MUL);
 ASM_REAL_ARITH_TAC; 
 (MATCH_MP_TAC REAL_LT_MUL); 
ASM_REAL_ARITH_TAC;
 
 (SUBGOAL_THEN `(b:real) IN R` ASSUME_TAC); 
 (EXPAND_TAC"R" THEN ASM_REWRITE_TAC[IN_ELIM_THM]);
 
 (REPLICATE_TAC 4 UP_ASM_TAC THEN DEL_TAC THEN UP_ASM_TAC); 
 (MESON_TAC[]);

 
 (EXPAND_TAC "d"); 
 (FIRST_X_ASSUM MATCH_MP_TAC); 
 (EXPAND_TAC "s" THEN ASM_REWRITE_TAC[IN_ELIM_THM])
]);;  
  
