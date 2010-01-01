(* Tran Nam Trung *)


(* Changes to make compatible with Multivariate/flyspeck.ml *)
needs "Multivariate/flyspeck.ml";;

let REAL_INJ = REAL_OF_NUM_EQ;;
let REAL_ADD' = REAL_OF_NUM_ADD;;  (* prime added to REAL_ADD throughout file *)
let REAL_MUL' = REAL_OF_NUM_MUL;;  (* prime added to REAL_MUL throughout file *)

prioritize_num();;

parse_as_infix("POWER",(24,"right"));;

parse_as_infix("inside",(11,"right"));;

parse_as_infix("iso",(24,"right"));;
 
(* The definition of the nth exponent of a map *)


let POWER = new_recursive_definition num_RECURSION 
  `(!(f:A->A). f POWER 0  = I) /\  
   (!(f:A->A) (n:num). f POWER (SUC n) = (f POWER n) o f)`;;

let POWER_0 = prove(`!f:A->A. f POWER 0 = I`,
   REWRITE_TAC[POWER]);;

let POWER_1 = prove(`!f:A->A. f POWER 1 = f`,
   REWRITE_TAC[POWER; ONE; I_O_ID]);;

let POWER_2 = prove(`!f:A->A. f POWER 2 = f o f`,
   REWRITE_TAC[POWER; TWO; POWER_1]);;

let orbit_map = new_definition `orbit_map (f:A->A)  (x:A) = {(f POWER n) x | n >= 0}`;;

let lemma_two_series_eq = prove(`!p:num->A q:num->A n:num. (!i:num. i <= n ==> p i = q i) ==> {p (i:num) | i <= n} = {q (i:num) | i <= n}`,
    REPEAT STRIP_TAC THEN SET_TAC[]);;

let lemma_add_one_assumption = prove(`!P. !(n:num). (!i:num. i <= SUC n ==> P i) <=> (!i:num. i <= n ==> P i) /\ P (SUC n)`,
   REPEAT GEN_TAC
   THEN EQ_TAC
   THENL[STRIP_TAC
      THEN STRIP_TAC
      THENL[REPEAT STRIP_TAC
	 THEN FIRST_X_ASSUM (MP_TAC o SPEC `i:num`)
	 THEN POP_ASSUM (fun th -> REWRITE_TAC[MATCH_MP (ARITH_RULE `i:num <= n:num ==> i <= SUC n`) th]); ALL_TAC]
      THEN POP_ASSUM (MP_TAC o REWRITE_RULE[LE_REFL] o SPEC `SUC n`)
      THEN SIMP_TAC[]; ALL_TAC]
   THEN STRIP_TAC
   THEN REPEAT STRIP_TAC
   THEN ASM_CASES_TAC `i:num = SUC n`
   THENL[POP_ASSUM SUBST1_TAC
       THEN ASM_REWRITE_TAC[]; ALL_TAC]
   THEN REPLICATE_TAC 2 (POP_ASSUM MP_TAC)
   THEN REWRITE_TAC[IMP_IMP; GSYM LT_LE; LT_SUC_LE]
   THEN DISCH_TAC
   THEN FIRST_X_ASSUM (MP_TAC o SPEC `i:num` o  check (is_forall o concl))
   THEN ASM_REWRITE_TAC[]);;

(* the definition of hypermap *)

let exist_hypermap = prove(`?H:((A->bool)#(A->A)#(A->A)#(A->A)). FINITE (FST H) /\ (FST(SND H)) permutes (FST H) /\ (FST(SND(SND H))) permutes (FST H) /\ (SND(SND(SND H))) permutes (FST H) /\ (FST(SND H)) o (FST(SND(SND  H))) o (SND(SND(SND H))) = I`,EXISTS_TAC
`({},I,I,I):(A->bool)#(A->A)#(A->A)#(A->A)` THEN REWRITE_TAC[FINITE_RULES; PERMUTES_I; I_O_ID]);;

let hypermap_tybij = (new_type_definition "hypermap" ("hypermap", "tuple_hypermap")exist_hypermap);;

let dart = new_definition `dart (H:(A)hypermap) = FST (tuple_hypermap H)`;;

let edge_map = new_definition `edge_map (H:(A)hypermap) = FST(SND(tuple_hypermap H))`;;

let node_map = new_definition `node_map (H:(A)hypermap) = FST(SND(SND(tuple_hypermap H)))`;;

let face_map = new_definition `face_map (H:(A)hypermap) = SND(SND(SND(tuple_hypermap H)))`;;

let hypermap_lemma = prove(`!H:(A)hypermap. FINITE (dart H) /\ edge_map H
   permutes dart H /\ node_map H permutes dart H /\ face_map H permutes dart
   H /\ edge_map H o node_map H o face_map H = I`,

   ASM_REWRITE_TAC[hypermap_tybij;dart;edge_map; node_map; face_map]);;

(* some technical lemmas *)

let edge_map_and_darts = prove(`!(H:(A)hypermap). FINITE (dart H) /\ edge_map H permutes (dart H)`,
    REWRITE_TAC[hypermap_lemma]);;

let node_map_and_darts = prove(`!(H:(A)hypermap). FINITE (dart H) /\ node_map H permutes (dart H)`,
    REWRITE_TAC[hypermap_lemma]);;

let face_map_and_darts = prove(`!(H:(A)hypermap). FINITE (dart H) /\ face_map H permutes (dart H)`,
    REWRITE_TAC[hypermap_lemma]);;

(* edges, nodes and faces of a hypermap *)

let edge = new_definition `edge (H:(A)hypermap) (x:A) = orbit_map (edge_map H) x`;;

let node = new_definition `node (H:(A)hypermap) (x:A) = orbit_map (node_map H) x`;;

let face = new_definition `face (H:(A)hypermap) (x:A) = orbit_map (face_map H) x`;;


(* We define the combinatorial component *)

let go_one_step = new_definition `go_one_step (H:(A)hypermap) (x:A) (y:A) <=> (y = (edge_map H) x) \/ (y = (node_map H) x) \/ (y = (face_map H) x)`;;

let is_path = new_recursive_definition num_RECURSION  `(is_path (H:(A)hypermap) (p:num->A) 0 <=> T)/\
(is_path (H:(A)hypermap) (p:num->A) (SUC n) <=> ((is_path H p n) /\ go_one_step H (p n) (p (SUC n))))`;; 

let is_in_component = new_definition `is_in_component (H:(A)hypermap) (x:A) (y:A) <=> ?p:num->A n:num. p 0 = x /\ p n = y /\ is_path H p n`;;

let comb_component = new_definition `comb_component (H:(A)hypermap) (x:A) = {y:A| is_in_component H x y}`;;


(* some definitions on orbits *)

let set_of_orbits = new_definition `set_of_orbits (D:A->bool) (f:A->A) = {orbit_map f x | x IN D}`;;

let number_of_orbits = new_definition `number_of_orbits (D:A->bool) (f:A->A) = CARD(set_of_orbits D f)`;;


(* the orbits on hypermaps*)

let edge_set = new_definition `edge_set (H:(A)hypermap) = set_of_orbits (dart H) (edge_map H)`;;

let node_set = new_definition `node_set  (H:(A)hypermap) = set_of_orbits (dart H) (node_map H)`;;

let face_set = new_definition `face_set (H:(A)hypermap) = set_of_orbits (dart H) (face_map H)`;;


let set_components = new_definition `set_components (H:(A)hypermap) (D:A->bool) = {comb_component H (x:A) | x IN D}`;;

let set_part_components = new_definition `set_part_components (H:(A)hypermap) (D:A->bool) = {(comb_component H (x:A)) | x IN D}`;;

let set_of_components = new_definition `set_of_components (H:(A)hypermap) = set_part_components H (dart H)`;;


(* counting the numbers of edges, nodes, faces and combinatorial components *)

let number_of_edges = new_definition `number_of_edges (H:(A)hypermap) = CARD (edge_set H)`;;

let number_of_nodes = new_definition `number_of_nodes (H:(A)hypermap) = CARD (node_set H)`;;

let number_of_faces = new_definition `number_of_faces (H:(A)hypermap) = CARD (face_set H)`;;

let number_of_components = new_definition `number_of_components (H:(A)hypermap) = CARD (set_of_components H)`;;

(* some special kinds of hypergraphs *)

let plain_hypermap = new_definition `plain_hypermap (H:(A)hypermap) <=> edge_map H o edge_map H = I`;;

let planar_hypermap = new_definition `planar_hypermap (H:(A)hypermap) <=>
    number_of_nodes H + number_of_edges H + number_of_faces H 
    = (CARD (dart H)) + 2 * number_of_components H`;;

let simple_hypermap = new_definition `simple_hypermap (H:(A)hypermap) <=>
    (!x:A. x IN dart H ==> (node H x) INTER (face H x) = {x})`;;


(* a dart x is degenerate or nondegenerate *)

let dart_degenerate = new_definition `dart_degenerate (H:(A)hypermap) (x:A)  
   <=> (edge_map H x = x \/ node_map H x = x \/ face_map H x = x)`;;

let dart_nondegenerate = new_definition `dart_nondegenerate (H:(A)hypermap) (x:A) 
   <=> ~(edge_map H x = x) /\ ~(node_map H x = x) /\ ~(face_map H x = x)`;;

(* some relationships of maps and orbits of maps *)

let LEFT_MULT_MAP = prove(`!u:A->A v:A->A w:A->A. v = w  ==> u o v = u o w`, MESON_TAC[]);;

let RIGHT_MULT_MAP = prove(`!u:A->A v:A->A w:A->A. u = v ==> u o w = v o w`, MESON_TAC[]);;

let LEFT_INVERSE_EQUATION = prove(`!s:A->bool u:A->A v:A->A w:A->A. u permutes s /\ u o v = w ==> v = inverse u o w`,
   REPEAT STRIP_TAC THEN 
   SUBGOAL_THEN `inverse (u:A->A) o u o (v:A->A) = inverse u o (w:A->A)` MP_TAC
   THENL[ ASM_MESON_TAC[]; REWRITE_TAC[o_ASSOC] 
	 THEN ASM_MESON_TAC[PERMUTES_INVERSES_o; I_O_ID]]);;

let RIGHT_INVERSE_EQUATION = prove(`!s:A->bool u:A->A v:A->A w:A->A. v permutes s /\ u o v = w ==> u = w o inverse v`,
   REPEAT STRIP_TAC 
   THEN SUBGOAL_THEN `(u:A->A) o (v:A->A) o inverse v = (w:A->A) o inverse v` MP_TAC
   THENL [ASM_MESON_TAC[o_ASSOC]; ASM_MESON_TAC[PERMUTES_INVERSES_o;I_O_ID]]);;

let iterate_orbit = prove(`!(s:A->bool) (u:A->A). u permutes s ==> !(n:num) (x:A). x IN s ==> (u POWER n) x IN s`,
   REPEAT GEN_TAC THEN DISCH_THEN(ASSUME_TAC o MATCH_MP PERMUTES_IN_IMAGE)
   THEN INDUCT_TAC
   THENL[GEN_TAC THEN REWRITE_TAC[POWER; I_THM]; REPEAT GEN_TAC
      THEN REWRITE_TAC[POWER; o_DEF] THEN ASM_MESON_TAC[]]);;

let orbit_subset = prove(`!(s:A->bool) (u:A->A). u permutes s ==> !(x:A). x IN s ==> (orbit_map u x) SUBSET s`,
   REPEAT STRIP_TAC THEN REWRITE_TAC[SUBSET; orbit_map; IN_ELIM_THM] 
   THEN ASM_MESON_TAC[iterate_orbit]);;

let COM_POWER = prove(`!(n:num) (f:A->A). f POWER (SUC n) = f o (f POWER n)`,
   INDUCT_TAC 
   THENL[ REWRITE_TAC [ONE; POWER;I_O_ID];
      REPEAT STRIP_TAC THEN POP_ASSUM(ASSUME_TAC o GSYM o (ISPEC `f:A->A`))
      THEN ASM_REWRITE_TAC[POWER; o_ASSOC]]);;

let addition_exponents = prove(`!m n (f:A->A). f POWER (m + n) = (f POWER m) o (f POWER n)`,
   INDUCT_TAC 
   THENL [STRIP_TAC THEN REWRITE_TAC[ADD; POWER; I_O_ID]; 
      POP_ASSUM(ASSUME_TAC o GSYM o (ISPECL[`n:num`;`f:A->A`]))
      THEN REWRITE_TAC[COM_POWER; GSYM o_ASSOC]
      THEN ASM_REWRITE_TAC[COM_POWER; GSYM o_ASSOC; ADD]]);;

let multiplication_exponents = prove(`!m n (f:A->A). f POWER (m * n) = (f POWER n) POWER m`, 
   INDUCT_TAC 
   THENL [STRIP_TAC THEN REWRITE_TAC[MULT; POWER; I_O_ID]; ALL_TAC] 
   THEN REPEAT GEN_TAC THEN POP_ASSUM(ASSUME_TAC o (SPECL[`n:num`; `f:A->A`]))
   THEN ASM_REWRITE_TAC[MULT; addition_exponents; POWER]);;

let power_unit_map = prove(`!n f:A->A. f POWER n = I ==> !m. f POWER (m * n) = I`,
   REPLICATE_TAC 3 STRIP_TAC THEN INDUCT_TAC THENL[REWRITE_TAC[MULT; POWER]; 
    REWRITE_TAC[MULT; addition_exponents] THEN ASM_REWRITE_TAC[I_O_ID]]);;

let power_map_fix_point = prove(`!n f:A->A x:A. (f POWER n) x = x ==> !m. (f POWER (m * n)) x = x`,
    REPEAT GEN_TAC THEN STRIP_TAC THEN INDUCT_TAC 
    THENL [REWRITE_TAC[MULT; POWER; I_THM]; 
    REWRITE_TAC[MULT; addition_exponents; o_DEF] THEN ASM_REWRITE_TAC[]]);;

let in_orbit_lemma = prove(`!f:A->A n:num x:A y:A. y = (f POWER n) x ==> y IN orbit_map f x`,
   REPEAT STRIP_TAC THEN REWRITE_TAC[orbit_map;IN_ELIM_THM] 
   THEN EXISTS_TAC `n:num` 
   THEN ASM_REWRITE_TAC[ARITH_RULE `n:num >= 0`]);;

let lemma_in_orbit = prove(`!f:A->A n:num x:A. (f POWER n) x IN orbit_map f x`,
   REPEAT STRIP_TAC
   THEN REWRITE_TAC[orbit_map;IN_ELIM_THM]
   THEN EXISTS_TAC `n:num` THEN REWRITE_TAC[LE_0; GE]);;

let orbit_one_point = prove(`!f:A->A x:A. f x = x <=> orbit_map f x = {x}`,
  REPEAT GEN_TAC THEN EQ_TAC
  THENL[STRIP_TAC THEN REWRITE_TAC[EXTENSION;IN_SING] THEN GEN_TAC
    THEN REWRITE_TAC[orbit_map; IN_ELIM_THM]
    THEN EQ_TAC
    THENL[STRIP_TAC THEN MP_TAC(SPECL[`1`; `f:A->A`; `x:A`] power_map_fix_point)
       THEN ASM_REWRITE_TAC[POWER_1;MULT_CLAUSES]
       THEN DISCH_THEN (ASSUME_TAC o SPEC `n:num`)
       THEN ASM_REWRITE_TAC[]; ALL_TAC]
    THEN STRIP_TAC THEN EXISTS_TAC `0` THEN ASM_REWRITE_TAC [ARITH_RULE `0 >= 0`; POWER; I_THM]; ALL_TAC]
  THEN STRIP_TAC THEN MP_TAC (SPECL[`f:A->A`; `1`; `(x:A)`; `(f:A->A) (x:A)`] in_orbit_lemma)
  THEN ASM_REWRITE_TAC[POWER_1; IN_SING]);;

let lemma_orbit_finite = prove(`!(s:A->bool) (p:A->A) (x:A). FINITE s /\ p permutes s ==> FINITE (orbit_map p x)`,
   REPEAT STRIP_TAC THEN ASM_CASES_TAC `x:A IN s:A->bool`
   THENL[REPEAT STRIP_TAC 
       THEN UNDISCH_THEN `(p:A->A) permutes (s:A->bool)` (MP_TAC o SPEC `x:A` o MATCH_MP orbit_subset)
       THEN ASM_MESON_TAC[FINITE_SUBSET]; ALL_TAC]
   THEN SUBGOAL_THEN `(p:A->A) x:A = x:A` MP_TAC
   THENL[ASM_MESON_TAC[permutes]; ALL_TAC]
   THEN ONCE_REWRITE_TAC[orbit_one_point] THEN DISCH_THEN SUBST1_TAC THEN ASSUME_TAC (CONJUNCT1 CARD_CLAUSES)
   THEN ASSUME_TAC (CONJUNCT1 FINITE_RULES) THEN MP_TAC(SPECL[`x:A`;`{}:A->bool`] (CONJUNCT2 FINITE_RULES))
   THEN ASM_REWRITE_TAC[NOT_IN_EMPTY] THEN ARITH_TAC);;

let orbit_cyclic = prove(`!(f:A->A) m:num (x:A). ~(m = 0) /\ (f POWER m) x = x ==> orbit_map f x = {(f POWER k) x | k < m}`, 
   REPEAT STRIP_TAC THEN REWRITE_TAC[orbit_map; EXTENSION; IN_ELIM_THM] 
   THEN GEN_TAC THEN EQ_TAC 
   THENL [STRIP_TAC THEN ASM_REWRITE_TAC[] 
      THEN FIND_ASSUM (MP_TAC o (SPEC `n:num`) o MATCH_MP DIVMOD_EXIST) `~(m:num = 0)` 
     THEN REPEAT STRIP_TAC 
     THEN UNDISCH_THEN `((f:A->A) POWER (m:num)) (x:A) = x` (ASSUME_TAC o (SPEC `q:num`) o MATCH_MP power_map_fix_point) 
     THEN ASM_REWRITE_TAC[ADD_SYM; addition_exponents; o_DEF] 
     THEN EXISTS_TAC `r:num` THEN ASM_SIMP_TAC[]; REPEAT STRIP_TAC THEN ASM_REWRITE_TAC[] 
     THEN EXISTS_TAC `k:num` THEN SIMP_TAC[ARITH_RULE `k:num >= 0`]]);; 




(* Some obviuos facts about common hypermap maps *)

let power_permutation = prove(`!(s:A->bool) (p:A->A). p permutes s  ==> !(n:num). (p POWER n) permutes s`, 
   REPLICATE_TAC 3 STRIP_TAC THEN INDUCT_TAC 
   THENL[REWRITE_TAC[POWER; PERMUTES_I]; REWRITE_TAC[POWER] THEN ASM_MESON_TAC[PERMUTES_COMPOSE]]);;

let inverse_function = prove( `!s:A->bool p:A->A x:A y:A. p permutes s /\ p x = y ==> x = (inverse p) y`,
   REPEAT STRIP_TAC THEN POP_ASSUM (MP_TAC o AP_TERM `inverse (p:A->A)`) THEN STRIP_TAC 
   THEN MP_TAC (ISPECL[`inverse(p:A->A)`; `p:A->A`; `x:A`] o_THM) 
   THEN POP_ASSUM (SUBST1_TAC o SYM) THEN POP_ASSUM (ASSUME_TAC o CONJUNCT2 o MATCH_MP PERMUTES_INVERSES_o) 
   THEN POP_ASSUM SUBST1_TAC THEN REWRITE_TAC[I_THM]);;

let lemma_4functions = prove(`!f g h r. f o g o h o r = f o (g o h) o r `, REPEAT STRIP_TAC THEN REWRITE_TAC[GSYM o_ASSOC]);;

let lemma_power_inverse_map = prove(`!s:A->bool p:A->A n:num. p permutes s ==>  
   ((inverse p) POWER n) o (p POWER n) = I /\ (p POWER n) o ((inverse p) POWER n) = I`,
   REPEAT GEN_TAC
   THEN DISCH_THEN (LABEL_TAC "F1")
   THEN SUBGOAL_THEN `((p:A->A) POWER (n:num)) o ((inverse p) POWER n) = I` (LABEL_TAC "F2")
   THENL[SPEC_TAC(`n:num`, `n:num`)
      THEN INDUCT_TAC
      THENL[REWRITE_TAC[POWER_0; I_O_ID]; ALL_TAC]
      THEN GEN_REWRITE_TAC (LAND_CONV o LAND_CONV o ONCE_DEPTH_CONV) [COM_POWER]
      THEN GEN_REWRITE_TAC (LAND_CONV o RAND_CONV o ONCE_DEPTH_CONV) [POWER]
      THEN REWRITE_TAC[GSYM o_ASSOC]
      THEN REWRITE_TAC[lemma_4functions]
      THEN POP_ASSUM SUBST1_TAC
      THEN REWRITE_TAC[I_O_ID]
      THEN POP_ASSUM (fun th -> REWRITE_TAC[MATCH_MP PERMUTES_INVERSES_o th]); ALL_TAC]
   THEN ASM_REWRITE_TAC[]
   THEN REMOVE_THEN "F1" (LABEL_TAC "F1" o SPEC `n:num` o MATCH_MP power_permutation)
   THEN USE_THEN "F1" (fun th -> (REMOVE_THEN "F2" (fun th2 -> (MP_TAC (MATCH_MP LEFT_INVERSE_EQUATION (CONJ th th2))))))
   THEN DISCH_THEN (SUBST1_TAC o REWRITE_RULE[I_O_ID])
   THEN POP_ASSUM (fun th -> REWRITE_TAC[MATCH_MP PERMUTES_INVERSES_o th]));;

let lemma_power_inverse = prove(`!s:A->bool p:A->A n:num. p permutes s 
    ==> (inverse p) POWER n = inverse (p POWER n) /\ inverse ((inverse p) POWER n) = p POWER n`,
   REPEAT GEN_TAC
   THEN DISCH_THEN (LABEL_TAC "F1")
   THEN USE_THEN "F1" (LABEL_TAC "F2"  o SPEC `n:num` o MATCH_MP power_permutation)
   THEN SUBGOAL_THEN `(inverse (p:A->A)) POWER (n:num) = inverse (p POWER n)` ASSUME_TAC
   THENL[REMOVE_THEN "F1" (MP_TAC o CONJUNCT1 o  SPEC `n:num` o MATCH_MP lemma_power_inverse_map)
      THEN DISCH_THEN (fun th1 -> (POP_ASSUM (fun th -> MP_TAC (MATCH_MP RIGHT_INVERSE_EQUATION (CONJ th th1)))))
      THEN REWRITE_TAC[I_O_ID]; ALL_TAC]
   THEN ASM_REWRITE_TAC[]
   THEN USE_THEN "F2" (fun th ->REWRITE_TAC[MATCH_MP PERMUTES_INVERSE_INVERSE th]));;

let inverse_power_function = prove(`!(s:A->bool) (p:A->A) n:num x:A y:A. p permutes s ==> (y = (p POWER n) x  <=> x = ((inverse p) POWER n) y)`,
   REPEAT GEN_TAC
   THEN DISCH_THEN (LABEL_TAC "F1")
   THEN USE_THEN "F1" (ASSUME_TAC  o SPEC `n:num` o MATCH_MP power_permutation)
   THEN POP_ASSUM (MP_TAC o SPECL[`x:A`; `y:A`] o MATCH_MP PERMUTES_INVERSE_EQ)
   THEN POP_ASSUM (SUBST1_TAC o SYM o CONJUNCT1 o SPEC `n:num` o MATCH_MP lemma_power_inverse)
   THEN MESON_TAC[]);;

let edge_map_inverse_representation = prove(`!(H:(A)hypermap) (x:A) (y:A). y = edge_map H x <=> x = inverse (edge_map H) y`,
   REPEAT GEN_TAC 
   THEN MP_TAC (GSYM(SPECL[`x:A`; `y:A`] (MATCH_MP PERMUTES_INVERSE_EQ (CONJUNCT1(CONJUNCT2(SPEC `H:(A)hypermap` hypermap_lemma))))))
   THEN MESON_TAC[EQ_SYM]);;

let node_map_inverse_representation = prove(`!(H:(A)hypermap) (x:A) (y:A). y = node_map H x <=> x = inverse (node_map H) y`,
   REPEAT GEN_TAC 
   THEN MP_TAC (GSYM(SPECL[`x:A`; `y:A`] (MATCH_MP PERMUTES_INVERSE_EQ (CONJUNCT1(CONJUNCT2(CONJUNCT2(SPEC `H:(A)hypermap` hypermap_lemma)))))))
   THEN MESON_TAC[EQ_SYM]);;

let face_map_inverse_representation = prove(`!(H:(A)hypermap) (x:A) (y:A). y = face_map H x <=> x = inverse (face_map H) y`,
   REPEAT GEN_TAC THEN MP_TAC (GSYM(SPECL[`x:A`; `y:A`] (MATCH_MP PERMUTES_INVERSE_EQ (CONJUNCT1(CONJUNCT2(CONJUNCT2(CONJUNCT2(SPEC `H:(A)hypermap` hypermap_lemma))))))))
   THEN MESON_TAC[EQ_SYM]);;

let edge_map_injective = prove(`!(H:(A)hypermap) (x:A) (y:A). edge_map H x = edge_map H y <=> x = y`,
   REPEAT GEN_TAC 
   THEN MP_TAC (GSYM(SPECL[`x:A`; `y:A`] (MATCH_MP PERMUTES_INJECTIVE (CONJUNCT1(CONJUNCT2(SPEC `H:(A)hypermap` hypermap_lemma))))))
   THEN MESON_TAC[EQ_SYM]);;

let node_map_injective = prove(`!(H:(A)hypermap) (x:A) (y:A). node_map H x = node_map H y <=> x = y`,
   REPEAT GEN_TAC 
   THEN MP_TAC (GSYM(SPECL[`x:A`; `y:A`] (MATCH_MP PERMUTES_INJECTIVE (CONJUNCT1(CONJUNCT2(CONJUNCT2(SPEC `H:(A)hypermap` hypermap_lemma)))))))
   THEN MESON_TAC[EQ_SYM]);;

let face_map_injective = prove(`!(H:(A)hypermap) (x:A) (y:A). face_map H x = face_map H y <=> x = y`,
   REPEAT GEN_TAC THEN MP_TAC (GSYM(SPECL[`x:A`; `y:A`] (MATCH_MP PERMUTES_INJECTIVE (CONJUNCT1(CONJUNCT2(CONJUNCT2(CONJUNCT2(SPEC `H:(A)hypermap` hypermap_lemma))))))))
   THEN MESON_TAC[EQ_SYM]);;

(* Some lemmas on the cardinality of finite series *)

let IMAGE_SEG = prove(`!(n:num) (f:num->A). IMAGE f {i:num | i < n:num}  = {f (i:num) | i < n}`,
   REPEAT STRIP_TAC
   THEN REWRITE_TAC[IMAGE; IN_ELIM_THM] THEN SET_TAC[]);;

let FINITE_SERIES = prove(`!(n:num) (f:num->A). FINITE {f(i) | i < n}`,
   REPEAT GEN_TAC
   THEN ONCE_REWRITE_TAC[SYM(SPECL[`n:num`; `f:num->A`] IMAGE_SEG)]
   THEN MATCH_MP_TAC FINITE_IMAGE
   THEN REWRITE_TAC[FINITE_NUMSEG_LT]);;

let CARD_FINITE_SERIES_LE  = prove(`!(n:num) (f:num->A). CARD {f(i) | i < n} <= n`,
   REPEAT GEN_TAC
   THEN ONCE_REWRITE_TAC[SYM(SPECL[`n:num`; `f:num->A`] IMAGE_SEG)]
   THEN MP_TAC(ISPEC `f:num ->A` (MATCH_MP CARD_IMAGE_LE (SPEC `n:num` FINITE_NUMSEG_LT)))
   THEN REWRITE_TAC[CARD_NUMSEG_LT]);;

let LEMMA_INJ = prove(`!(n:num) (f:num->A).(!i:num j:num. i < n /\ j < i ==> ~(f i = f j)) ==> (!i:num j:num. i < n /\ j < n /\ f i = f j ==> i = j)`,
   REPEAT GEN_TAC
   THEN DISCH_TAC THEN MATCH_MP_TAC WLOG_LT
   THEN STRIP_TAC THENL[ARITH_TAC; ALL_TAC]
   THEN STRIP_TAC THENL[MESON_TAC[]; ALL_TAC]
   THEN ASM_MESON_TAC[]);;

let CARD_FINITE_SERIES_EQ  = prove(`!(n:num) (f:num->A). (!i:num j:num. i < n /\  j < i ==> ~(f i = f j)) ==> CARD {f(i) | i < n} = n`,
   REPEAT GEN_TAC
   THEN DISCH_THEN (LABEL_TAC "F1" o MATCH_MP LEMMA_INJ)
   THEN ONCE_REWRITE_TAC[GSYM IMAGE_SEG]
   THEN GEN_REWRITE_TAC(RAND_CONV o ONCE_DEPTH_CONV) [GSYM (SPEC `n:num` CARD_NUMSEG_LT)]
   THEN MATCH_MP_TAC CARD_IMAGE_INJ
   THEN REWRITE_TAC[FINITE_NUMSEG_LT]
   THEN REWRITE_TAC[IN_ELIM_THM]
   THEN ASM_REWRITE_TAC[]);;

(* In arbitrary finite group, every element has finite order *)

let LM_AUX = prove(`!m n. m < n ==> ?k. ~(k = 0) /\ n = m + k`,
   REPEAT GEN_TAC THEN REWRITE_TAC[LT_EXISTS] 
   THEN DISCH_THEN(X_CHOOSE_THEN `d:num` ASSUME_TAC)
   THEN EXISTS_TAC `SUC d` 
   THEN ASM_REWRITE_TAC[ARITH_RULE `~(SUC d = 0)`]);;

let LM1 = prove(`!s:A->bool p:A->A n:num m:num. p permutes s /\ p POWER (m+n) = p POWER m ==> p POWER n = I`,
   REPEAT GEN_TAC THEN DISCH_THEN(CONJUNCTS_THEN2 (LABEL_TAC "c1") (MP_TAC))
   THEN REWRITE_TAC[addition_exponents] THEN DISCH_TAC THEN
   REMOVE_THEN "c1" (ASSUME_TAC o (SPEC `m:num`) o MATCH_MP power_permutation)
   THEN MP_TAC (SPECL[`s:A->bool`; `(p:A->A) POWER (m:num)`;`(p:A->A) POWER (n:num)`; `(p:A->A) POWER (m:num)`] LEFT_INVERSE_EQUATION)
   THEN ASM_REWRITE_TAC[] THEN POP_ASSUM(MP_TAC o CONJUNCT2 o (MATCH_MP PERMUTES_INVERSES_o))
   THEN SIMP_TAC[]);;

let lemma_sub_two_numbers = prove(`!m:num n:num p:num. m - n - p = m - (n + p)`, ARITH_TAC);;

let NON_ZERO = prove(`!n:num. ~(SUC n = 0)`, REWRITE_TAC[GSYM LT_NZ; LT_0]);;

let LT1_NZ = prove(`!n:num. 1 <= n <=> 0 < n`, ARITH_TAC);;

let LT_PLUS = prove(`!n:num. n < SUC n`, ARITH_TAC);;

let LT_SUC_PRE = prove(`!n:num. 0 < n ==> n = SUC(PRE n)`, ARITH_TAC);;

let LT_PRE = prove(`!n:num. 0 < n ==> n = (PRE n) + 1`,
   GEN_TAC THEN DISCH_THEN (MP_TAC  o MATCH_MP LT_SUC_PRE) THEN REWRITE_TAC[ADD1]);;

let LE_MOD_SUC = prove(`!n m. m MOD (SUC n) <= n`,
   REPEAT GEN_TAC
   THEN MP_TAC(CONJUNCT2(SPEC `m:num`(MATCH_MP DIVISION (SPEC `n:num` NON_ZERO))))
   THEN REWRITE_TAC[LT_SUC_LE]);;

let LT0_LE1 = prove(`!n:num. 0 < n <=> 1 <= n`, ARITH_TAC);;

let ZR_LT_1 = prove(`0 < 1`, ARITH_TAC);;

let LT_RIGHT_SUC = prove(`!i:num n:num. i < n ==> i < SUC n`, ARITH_TAC);;

let MOD_REFL = prove(`!m n. ~(n = 0) ==> ((m MOD n) MOD n = m MOD n)`,  (* in file ARITH.ML *)
    REPEAT GEN_TAC THEN DISCH_TAC THEN
    MP_TAC(SPECL [`m:num`; `n:num`; `1`] MOD_MOD) THEN
    ASM_REWRITE_TAC[MULT_CLAUSES; MULT_EQ_0] THEN
    REWRITE_TAC[ONE; NOT_SUC]);;

let THREE = prove(`3 = SUC 2`, ARITH_TAC);;


(***********************************************************************)


let inj_iterate_segment = prove(`!s:A->bool p:A->A (n:num). p permutes s /\ 
   ~(n = 0) ==> (!m:num. ~(m = 0) /\ (m < n) ==> ~(p POWER m = I)) 
   ==> (!i:num j:num. (i < n) /\ (j < i) ==> ~(p POWER i = p POWER j))`,
   REPEAT GEN_TAC THEN DISCH_THEN(CONJUNCTS_THEN2 (LABEL_TAC "c2") (ASSUME_TAC))
   THEN DISCH_THEN (LABEL_TAC "c3") THEN REPLICATE_TAC 3 STRIP_TAC
   THEN DISCH_THEN (LABEL_TAC "c4") THEN FIRST_X_ASSUM(MP_TAC o MATCH_MP LM_AUX)
   THEN REPEAT STRIP_TAC THEN REMOVE_THEN "c3" MP_TAC THEN
   REWRITE_TAC[NOT_FORALL_THM; NOT_IMP]
   THEN EXISTS_TAC `k:num` THEN MP_TAC (ARITH_RULE `(i:num < n:num) /\ (i = (j:num) + (k:num)) ==> k < n`)
   THEN ASM_REWRITE_TAC[] THEN STRIP_TAC THEN ASM_REWRITE_TAC[]
   THEN REMOVE_THEN "c4" MP_TAC THEN ASM_REWRITE_TAC[] THEN STRIP_TAC
   THEN MP_TAC (ISPECL[`s:A->bool`; `p:A->A`; `k:num`; `j:num`] LM1) 
   THEN ASM_REWRITE_TAC[]);;

let inj_iterate_lemma = prove(`!s:A->bool p:A->A. p permutes s /\
   (!(n:num). ~(n = 0) ==> ~(p POWER n = I)) ==> (!m. CARD({p POWER k | k < m}) = m)`,
   REPEAT GEN_TAC THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "c1") (LABEL_TAC "c2"))
   THEN GEN_TAC 
   THEN SUBGOAL_THEN `!i:num j:num. i < (m:num) /\  j < i ==> ~((p:A->A) POWER i = p POWER j)` ASSUME_TAC
   THENL[REPEAT GEN_TAC THEN STRIP_TAC THEN POP_ASSUM (MP_TAC o MATCH_MP LM_AUX)
      THEN STRIP_TAC THEN ASM_REWRITE_TAC[]  THEN STRIP_TAC
      THEN MP_TAC (ISPECL[`s:A->bool`; `p:A->A`; `k:num`; `j:num`] LM1) 
      THEN ASM_REWRITE_TAC[]
      THEN STRIP_TAC THEN REMOVE_THEN "c2" (MP_TAC o SPEC(`k:num`)) 
      THEN REWRITE_TAC[NOT_IMP]
      THEN ASM_REWRITE_TAC[]; 
      POP_ASSUM(MP_TAC o MATCH_MP CARD_FINITE_SERIES_EQ)
      THEN SIMP_TAC[]]);;  

let NEW_CARD_SUBSET = prove (`!(a:(A->A)->bool) b. a SUBSET b /\ FINITE(b) ==> CARD(a) <= CARD(b)`,
   REPEAT STRIP_TAC
   THEN MATCH_MP_TAC CARD_SUBSET THEN ASM_REWRITE_TAC[]);;


(* finite order theorem on every element in arbitrary finite group *)

let finite_order = prove( `!s:A->bool p:A->A. FINITE s /\ p permutes s 
   ==> ?(n:num). ~(n = 0) /\ p POWER n = I`,
   REPEAT GEN_TAC THEN DISCH_THEN(CONJUNCTS_THEN2 (LABEL_TAC "c1") (ASSUME_TAC)) 
   THEN ASM_CASES_TAC `?(n:num). ~(n = 0) /\ (p:A->A) POWER n = I` 
   THENL[ASM_SIMP_TAC[]; ALL_TAC]
   THEN POP_ASSUM MP_TAC 
   THEN REWRITE_TAC[NOT_EXISTS_THM; DE_MORGAN_THM; TAUT `!a b. ~(a /\ b) = (a ==> ~b)`]
   THEN DISCH_TAC THEN MP_TAC (ISPECL[`s:A->bool`; `p:A->A`] inj_iterate_lemma)
   THEN ASM_REWRITE_TAC[] THEN DISCH_TAC
   THEN USE_THEN "c1" (ASSUME_TAC o MATCH_MP FINITE_PERMUTATIONS)
   THEN ABBREV_TAC `md = SUC(CARD({p | p permutes (s:A->bool)}))`
   THEN SUBGOAL_THEN `{(p:A->A) POWER (k:num) | k < (md:num)} SUBSET {p | p permutes (s:A->bool)}` ASSUME_TAC
   THENL[REWRITE_TAC[SUBSET; IN_ELIM_THM] THEN REPEAT STRIP_TAC 
   THEN ASM_MESON_TAC[power_permutation]; ALL_TAC]
   THEN MP_TAC (ISPECL[`{(p:A->A) POWER (k:num) | k < (md:num)}`;`{p | p permutes (s:A->bool)}`] NEW_CARD_SUBSET)
   THEN ASM_REWRITE_TAC[] THEN EXPAND_TAC "md" THEN ARITH_TAC);;

let inverse_element_lemma = prove(`!s:A->bool p:A->A. FINITE s /\ p permutes s ==> ?j:num. inverse p = p POWER j`,
   REPEAT GEN_TAC
   THEN DISCH_THEN(fun th -> MP_TAC (MATCH_MP finite_order th) THEN ASSUME_TAC(CONJUNCT2 th))
   THEN REWRITE_TAC[GSYM LT_NZ]
   THEN DISCH_THEN (X_CHOOSE_THEN `n:num` (CONJUNCTS_THEN2 (MP_TAC) (ASSUME_TAC)))
   THEN DISCH_THEN (SUBST_ALL_TAC o MATCH_MP LT_SUC_PRE)
   THEN POP_ASSUM MP_TAC
   THEN REWRITE_TAC[POWER]
   THEN POP_ASSUM (fun th -> (DISCH_THEN (fun th1 -> MP_TAC (MATCH_MP RIGHT_INVERSE_EQUATION (CONJ th th1)))))
   THEN REWRITE_TAC[I_O_ID]
   THEN DISCH_THEN (ASSUME_TAC o SYM)
   THEN EXISTS_TAC `PRE n`
   THEN ASM_REWRITE_TAC[]);;

let lemma_permutation_via_its_inverse = prove(`!s:A->bool p:A->A. FINITE s /\ p permutes s ==> ?j:num. p = (inverse p) POWER j`,
   REPEAT GEN_TAC
   THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F1") (LABEL_TAC "F2"))
   THEN USE_THEN "F2" (ASSUME_TAC o MATCH_MP PERMUTES_INVERSE)
   THEN POP_ASSUM (fun th -> (REMOVE_THEN "F1" (fun th2 -> (MP_TAC (MATCH_MP inverse_element_lemma (CONJ th2 th))))))
   THEN POP_ASSUM (SUBST1_TAC o MATCH_MP PERMUTES_INVERSE_INVERSE)
   THEN SIMP_TAC[]);;

let power_inverse_element_lemma = prove(`!s:A->bool p:A->A n:num. FINITE s /\ p permutes s ==> ?j:num. (inverse p) POWER n = p POWER j`,
 REPLICATE_TAC 2 GEN_TAC
   THEN INDUCT_TAC
   THENL[STRIP_TAC
      THEN EXISTS_TAC `0`
      THEN REWRITE_TAC[POWER_0]; ALL_TAC]
   THEN DISCH_TAC
   THEN FIRST_X_ASSUM (MP_TAC o check (is_imp o concl))
   THEN ASM_REWRITE_TAC[]
   THEN STRIP_TAC
   THEN FIRST_X_ASSUM (MP_TAC o MATCH_MP  inverse_element_lemma)
   THEN DISCH_THEN (X_CHOOSE_THEN `i:num` ASSUME_TAC)
   THEN EXISTS_TAC `(j:num) + (i:num)`
   THEN REWRITE_TAC[POWER]
   THEN POP_ASSUM (fun th -> GEN_REWRITE_TAC (LAND_CONV o RAND_CONV) [th])
   THEN ASM_REWRITE_TAC[addition_exponents]);;

let inverse_relation = prove(`!(s:A->bool) p:A->A x:A y:A. FINITE s /\ p permutes s /\ y = p x ==>(?k:num. x = (p POWER k) y)`, 
   REPEAT STRIP_TAC THEN MP_TAC(SPECL[`s:A->bool`; `p:A->A`] inverse_element_lemma) 
   THEN ASM_REWRITE_TAC[] THEN STRIP_TAC THEN EXISTS_TAC `j:num` 
   THEN POP_ASSUM(fun th -> REWRITE_TAC[SYM th]) 
   THEN REWRITE_TAC[GSYM(ISPECL[`(inverse (p:A->A)):(A->A)`; `p:A->A`; `(x:A)`] o_THM)] 
   THEN UNDISCH_THEN `p:A->A permutes s`(fun th-> REWRITE_TAC[CONJUNCT2 (MATCH_MP PERMUTES_INVERSES_o th);I_THM]));;

(* some properties of orbits *)

let orbit_reflect = prove(`!f:A->A x:A. x IN (orbit_map f x)`, 
   REPEAT GEN_TAC THEN REWRITE_TAC[orbit_map; IN_ELIM_THM] 
   THEN EXISTS_TAC `0` THEN REWRITE_TAC[POWER; ARITH_RULE `0>=0`;I_THM]);;

let orbit_sym = prove(`!s:A->bool p:A->A x:A y:A. FINITE s /\ p permutes s
   ==> (x IN (orbit_map p y) ==> y IN (orbit_map p x))`, 
   REPLICATE_TAC 5 STRIP_TAC THEN REWRITE_TAC[orbit_map; IN_ELIM_THM] 
   THEN  STRIP_TAC 
   THEN FIND_ASSUM (ASSUME_TAC o (SPEC `n:num`) o MATCH_MP power_permutation) `p:A->A permutes (s:A->bool)` 
   THEN POP_ASSUM (MP_TAC o (SPECL[`y:A`; `x:A`]) o MATCH_MP PERMUTES_INVERSE_EQ) 
   THEN POP_ASSUM(ASSUME_TAC o SYM) THEN ASM_REWRITE_TAC[] 
   THEN UNDISCH_THEN `p:A->A permutes s` (ASSUME_TAC o (SPEC `n:num`) o MATCH_MP power_permutation) 
   THEN MP_TAC(SPECL[`s:A->bool`; `(p:A->A) POWER (n:num)`] inverse_element_lemma) 
   THEN ASM_REWRITE_TAC[GSYM multiplication_exponents]
   THEN STRIP_TAC THEN ASM_REWRITE_TAC[] THEN STRIP_TAC 
   THEN EXISTS_TAC `(j:num) * (n:num)` 
   THEN ASM_REWRITE_TAC[ARITH_RULE `(j:num) * (n:num) >= 0`]);;

let orbit_trans = prove(`!f:A->A x:A y:A z:A. x IN orbit_map f y /\ y IN orbit_map f z 
   ==> x IN orbit_map f z`,
   REPEAT GEN_TAC THEN REWRITE_TAC[orbit_map; IN_ELIM_THM] 
   THEN REPEAT STRIP_TAC THEN 
   UNDISCH_THEN `x:A = ((f:A->A) POWER (n:num)) (y:A)` MP_TAC 
   THEN  ASM_REWRITE_TAC[] 
   THEN DISCH_THEN (ASSUME_TAC o SYM) THEN MP_TAC (SPECL[`n:num`; `n':num`; `f:A->A`] addition_exponents) 
   THEN  DISCH_THEN(fun th -> MP_TAC (AP_THM th `z:A`)) 
   THEN ASM_REWRITE_TAC[o_DEF] THEN DISCH_THEN (ASSUME_TAC o SYM)
   THEN EXISTS_TAC `(n:num) + n'` 
   THEN ASM_REWRITE_TAC[ARITH_RULE `(n:num) + (n':num) >= 0`]);;


let partition_orbit = prove(`!s:A->bool p:A->A. FINITE s /\ p permutes s
   ==>(!x:A y:A. (orbit_map p x INTER orbit_map p y = {}) \/ (orbit_map p x = orbit_map p y))`, 
   REPEAT STRIP_TAC THEN ASM_CASES_TAC `orbit_map (p:A->A)(x:A) INTER orbit_map (p:A->A) (y:A) = {}` 
   THENL[ASM_REWRITE_TAC[]; ALL_TAC] 
   THEN DISJ2_TAC THEN  POP_ASSUM MP_TAC THEN REWRITE_TAC[GSYM MEMBER_NOT_EMPTY] 
   THEN REWRITE_TAC[INTER; IN_ELIM_THM] THEN STRIP_TAC 
   THEN MP_TAC (SPECL[`s:A->bool`; `p:A->A`; `x':A`; `x:A`] orbit_sym) 
   THEN ASM_REWRITE_TAC[] THEN STRIP_TAC THEN MP_TAC (SPECL[`s:A->bool`; `p:A->A`; `x':A`; `y:A`] orbit_sym) 
   THEN ASM_REWRITE_TAC[] THEN STRIP_TAC THEN REWRITE_TAC[EXTENSION] THEN GEN_TAC 
   THEN EQ_TAC 
   THENL[STRIP_TAC THEN MP_TAC (SPECL[`p:A->A`; `x'':A`; `x:A`;`x':A`] orbit_trans) 
      THEN ASM_MESON_TAC[orbit_trans]; 
      STRIP_TAC THEN MP_TAC (SPECL[`p:A->A`; `x'':A`; `y:A`;`x':A`] orbit_trans) 
      THEN ASM_MESON_TAC[orbit_trans]]);;

let card_orbit_le = prove(`!f:A->A n:num x:A. ~(n = 0) /\ (f POWER n) x = x ==> CARD(orbit_map f x) <= n`, 
   REPEAT GEN_TAC 
   THEN DISCH_THEN (fun th -> SUBST1_TAC (MATCH_MP orbit_cyclic th) 
   THEN ASSUME_TAC (CONJUNCT1 th)) 
   THEN MP_TAC (SPECL[`n:num`; `(\k. ((f:A->A) POWER k) (x:A))`] CARD_FINITE_SERIES_LE) 
   THEN MESON_TAC[]);;


(* some properties of hypermap *)

let cyclic_maps = prove(`!D:A->bool e:A->A n:A->A f:A->A. 
   (FINITE D) /\ e permutes D /\ n permutes D /\ f permutes D /\ e o n o f = I 
    ==> (n o f o e = I) /\ (f o e o n = I)`, 
   REPEAT STRIP_TAC 
   THENL[MP_TAC (ISPECL[`D:A->bool`;`e:A->A`; `(n:A->A) o (f:A->A)`; `I:A->A`]
      LEFT_INVERSE_EQUATION) THEN ASM_REWRITE_TAC[I_O_ID] 
      THEN FIND_ASSUM (ASSUME_TAC o CONJUNCT2 o MATCH_MP PERMUTES_INVERSES_o) `e:A->A permutes D:A->bool` 
      THEN DISCH_TAC 
      THEN MP_TAC (ISPECL[`(n:A->A)o(f:A->A)`;`inverse(e:A->A)`;`e:A->A` ] RIGHT_MULT_MAP) 
      THEN ASM_REWRITE_TAC[o_ASSOC]; 
      MP_TAC (ISPECL[`D:A->bool`;`(e:A->A)o(n:A->A)`;`(f:A->A)`; `I:A->A`] RIGHT_INVERSE_EQUATION) 
      THEN ASM_REWRITE_TAC[I_O_ID; GSYM o_ASSOC] 
      THEN DISCH_TAC  THEN MP_TAC (ISPECL[`D:A->bool`;`(e:A->A) o (n:A->A)`; `(f:A->A)`; `I:A->A`] RIGHT_INVERSE_EQUATION) 
      THEN ASM_REWRITE_TAC[GSYM o_ASSOC; I_O_ID] 
      THEN FIND_ASSUM (ASSUME_TAC o CONJUNCT1 o MATCH_MP PERMUTES_INVERSES_o) `f:A->A permutes D:A->bool` 
      THEN ASM_SIMP_TAC[]]);;

let cyclic_inverses_maps = prove(`!D:A->bool e:A->A n:A->A f:A->A. 
   (FINITE D) /\ e permutes D /\ n permutes D /\ f permutes D /\ e o n o f = I 
   ==> inverse n o inverse e o inverse f = I`, 
   
   REPEAT STRIP_TAC THEN MP_TAC (ISPECL[`D:A->bool`; `e:A->A`; `n:A->A`; `f:A->A`] cyclic_maps) 
   THEN ASM_REWRITE_TAC[] THEN REPEAT STRIP_TAC 
   THEN  MP_TAC (ISPECL[`D:A->bool`;`f:A->A`; `(e:A->A) o (n:A->A)`; `I:A->A`] LEFT_INVERSE_EQUATION) 
   THEN ASM_REWRITE_TAC[I_O_ID] THEN STRIP_TAC 
   THEN MP_TAC (ISPECL[`D:A->bool`;`e:A->A`; `(n:A->A)`; `inverse(f:A->A)`] LEFT_INVERSE_EQUATION) 
   THEN ASM_REWRITE_TAC[] THEN DISCH_TAC 
   THEN  MP_TAC (ISPECL[`inverse(n:A->A)`; `n:A->A`; `inverse(e:A->A) o inverse(f:A->A)`] LEFT_MULT_MAP) 
   THEN FIND_ASSUM (ASSUME_TAC o CONJUNCT2 o MATCH_MP PERMUTES_INVERSES_o) `n:A->A permutes D:A->bool` 
   THEN ASM_REWRITE_TAC[] THEN DISCH_THEN(MP_TAC o SYM) THEN REWRITE_TAC[]);;

(* Some label_TAC *)

let label_4Gs_TAC th = CONJUNCTS_THEN2 (LABEL_TAC "G1") (CONJUNCTS_THEN2(LABEL_TAC "G2") (CONJUNCTS_THEN2 (LABEL_TAC "G3") (LABEL_TAC "G4"))) th;;

let label_hypermap_TAC th = CONJUNCTS_THEN2 (LABEL_TAC "H1") (CONJUNCTS_THEN2(LABEL_TAC "H2") (CONJUNCTS_THEN2 (LABEL_TAC "H3") (CONJUNCTS_THEN2 (LABEL_TAC "H4") (LABEL_TAC "H5")) )) (SPEC th hypermap_lemma);;

let label_hypermap4_TAC th = CONJUNCTS_THEN2 (LABEL_TAC "H1") (CONJUNCTS_THEN2(LABEL_TAC "H2") (CONJUNCTS_THEN2 (LABEL_TAC "H3") (LABEL_TAC "H4" o CONJUNCT1))) (SPEC th hypermap_lemma);;

let label_hypermapG_TAC th = CONJUNCTS_THEN2 (LABEL_TAC "G1") (CONJUNCTS_THEN2(LABEL_TAC "G2") (CONJUNCTS_THEN2 (LABEL_TAC "G3") (CONJUNCTS_THEN2 (LABEL_TAC "G4") (LABEL_TAC "G5")) )) (SPEC th hypermap_lemma);;

let label_strip3A_TAC th = CONJUNCTS_THEN2 (LABEL_TAC "A1") (CONJUNCTS_THEN2(LABEL_TAC "A2")(LABEL_TAC "A3")) th;;

(* Hypermap cycle *)

let hypermap_cyclic = prove(`!(H:(A)hypermap). (node_map H) o (face_map H) o (edge_map H) = I /\ (face_map H) o (edge_map H) o (node_map H) = I`, 
   GEN_TAC THEN label_hypermap_TAC `H:(A)hypermap`
   THEN MP_TAC(SPECL[`dart (H:(A)hypermap)`; `edge_map (H:(A)hypermap)`; `node_map (H:(A)hypermap)`;`face_map (H:(A)hypermap)`] cyclic_maps) 
   THEN ASM_REWRITE_TAC[]);;


(* INVERSES HYPERMAP MAPS *)

let label_cyclic_maps_TAC th = CONJUNCTS_THEN2 (LABEL_TAC "H6") (LABEL_TAC "H7") (SPEC th hypermap_cyclic);;

let inverse_hypermap_maps = prove(`!(H:(A)hypermap). inverse(edge_map H) = (node_map H) o (face_map H) /\ inverse(node_map H) = (face_map H) o (edge_map H) /\ inverse(face_map H) = (edge_map H) o (node_map H)`,   
   GEN_TAC THEN label_hypermap_TAC `(H:(A)hypermap)` 
   THEN label_cyclic_maps_TAC `(H:(A)hypermap)` THEN ABBREV_TAC `D = dart (H:(A)hypermap)` 
   THEN ABBREV_TAC `e = edge_map (H:(A)hypermap)` THEN ABBREV_TAC `n = node_map (H:(A)hypermap)` 
   THEN ABBREV_TAC `f = face_map (H:(A)hypermap)` 
   THEN MP_TAC (SPECL[`D:A->bool`;`e:A->A`; `(n:A->A) o (f:A->A)`; `I:A->A`] LEFT_INVERSE_EQUATION) 
   THEN ASM_REWRITE_TAC[I_O_ID] THEN DISCH_THEN (fun th -> REWRITE_TAC[SYM th]) 
   THEN MP_TAC (SPECL[`D:A->bool`;`n:A->A`; `(f:A->A) o (e:A->A)`; `I:A->A`] LEFT_INVERSE_EQUATION) 
   THEN ASM_REWRITE_TAC[I_O_ID] THEN DISCH_THEN (fun th -> REWRITE_TAC[SYM th]) 
   THEN MP_TAC (SPECL[`D:A->bool`;`f:A->A`; `(e:A->A) o (n:A->A)`; `I:A->A`] LEFT_INVERSE_EQUATION) 
   THEN ASM_REWRITE_TAC[I_O_ID] THEN DISCH_THEN (fun th -> REWRITE_TAC[SYM th]));;

let inverse2_hypermap_maps = prove(`!(H:(A)hypermap). edge_map H = inverse (face_map H) o inverse (node_map H) /\ node_map H = inverse (edge_map H) o inverse (face_map H) /\ face_map H = inverse (node_map H) o inverse(edge_map H)`, 
   GEN_TAC THEN label_hypermap_TAC `(H:(A)hypermap)` 
   THEN label_strip3A_TAC (SPEC `H:(A)hypermap` inverse_hypermap_maps) 
   THEN label_cyclic_maps_TAC `(H:(A)hypermap)` 
   THEN ABBREV_TAC `D = dart (H:(A)hypermap)` 
   THEN ABBREV_TAC `e = edge_map (H:(A)hypermap)` 
   THEN ABBREV_TAC `n = node_map (H:(A)hypermap)` 
   THEN ABBREV_TAC `f = face_map (H:(A)hypermap)` 
   THEN REMOVE_THEN "A1" ((LABEL_TAC "B1") o SYM) 
   THEN MP_TAC (SPECL[`D:A->bool`;`n:A->A`; `(f:A->A)`; `inverse(e:A->A)`] LEFT_INVERSE_EQUATION) 
   THEN ASM_REWRITE_TAC[I_O_ID] THEN DISCH_THEN (fun th -> REWRITE_TAC[SYM th]) 
   THEN REMOVE_THEN "A2" ((LABEL_TAC "B2") o SYM) 
   THEN MP_TAC (SPECL[`D:A->bool`;`f:A->A`; `(e:A->A)`; `inverse(n:A->A)`] LEFT_INVERSE_EQUATION) 
   THEN ASM_REWRITE_TAC[I_O_ID] THEN DISCH_THEN (fun th -> REWRITE_TAC[SYM th]) THEN ASM_REWRITE_TAC[o_ASSOC] 
   THEN REMOVE_THEN "H2" (MP_TAC o CONJUNCT2 o  MATCH_MP PERMUTES_INVERSES_o) THEN SIMP_TAC[I_O_ID]);;

let lemmaZHQCZLX = prove(`!H:(A)hypermap. (simple_hypermap H /\ plain_hypermap H /\ (!x:A. x IN dart H ==> CARD (face H x) >= 3)) 
   ==> (!x:A. x IN dart H ==> ~(node_map H x = x))`,
   GEN_TAC THEN REWRITE_TAC[simple_hypermap; plain_hypermap;face; node] 
   THEN MP_TAC (SPEC `H:(A)hypermap` hypermap_lemma)
   THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "c1") (CONJUNCTS_THEN2 (LABEL_TAC "c2") (CONJUNCTS_THEN2 (LABEL_TAC "c3") (CONJUNCTS_THEN2 (LABEL_TAC "c4") (LABEL_TAC "c5")))))
   THEN DISCH_THEN(CONJUNCTS_THEN2 (LABEL_TAC "c6") (CONJUNCTS_THEN2 (LABEL_TAC "c7") (LABEL_TAC "c8")))
   THEN GEN_TAC THEN DISCH_THEN (LABEL_TAC "c9") 
   THEN DISCH_THEN (LABEL_TAC "c10")
   THEN ABBREV_TAC `D = dart (H:(A)hypermap)` 
   THEN ABBREV_TAC `e = edge_map (H:(A)hypermap)`  
   THEN ABBREV_TAC `n = node_map (H:(A)hypermap)` 
   THEN ABBREV_TAC `f = face_map (H:(A)hypermap)`
   THEN USE_THEN "c2" (MP_TAC o (SPEC `x:A`) o MATCH_MP PERMUTES_IN_IMAGE)
   THEN USE_THEN "c4" (MP_TAC o (SPEC `x:A`) o MATCH_MP PERMUTES_IN_IMAGE)
   THEN ASM_REWRITE_TAC[] THEN REPEAT STRIP_TAC 
   THEN ABBREV_TAC `y:A = (f:A->A) (x:A)` THEN ABBREV_TAC `z:A = (e:A->A) (x:A)`
   THEN USE_THEN "c7" MP_TAC THEN USE_THEN "c2" MP_TAC THEN REWRITE_TAC[IMP_IMP]
   THEN DISCH_THEN (MP_TAC o MATCH_MP LEFT_INVERSE_EQUATION) 
   THEN REWRITE_TAC[I_O_ID]
   THEN DISCH_THEN(fun th -> (ASSUME_TAC (SYM th)) 
   THEN (ASSUME_TAC (AP_THM (SYM th) `x:A`)))
   THEN USE_THEN "c3" (MP_TAC o (SPECL[`x:A`;`x:A`]) o MATCH_MP PERMUTES_INVERSE_EQ)
   THEN ASM_REWRITE_TAC[] THEN DISCH_TAC THEN USE_THEN "c5" MP_TAC
   THEN USE_THEN "c2" MP_TAC THEN REWRITE_TAC[IMP_IMP]
   THEN DISCH_THEN (MP_TAC o MATCH_MP LEFT_INVERSE_EQUATION) THEN REWRITE_TAC[I_O_ID]
   THEN DISCH_THEN(fun th -> (ASSUME_TAC (SYM th)) 
   THEN (MP_TAC (AP_THM (SYM th) `x:A`)))
   THEN ASM_REWRITE_TAC[o_THM] THEN DISCH_THEN (MP_TAC o SYM)
   THEN MP_TAC (SPECL[`D:A->bool`; `e:A->A`; `n:A->A`; `f:A->A`] cyclic_maps)
   THEN ASM_REWRITE_TAC[] THEN DISCH_THEN (fun th -> MP_TAC (AP_THM (CONJUNCT2 th) `x:A`))
   THEN ASM_REWRITE_TAC[o_THM; I_THM] THEN DISCH_THEN (MP_TAC o AP_TERM `f:A->A`) 
   THEN ASM_REWRITE_TAC[]
   THEN DISCH_THEN (LABEL_TAC "c11") THEN DISCH_THEN (LABEL_TAC "c12")
   THEN MP_TAC (SPECL[`f:A->A`; `2`; `z:A`; `y:A`] in_orbit_lemma) 
   THEN ASM_REWRITE_TAC[POWER_2; o_THM]
   THEN DISCH_TAC THEN MP_TAC (SPECL[`D:A->bool`; `f:A->A`; `y:A`; `z:A`] orbit_sym)
   THEN ASM_REWRITE_TAC[] THEN DISCH_THEN (LABEL_TAC "d1") 
   THEN MP_TAC (SPECL[`n:A->A`; `1`; `y:A`; `z:A`] in_orbit_lemma)
   THEN ASM_REWRITE_TAC[POWER_1] THEN DISCH_THEN (LABEL_TAC "d2")
   THEN REMOVE_THEN "c6" (MP_TAC o (SPEC `y:A`))
   THEN UNDISCH_TAC `(y:A) IN D` THEN ASM_REWRITE_TAC[IN] THEN STRIP_TAC
   THEN ASM_REWRITE_TAC[] THEN STRIP_TAC
   THEN MP_TAC (SPECL[`orbit_map (n:A->A) (y:A)`;`orbit_map (f:A->A) (y:A)`;`z:A`] IN_INTER)
   THEN ASM_REWRITE_TAC[IN_SING] THEN STRIP_TAC
   THEN REMOVE_THEN "c11" MP_TAC THEN ASM_REWRITE_TAC[] THEN DISCH_TAC
   THEN MP_TAC (SPECL[`f:A->A`; `2`; `y:A`] card_orbit_le)
   THEN ASM_REWRITE_TAC[ARITH; POWER_2; o_DEF] THEN DISCH_TAC
   THEN REMOVE_THEN "c8" (MP_TAC o (SPEC `y:A`)) THEN ASM_REWRITE_TAC[IN]
   THEN POP_ASSUM MP_TAC THEN ARITH_TAC);;

(* Definition of connected hypermap *)

let connected_hypermap = new_definition `connected_hypermap (H:(A)hypermap) <=> number_of_components H = 1`;;

(* Some lemmas about counting the orbits of a permutation *)

let finite_orbits_lemma = prove(`!D:A->bool p:A->A. (FINITE D /\ p permutes D) ==> FINITE (set_of_orbits D p)`, 
   REPEAT STRIP_TAC THEN SUBGOAL_THEN `IMAGE (\x:A. orbit_map (p:A->A) x) (D:A->bool) = set_of_orbits D p` ASSUME_TAC 
   THENL[REWRITE_TAC[EXTENSION] THEN STRIP_TAC THEN EQ_TAC THENL[REWRITE_TAC[set_of_orbits;IMAGE;IN;IN_ELIM_THM];ALL_TAC] 
   THEN REWRITE_TAC[set_of_orbits;IMAGE;IN;IN_ELIM_THM];ALL_TAC] 
   THEN POP_ASSUM (fun th -> REWRITE_TAC[SYM th]) 
   THEN MATCH_MP_TAC FINITE_IMAGE THEN ASM_SIMP_TAC[]);;

let lemma_disjoints = prove(`!(s:(A->bool)->bool) (t:A->bool). (!(v:A->bool). v IN s ==> DISJOINT t v) ==> DISJOINT t (UNIONS s)`, SET_TAC[]);;

let SET_SIZE_CLAUSES = prove (`(!s. s HAS_SIZE 0 <=> (s = {})) /\(!s (n:num). s HAS_SIZE (SUC n) <=> ?a t. t HAS_SIZE n /\ ~(a IN t) /\ (s = a INSERT t))`,let lemma = SET_RULE `a IN s ==> (s = a INSERT (s DELETE a))` in REWRITE_TAC[HAS_SIZE_0] THEN REPEAT STRIP_TAC THEN EQ_TAC 
   THENL[REWRITE_TAC[HAS_SIZE_SUC; GSYM MEMBER_NOT_EMPTY] THEN MESON_TAC[lemma; IN_DELETE];
        SIMP_TAC[LEFT_IMP_EXISTS_THM; HAS_SIZE; CARD_CLAUSES; FINITE_INSERT]]);;

let TYPED_FINITE_UNIONS = prove
 (`!s:(A->bool)->bool. FINITE(s) ==> (FINITE(UNIONS s) <=> (!g:A->bool. g IN s ==> FINITE(g)))`,
  MATCH_MP_TAC FINITE_INDUCT THEN
  REWRITE_TAC[IN_INSERT; NOT_IN_EMPTY; UNIONS_0; UNIONS_INSERT] THEN
  REWRITE_TAC[FINITE_UNION; FINITE_RULES] THEN MESON_TAC[]);;

let lemma_partition = prove( `!s:A->bool p:A->A. FINITE s /\ p permutes s ==> s = UNIONS (set_of_orbits s p)`,
   REPEAT STRIP_TAC THEN REWRITE_TAC[EXTENSION;IN_UNIONS] THEN  GEN_TAC THEN EQ_TAC 
   THENL[MP_TAC (ISPECL[`p:A->A`;`x:A`] orbit_reflect) THEN REWRITE_TAC[set_of_orbits] 
      THEN REPEAT STRIP_TAC THEN EXISTS_TAC `(orbit_map p x):A->bool` THEN (SET_TAC[]); 
      DISCH_THEN(X_CHOOSE_THEN `t:A->bool` MP_TAC) THEN REWRITE_TAC[IN_ELIM_THM;set_of_orbits] 
      THEN STRIP_TAC THEN FIRST_ASSUM SUBST_ALL_TAC THEN FIRST_ASSUM(MP_TAC o MATCH_MP  orbit_subset) THEN SET_TAC[]]);;

let lemma_card_of_disjoint_covering = prove(`!(t:(A->bool)->bool). (FINITE t /\ (!u:A->bool. u IN t ==> FINITE u) 
   /\ (!(s1:A->bool) (s2:A->bool). s1 IN t /\ s2 IN t /\ ~(s1 = s2) ==> DISJOINT s1 s2)) ==> CARD (UNIONS t) = nsum t (\u. CARD u)`,
   GEN_TAC
   THEN ABBREV_TAC `n = CARD (t:(A->bool)->bool)`
   THEN POP_ASSUM (MP_TAC)
   THEN REWRITE_TAC[IMP_IMP]
   THEN SPEC_TAC(`t:(A->bool)->bool`, `t:(A->bool)->bool`)
   THEN SPEC_TAC(`n:num`, `n:num`)
   THEN INDUCT_TAC
   THENL[REPEAT STRIP_TAC
       THEN UNDISCH_TAC `CARD (t:(A->bool)->bool) = 0`
       THEN UNDISCH_TAC `FINITE (t:(A->bool)->bool)`
       THEN REWRITE_TAC[IMP_IMP; GSYM HAS_SIZE; HAS_SIZE_0]
       THEN DISCH_THEN SUBST_ALL_TAC
       THEN REWRITE_TAC[SET_RULE `UNIONS {} = {}`]
       THEN REWRITE_TAC[CARD_CLAUSES; NSUM_CLAUSES]; ALL_TAC]
   THEN GEN_TAC
   THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F2") (CONJUNCTS_THEN2 (LABEL_TAC "F3") (CONJUNCTS_THEN2 (LABEL_TAC "F4") (LABEL_TAC "F5"))))
   THEN MP_TAC (SPEC `n:num` NON_ZERO)
   THEN USE_THEN "F2" (SUBST1_TAC o SYM)
   THEN USE_THEN "F3" (fun th -> REWRITE_TAC[MATCH_MP CARD_EQ_0 th])
   THEN REWRITE_TAC[GSYM MEMBER_NOT_EMPTY]
   THEN DISCH_THEN (X_CHOOSE_THEN `u:A->bool` (LABEL_TAC "F6"))
   THEN SUBGOAL_THEN `FINITE (UNIONS (t:(A->bool)->bool))` (LABEL_TAC "F7")
   THENL[USE_THEN "F3" (fun th -> REWRITE_TAC[MATCH_MP FINITE_UNIONS th])
       THEN USE_THEN "F4" (fun th -> REWRITE_TAC[th]); ALL_TAC]
   THEN SUBGOAL_THEN `UNIONS (t:(A->bool)->bool) = (UNIONS (t DELETE (u:A->bool))) UNION u` (LABEL_TAC "F8")
   THENL[SET_TAC[]; ALL_TAC]
   THEN SUBGOAL_THEN `DISJOINT (UNIONS ((t:(A->bool)->bool) DELETE (u:A->bool))) u` (LABEL_TAC "F9")
   THENL[REWRITE_TAC[DISJOINT; INTER; EXTENSION; IN_ELIM_THM]
       THEN GEN_TAC
       THEN EQ_TAC
       THENL[REWRITE_TAC[IN_UNIONS]
	  THEN STRIP_TAC
	  THEN SUBGOAL_THEN `~(DISJOINT (u:A->bool) (t':A->bool))` ASSUME_TAC
	  THENL[REWRITE_TAC[IN_DISJOINT]
	      THEN EXISTS_TAC `x:A`
	      THEN REPLICATE_TAC 2 (POP_ASSUM (fun th -> REWRITE_TAC[th])); ALL_TAC]
          THEN UNDISCH_TAC `t':A->bool IN (t:(A->bool)->bool) DELETE (u:A->bool)`
          THEN REWRITE_TAC[IN_DELETE]
          THEN STRIP_TAC
          THEN USE_THEN "F5" (MP_TAC o SPECL[`t':A->bool`; `u:A->bool`])
          THEN REPLICATE_TAC 2 (POP_ASSUM (fun th -> REWRITE_TAC[th]))
          THEN USE_THEN "F6" (fun th -> REWRITE_TAC[th])
          THEN ONCE_REWRITE_TAC[DISJOINT_SYM]
          THEN POP_ASSUM (fun th -> REWRITE_TAC[th]); ALL_TAC]
       THEN MESON_TAC[NOT_IN_EMPTY]; ALL_TAC]
   THEN USE_THEN "F3" (MP_TAC o ISPEC `u:A->bool` o  MATCH_MP CARD_DELETE)
   THEN USE_THEN "F6" (fun th -> REWRITE_TAC[th])
   THEN REMOVE_THEN "F2" SUBST1_TAC
   THEN REWRITE_TAC[ADD1; ADD_SUB]
   THEN DISCH_TAC
   THEN FIRST_X_ASSUM (MP_TAC o SPEC`(t:(A->bool)->bool) DELETE (u:A->bool)`)
   THEN POP_ASSUM (fun th -> REWRITE_TAC[th])
   THEN USE_THEN "F3" (fun th -> REWRITE_TAC[MATCH_MP FINITE_DELETE_IMP th])
   THEN SUBGOAL_THEN `!(u':A->bool). u' IN ((t:(A->bool)->bool) DELETE (u:A->bool)) ==> FINITE u'` (fun th -> REWRITE_TAC[th])
   THENL[REWRITE_TAC[IN_DELETE]
       THEN USE_THEN "F4" (fun th -> MESON_TAC[SPEC `u':A->bool` th]); ALL_TAC]
   THEN SUBGOAL_THEN `!s1:A->bool s2:A->bool. s1 IN ((t:(A->bool)->bool) DELETE (u:A->bool)) /\ s2 IN ((t:(A->bool)->bool) DELETE (u:A->bool)) /\ ~(s1 = s2) ==> DISJOINT s1 s2` (fun th -> REWRITE_TAC[th])
   THENL[REWRITE_TAC[IN_DELETE]
       THEN REMOVE_THEN "F5" (fun th -> MESON_TAC[th]); ALL_TAC]
   THEN DISCH_TAC
   THEN SUBGOAL_THEN `CARD (UNIONS (t:(A->bool)->bool)) = CARD(UNIONS (t DELETE (u:A->bool))) + CARD (u:A->bool)` ASSUME_TAC
   THENL[USE_THEN "F8" SUBST1_TAC
       THEN MATCH_MP_TAC CARD_UNION
       THEN USE_THEN "F9" (MP_TAC o REWRITE_RULE[DISJOINT])
       THEN DISCH_THEN (fun th -> REWRITE_TAC[th])
       THEN USE_THEN "F6" (fun th -> (USE_THEN "F4" (fun ths -> REWRITE_TAC[MATCH_MP ths th])))
       THEN USE_THEN "F7" MP_TAC
       THEN USE_THEN "F8" SUBST1_TAC
       THEN REWRITE_TAC[FINITE_UNION]
       THEN SIMP_TAC[]; ALL_TAC]
   THEN USE_THEN "F3" (fun th -> (USE_THEN "F6" (fun th1 -> (MP_TAC (SPEC `(\u:A->bool. CARD u)` (MATCH_MP NSUM_DELETE  (CONJ th th1)))))))
   THEN POP_ASSUM MP_TAC
   THEN POP_ASSUM SUBST1_TAC
   THEN DISCH_THEN SUBST1_TAC
   THEN REWRITE_TAC[]
   THEN ARITH_TAC);;

let card_partition_formula = prove(`!s:A->bool p:A->A. FINITE s /\ p permutes s ==> CARD s = nsum (set_of_orbits s p) (\u:A->bool. CARD u)`,
   REPEAT GEN_TAC
   THEN DISCH_THEN (LABEL_TAC "F1")
   THEN USE_THEN "F1" (fun th -> GEN_REWRITE_TAC (LAND_CONV o ONCE_DEPTH_CONV)  [MATCH_MP lemma_partition th])
   THEN MATCH_MP_TAC lemma_card_of_disjoint_covering
   THEN USE_THEN "F1" (fun th -> REWRITE_TAC [MATCH_MP finite_orbits_lemma th])
   THEN STRIP_TAC
   THENL[GEN_TAC
       THEN REWRITE_TAC[set_of_orbits; IN_ELIM_THM]
       THEN STRIP_TAC
       THEN POP_ASSUM SUBST1_TAC
       THEN USE_THEN "F1" (fun th -> REWRITE_TAC[MATCH_MP lemma_orbit_finite th]); ALL_TAC]
   THEN REPEAT GEN_TAC
   THEN REWRITE_TAC[set_of_orbits; IN_ELIM_THM]
   THEN STRIP_TAC
   THEN POP_ASSUM MP_TAC
   THEN ASM_REWRITE_TAC[]
   THEN REWRITE_TAC[DISJOINT]
   THEN USE_THEN "F1" (MP_TAC o SPECL[`x:A`; `x':A`] o MATCH_MP partition_orbit)
   THEN MESON_TAC[]);;

let lemma_card_lower_bound = prove(`!s:A->bool p:A->A m:num. FINITE s /\ p permutes s /\ (!x:A. x IN s ==> m <= CARD(orbit_map p x)) 
   ==> (m * (number_of_orbits s p) <= CARD s)`,
   REPEAT GEN_TAC
   THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F1") (CONJUNCTS_THEN2 (LABEL_TAC "F2") (LABEL_TAC "F3")))
   THEN USE_THEN "F1" (fun th1 -> (USE_THEN "F2" (fun th2 -> (LABEL_TAC "F4" (MATCH_MP finite_orbits_lemma (CONJ th1 th2))))))
   THEN SUBGOAL_THEN `!x:(A->bool). x IN set_of_orbits s p ==> (\u:A->bool. (m:num)) x <= (\u:A->bool. CARD u) x` ASSUME_TAC
   THENL[GEN_TAC
       THEN REWRITE_TAC[set_of_orbits; IN_ELIM_THM]
       THEN STRIP_TAC
       THEN POP_ASSUM SUBST1_TAC
       THEN REMOVE_THEN "F3" (MP_TAC o SPEC `x':A`)
       THEN ASM_REWRITE_TAC[]; ALL_TAC]
   THEN USE_THEN "F4" (fun th1 -> (POP_ASSUM (fun th2 -> (MP_TAC (MATCH_MP NSUM_LE (CONJ th1 th2))))))
   THEN USE_THEN "F4" (fun th -> REWRITE_TAC[MATCH_MP NSUM_CONST th])
   THEN USE_THEN "F1" (fun th1 -> (USE_THEN "F2" (fun th2 -> REWRITE_TAC [GSYM(MATCH_MP card_partition_formula (CONJ th1 th2))])))
   THEN REWRITE_TAC[GSYM number_of_orbits]
   THEN ARITH_TAC);;

let lemma_card_eq = prove(`!(s:A->bool) p:A->A m:num. FINITE s /\ p permutes s /\ (!x:A. x IN s ==> CARD(orbit_map p x) = m) 
   ==> CARD s = m * (number_of_orbits s p)`,
   REPEAT GEN_TAC
   THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F1") (CONJUNCTS_THEN2 (LABEL_TAC "F2") (LABEL_TAC "F3" o GSYM)))
   THEN USE_THEN "F1" (fun th1 -> (USE_THEN "F2" (fun th2 -> (LABEL_TAC "F4" (MATCH_MP finite_orbits_lemma (CONJ th1 th2))))))
   THEN SUBGOAL_THEN `!x:(A->bool). x IN set_of_orbits s p ==> (\u:A->bool. (m:num)) x = (\u:A->bool. CARD u) x` ASSUME_TAC
   THENL[GEN_TAC
       THEN REWRITE_TAC[set_of_orbits; IN_ELIM_THM]
       THEN STRIP_TAC
       THEN POP_ASSUM SUBST1_TAC
       THEN REMOVE_THEN "F3" (MP_TAC o SPEC `x':A`)
       THEN ASM_REWRITE_TAC[]; ALL_TAC]
   THEN POP_ASSUM (fun th2 -> (MP_TAC (MATCH_MP NSUM_EQ th2)))	 
   THEN USE_THEN "F4" (fun th -> REWRITE_TAC[MATCH_MP NSUM_CONST th])
   THEN USE_THEN "F1" (fun th1 -> (USE_THEN "F2" (fun th2 -> REWRITE_TAC [GSYM(MATCH_MP card_partition_formula (CONJ th1 th2))])))
   THEN REWRITE_TAC[GSYM number_of_orbits]
   THEN ARITH_TAC);;

let lemma_card_atleast_one = prove(`!s:A->bool x:A. FINITE s /\ (x IN s) ==> CARD s >= 1`, 
   REPEAT STRIP_TAC
   THEN DISJ_CASES_TAC (SET_RULE`(CARD(s:A->bool) = 0) \/ ~(CARD(s) = 0)`)
   THENL[MP_TAC (ISPECL[`s:A->bool`] (CONJUNCT1 SET_SIZE_CLAUSES)) THEN ASM_REWRITE_TAC[HAS_SIZE] THEN SET_TAC[];ALL_TAC]
   THEN POP_ASSUM MP_TAC THEN ARITH_TAC);;


let lemma_card_atleast_2 = prove(`!s:A->bool. FINITE s /\ (?x:A y:A. (x IN s) /\ (y IN s) /\ ~( x = y)) ==> CARD s >= 2`,
   REPEAT STRIP_TAC THEN ASSUME_TAC(SPEC `x:A`INSERT_DELETE) THEN POP_ASSUM(MP_TAC o SPEC `s:A->bool`)
   THEN ASM_REWRITE_TAC[] THEN STRIP_TAC THEN MP_TAC(ISPECL[`s:A->bool`;`x:A`] FINITE_DELETE_IMP) THEN ASM_REWRITE_TAC[]
   THEN STRIP_TAC THEN MP_TAC(ISPECL[`x:A`;`s:A->bool DELETE x:A`] (CONJUNCT2 CARD_CLAUSES )) THEN ASM_REWRITE_TAC[]
   THEN COND_CASES_TAC THENL[SET_TAC[];ALL_TAC]
   THEN REWRITE_TAC[ARITH_RULE `SUC(CARD(s:A->bool DELETE x:A)) = CARD(s DELETE x) +1`] THEN STRIP_TAC THEN MP_TAC(ISPECL[`s:A->bool`;`y:A`;`x:A`] IN_DELETE)
   THEN ASM_REWRITE_TAC[] THEN ABBREV_TAC `t = s:A->bool DELETE x:A` THEN STRIP_TAC
   THEN ASSUME_TAC(SPEC `y:A` INSERT_DELETE) THEN POP_ASSUM(MP_TAC o SPEC `t:A->bool`) THEN ASM_REWRITE_TAC[] THEN STRIP_TAC
   THEN MP_TAC(ISPECL[`t:A->bool`;`y:A`] FINITE_DELETE_IMP) THEN ASM_REWRITE_TAC[] THEN STRIP_TAC
   THEN MP_TAC(ISPECL[`y:A`;`t:A->bool DELETE y:A`] (CONJUNCT2 CARD_CLAUSES )) THEN ASM_REWRITE_TAC[]
   THEN COND_CASES_TAC THENL[SET_TAC[];ALL_TAC]
   THEN REWRITE_TAC[ARITH_RULE `SUC(CARD(t:A->bool DELETE y:A)) = CARD(t DELETE y) +1`]
   THEN STRIP_TAC THEN ASM_REWRITE_TAC[ARITH] THEN ARITH_TAC);;

let lemma_nondegenerate_convolution = prove(`!s:A->bool p:A->A. FINITE s /\ p permutes s /\ p o p = I /\ 
   (!x:A. x IN s ==> ~(p x = x)) ==> (!x:A. x IN s ==> FINITE (orbit_map p x) /\ CARD(orbit_map p x) = 2)`,
REPEAT GEN_TAC THEN DISCH_THEN(CONJUNCTS_THEN2 (LABEL_TAC "F1") (CONJUNCTS_THEN2 (LABEL_TAC "F2")(CONJUNCTS_THEN2 (LABEL_TAC "F3")(LABEL_TAC "F4"))))
  THEN GEN_TAC THEN (DISCH_THEN(LABEL_TAC "F5")) THEN USE_THEN "F2"(MP_TAC o SPEC `x:A` o MATCH_MP orbit_subset) THEN ASM_REWRITE_TAC[]
  THEN DISCH_THEN (LABEL_TAC "F6") THEN 
  USE_THEN "F1"(fun th1 -> (USE_THEN "F6"(fun th2 -> (MP_TAC(MATCH_MP FINITE_SUBSET (CONJ th1 th2))))))
  THEN DISCH_THEN(LABEL_TAC "F7") THEN ASM_REWRITE_TAC[] THEN MP_TAC(ISPECL[`p:A->A`;`2`;`x:A`] card_orbit_le)
  THEN ASM_REWRITE_TAC[ARITH; SPEC `(p:A->A)` POWER_2;I_THM] THEN DISCH_THEN(LABEL_TAC "F8")
  THEN MP_TAC(ISPECL[`p:A->A`;`1`; `x:A`; `(p:A->A) (x:A)`] in_orbit_lemma) THEN REWRITE_TAC[POWER_1]
  THEN DISCH_THEN(LABEL_TAC "F9") THEN LABEL_TAC "F10" (ISPECL[`p:A->A`;`x:A`] orbit_reflect)
  THEN USE_THEN "F1"(fun th1 -> (USE_THEN "F6" (fun th2 -> LABEL_TAC "F11" (MATCH_MP FINITE_SUBSET (CONJ th1 th2) ))))
  THEN SUBGOAL_THEN `?u:A v:A. u IN orbit_map (p:A->A) (x:A) /\ v IN orbit_map p x /\ ~(u = v)` (LABEL_TAC "F12")
  THENL[EXISTS_TAC `(p:A->A) (x:A)` THEN EXISTS_TAC `x:A` THEN ASM_SIMP_TAC[];ALL_TAC]
  THEN USE_THEN "F11"(fun th1 -> USE_THEN "F12"(fun th2 -> MP_TAC(MATCH_MP lemma_card_atleast_2 (CONJ th1 th2))))
  THEN USE_THEN "F8"(MP_TAC) THEN ARITH_TAC);;

let lemmaTGJISOK = prove(`!H:(A)hypermap. connected_hypermap H /\ plain_hypermap H /\ planar_hypermap H /\
   (!x:A. x IN (dart H) ==> ~(edge_map H x = x) /\ (3 <= CARD(node H x))) 
   ==> (CARD (dart H) <= (6*(number_of_faces H)-12))`,

   GEN_TAC THEN REWRITE_TAC[connected_hypermap; plain_hypermap; planar_hypermap]
   THEN DISCH_THEN(CONJUNCTS_THEN2 (ASSUME_TAC) (MP_TAC )) THEN POP_ASSUM SUBST1_TAC THEN SIMP_TAC[ARITH]
   THEN DISCH_THEN(CONJUNCTS_THEN2 (LABEL_TAC "F1") (CONJUNCTS_THEN2 (LABEL_TAC "F2") (LABEL_TAC "F3")))
   THEN SUBGOAL_THEN `!x:A. x IN dart (H:(A)hypermap) ==> CARD (edge H x) = 2` MP_TAC
   THENL[MP_TAC(SPECL[`dart (H:(A)hypermap)`; `edge_map (H:(A)hypermap)`] lemma_nondegenerate_convolution)
       THEN REWRITE_TAC[edge_map_and_darts; GSYM edge]
       THEN ASM_SIMP_TAC[]; ALL_TAC]
   THEN REWRITE_TAC[edge]
   THEN DISCH_THEN (fun th -> (MP_TAC (MATCH_MP lemma_card_eq(REWRITE_RULE[GSYM CONJ_ASSOC] (CONJ (SPEC `H:(A)hypermap` edge_map_and_darts) th)))))
   THEN GEN_REWRITE_TAC (LAND_CONV o DEPTH_CONV) [number_of_orbits]
   THEN REWRITE_TAC[GSYM edge_set; GSYM number_of_edges]
   THEN DISCH_THEN (LABEL_TAC "F4")
   THEN SUBGOAL_THEN `!x:A. x IN dart (H:(A)hypermap) ==> 3 <= CARD (node H x)` MP_TAC
   THENL[ASM_SIMP_TAC[]; ALL_TAC]
   THEN REWRITE_TAC[node]
   THEN DISCH_THEN (fun th->(MP_TAC (MATCH_MP lemma_card_lower_bound(REWRITE_RULE[GSYM CONJ_ASSOC] (CONJ (SPEC `H:(A)hypermap` node_map_and_darts) th)))))
   THEN GEN_REWRITE_TAC (LAND_CONV o DEPTH_CONV) [number_of_orbits]
   THEN REWRITE_TAC[GSYM node_set; GSYM number_of_nodes]
   THEN DISCH_TAC
   THEN REMOVE_THEN "F2" MP_TAC
   THEN POP_ASSUM MP_TAC
   THEN REMOVE_THEN "F4" SUBST1_TAC
   THEN ARITH_TAC);;

(* We set up some lemmas on combinatorial commponents *)

let lemma_subpath = prove(`!H:(A)hypermap p:num->A n:num. is_path H p n ==> (!i. i <= n ==> is_path H p i)`,
   REPLICATE_TAC 2 GEN_TAC THEN INDUCT_TAC THENL[ SIMP_TAC[is_path; ARITH_RULE `i <= 0 ==> i = 0`]; ALL_TAC] 
   THEN STRIP_TAC THEN GEN_TAC THEN REWRITE_TAC[ARITH_RULE `i<=SUC n <=> i = SUC n \/ i <= n`] THEN STRIP_TAC  
   THENL[ASM_REWRITE_TAC[]; UNDISCH_TAC `is_path (H:(A)hypermap) (p:num->A) (SUC n)` THEN ASM_REWRITE_TAC[is_path] THEN ASM_MESON_TAC[]]);;

let lemm_path_subset = prove(`!H:(A)hypermap x:A p:num->A n:num. (x IN dart H) /\ (p 0 = x) /\ (is_path H p n) ==> p n IN dart H`, 
   REPLICATE_TAC 3 GEN_TAC THEN INDUCT_TAC THENL[SIMP_TAC[is_path;go_one_step];ALL_TAC] THEN POP_ASSUM(LABEL_TAC "F1") 
   THEN STRIP_TAC THEN POP_ASSUM(fun th -> (MP_TAC(MATCH_MP lemma_subpath th) THEN LABEL_TAC "F2" th)) 
   THEN REWRITE_TAC[LEFT_AND_FORALL_THM] THEN DISCH_THEN(MP_TAC o SPEC `n:num`) 
   THEN REWRITE_TAC[ARITH_RULE `n <= SUC n`] THEN  STRIP_TAC 
   THEN REMOVE_THEN "F1" MP_TAC THEN ASM_REWRITE_TAC[] THEN STRIP_TAC 
   THEN REMOVE_THEN "F2" MP_TAC THEN ASM_REWRITE_TAC[is_path;go_one_step] 
   THEN STRIP_ASSUME_TAC(SPEC `H:(A)hypermap` hypermap_lemma) THEN ASM_REWRITE_TAC[] 
   THEN STRIP_ASSUME_TAC(SPEC `H:(A)hypermap` hypermap_lemma) 
   THEN ABBREV_TAC `D = dart (H:(A)hypermap)` 
   THEN ABBREV_TAC `e = edge_map (H:(A)hypermap)` 
   THEN ABBREV_TAC `nn = node_map (H:(A)hypermap)` 
   THEN ABBREV_TAC `f = face_map (H:(A)hypermap)`
   THEN ABBREV_TAC `u = (p:num->A) (SUC n)` 
   THEN ABBREV_TAC `v = (p:num->A) n` 
   THEN MP_TAC(ISPECL[`e:A->A`; `D:A->bool`; `v:A`] PERMUTES_IN_IMAGE) 
   THEN ASM_REWRITE_TAC[] THEN MP_TAC(ISPECL[`nn:A->A`; `D:A->bool`; `v:A`] PERMUTES_IN_IMAGE) 
   THEN ASM_REWRITE_TAC[] THEN MP_TAC(ISPECL[`f:A->A`; `D:A->bool`; `v:A`] PERMUTES_IN_IMAGE) 
   THEN ASM_REWRITE_TAC[] THEN MESON_TAC[]);;

let lemma_component_subset = prove(`!H:(A)hypermap x:A. x IN dart H ==> comb_component H x SUBSET dart H`, 
   REPEAT STRIP_TAC THEN STRIP_ASSUME_TAC(SPEC `H:(A)hypermap` hypermap_lemma) 
   THEN REWRITE_TAC[SUBSET;IN_ELIM_THM;comb_component] 
   THEN GEN_TAC THEN REWRITE_TAC[is_in_component] THEN ASM_MESON_TAC[lemm_path_subset]);;

let lemma_edge_subset = prove(`!(H:(A)hypermap) x:A. x IN dart H ==> edge H x SUBSET dart H`, 
   REWRITE_TAC[edge] THEN MESON_TAC[edge_map_and_darts; orbit_subset]);;

let lemma_node_subset = prove(`!(H:(A)hypermap) x:A. x IN dart H ==> node H x SUBSET dart H`, 
   REWRITE_TAC[node] THEN MESON_TAC[ node_map_and_darts; orbit_subset]);;

let lemma_face_subset = prove(`!(H:(A)hypermap) x:A. x IN dart H ==> face H x SUBSET dart H`, 
   REWRITE_TAC[face] THEN MESON_TAC[face_map_and_darts; orbit_subset]);;

let lemma_component_reflect = prove(`!H:(A)hypermap x:A. x IN comb_component H x`, 
   REPEAT STRIP_TAC THEN REWRITE_TAC[IN_ELIM_THM; comb_component;is_in_component] 
   THEN EXISTS_TAC `(\k:num. x:A)` THEN EXISTS_TAC `0` THEN MESON_TAC[is_path]);;

(* The definition of path is exactly here *)

let lemma_def_path = prove(`!H:(A)hypermap p:num->A n:num.(is_path H p n <=> (!i:num. i < n ==> go_one_step H (p i) (p (SUC i))))`, 
   REPLICATE_TAC 2 GEN_TAC THEN INDUCT_TAC 
   THENL[REWRITE_TAC[is_path] THEN ARITH_TAC; ALL_TAC] 
   THEN ASM_REWRITE_TAC[is_path] THEN EQ_TAC THENL[STRIP_TAC THEN  GEN_TAC 
   THEN REWRITE_TAC[ARITH_RULE `i<SUC n <=> i = n \/ i < n`] THEN ASM_MESON_TAC[]; ALL_TAC] 
   THEN REWRITE_TAC[ARITH_RULE `i<SUC n <=> i = n \/ i < n`] THEN STRIP_TAC 
   THEN ASM_MESON_TAC[ARITH_RULE `n < SUC n /\ i < SUC n <=> (i = n \/ i < n)`]);;


(* Three special paths *)

let edge_path = new_definition `!(H:(A)hypermap) (x:A) (i:num). edge_path H x i  = ((edge_map H) POWER i) x`;;

let node_path = new_definition `!(H:(A)hypermap) (x:A) (i:num). node_path H x i  = ((node_map H) POWER i) x`;;

let face_path = new_definition `!(H:(A)hypermap) (x:A) (i:num). face_path H x i  = ((face_map H) POWER i) x`;;

let lemma_edge_path = prove(`!(H:(A)hypermap) (x:A) k:num. is_path H (edge_path H x) k`,
   REPLICATE_TAC 2 GEN_TAC
     THEN INDUCT_TAC THENL[REWRITE_TAC[is_path]; ALL_TAC]
     THEN REWRITE_TAC[is_path]
     THEN ASM_REWRITE_TAC[]
     THEN REWRITE_TAC[go_one_step]
     THEN DISJ1_TAC THEN REWRITE_TAC[edge_path; COM_POWER; o_THM]);;

let lemma_node_path = prove(`!(H:(A)hypermap) (x:A) k:num. is_path H (node_path H x) k`,
   REPLICATE_TAC 2 GEN_TAC
     THEN INDUCT_TAC THENL[REWRITE_TAC[is_path]; ALL_TAC]
     THEN REWRITE_TAC[is_path]
     THEN ASM_REWRITE_TAC[]
     THEN REWRITE_TAC[go_one_step]
     THEN DISJ2_TAC THEN DISJ1_TAC THEN REWRITE_TAC[node_path; COM_POWER; o_THM]);;

let lemma_face_path = prove(`!(H:(A)hypermap) (x:A) k:num. is_path H (face_path H x) k`,
   REPLICATE_TAC 2 GEN_TAC
     THEN INDUCT_TAC THENL[REWRITE_TAC[is_path]; ALL_TAC]
     THEN REWRITE_TAC[is_path]
     THEN ASM_REWRITE_TAC[]
     THEN REWRITE_TAC[go_one_step]
     THEN DISJ2_TAC THEN DISJ2_TAC  THEN REWRITE_TAC[face_path; COM_POWER; o_THM]);;


(* some lemmas on concatenate paths *)

let identify_path = prove(`!(H:(A)hypermap) p:num->A q:num->A n:num. is_path H p n /\ (!i:num. i<= n ==> p i = q i) ==> is_path H q n`,
   REPLICATE_TAC 3 GEN_TAC
   THEN INDUCT_TAC THENL[REWRITE_TAC[is_path]; ALL_TAC]
   THEN POP_ASSUM (LABEL_TAC "F1")
   THEN DISCH_THEN (CONJUNCTS_THEN2 MP_TAC (LABEL_TAC "F2"))
   THEN REWRITE_TAC[is_path]
   THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F3") (LABEL_TAC "F4"))
   THEN SUBGOAL_THEN `!i:num. i <= n:num ==> (p:num->A) i = (q:num->A) i` ASSUME_TAC
   THENL[REPEAT STRIP_TAC
      THEN USE_THEN "F2" (MP_TAC o SPEC `i:num`)
      THEN MP_TAC (MATCH_MP LT_IMP_LE (SPEC `n:num` LT_PLUS))
      THEN POP_ASSUM (fun th -> (DISCH_THEN (fun th1 -> REWRITE_TAC[MATCH_MP LE_TRANS (CONJ th th1)]))); ALL_TAC]
   THEN REMOVE_THEN "F1" MP_TAC
   THEN ASM_REWRITE_TAC[]
   THEN DISCH_THEN (fun th -> REWRITE_TAC[th])
   THEN POP_ASSUM (MP_TAC o SPEC `n:num`)
   THEN REWRITE_TAC[LE_REFL]
   THEN DISCH_THEN (SUBST1_TAC o SYM)
   THEN REMOVE_THEN "F2" (MP_TAC o SPEC `SUC n`)
   THEN REWRITE_TAC[LE_REFL]
   THEN DISCH_THEN (SUBST1_TAC o SYM)
   THEN ASM_REWRITE_TAC[]);;

let concatenate_two_paths = prove(`!H:(A)hypermap p:num->A q:num->A n:num m:num. is_path H p n /\ is_path H q m /\ (p n = q 0) 
==> ?g:num->A. g 0 = p 0 /\ g (n+m) = q m /\ is_path H g (n+m) /\ (!i:num. i <= n ==> g i = p i) /\ (!i:num. i <= m ==> g (n+i) = q i)`,
   REPLICATE_TAC 4 GEN_TAC
   THEN INDUCT_TAC
   THENL[ REPEAT STRIP_TAC THEN EXISTS_TAC `p:num->A`
        THEN ASM_REWRITE_TAC[ADD_0; LE]
        THEN GEN_TAC
        THEN DISCH_THEN SUBST1_TAC
        THEN ASM_REWRITE_TAC[ADD_0]; ALL_TAC]
   THEN POP_ASSUM (LABEL_TAC "F1")
   THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F2")(CONJUNCTS_THEN2 (LABEL_TAC "F3") (LABEL_TAC "F4")))
   THEN USE_THEN "F3" (MP_TAC o SPEC `m:num` o MATCH_MP lemma_subpath)
   THEN SIMP_TAC [ARITH_RULE `m <= SUC m`]
   THEN DISCH_THEN (LABEL_TAC "F5") THEN REMOVE_THEN "F1" MP_TAC
   THEN ASM_REWRITE_TAC[]
   THEN DISCH_THEN(X_CHOOSE_THEN `h:num->A` (LABEL_TAC "F6"))
   THEN EXISTS_TAC `(\k:num. if k = (n:num) + (SUC (m:num)) then (q:num->A) (SUC m) else (h:num->A) k)`
   THEN ASM_REWRITE_TAC[ARITH_RULE `~((n:num)+SUC m = 0)`]
   THEN STRIP_TAC
   THENL[REWRITE_TAC [ADD_SUC]
       THEN ABBREV_TAC `t = (\k:num. if k = SUC ((n:num)+(m:num)) then (q:num->A) (SUC m) else (h:num->A) k)`
       THEN SUBGOAL_THEN `!i:num. i <= (n:num) + (m:num) ==> (h:num->A) i = (t:num->A) i` (LABEL_TAC "FA")
       THENL[REPEAT  STRIP_TAC THEN MP_TAC(ARITH_RULE `(i:num) <= (n:num)+(m:num) ==> ~(i = SUC (n+m))`)
	       THEN POP_ASSUM (fun th -> REWRITE_TAC[th])
	       THEN STRIP_TAC THEN EXPAND_TAC "t"
	       THEN POP_ASSUM (fun th -> REWRITE_TAC[th; COND_ELIM_THM]); ALL_TAC]
       THEN SUBGOAL_THEN `(t:num->A) (SUC((n:num) + (m:num))) = (q:num->A) (SUC m)` ASSUME_TAC
       THENL[EXPAND_TAC "t" THEN REWRITE_TAC[COND_ELIM_THM]; ALL_TAC]     
       THEN MP_TAC(SPECL[`H:(A)hypermap`; `h:num->A`;`t:num->A`;`(n:num)+(m:num)` ] identify_path)
       THEN USE_THEN "FA" (fun th -> SIMP_TAC[th])
       THEN USE_THEN "F6" (fun th -> REWRITE_TAC[th])
       THEN REWRITE_TAC[is_path]
       THEN DISCH_THEN (fun th -> REWRITE_TAC[th])
       THEN REMOVE_THEN "FA" (MP_TAC o SPEC `(n:num) + (m:num)`)
       THEN REWRITE_TAC[LE_REFL]
       THEN POP_ASSUM SUBST1_TAC
       THEN DISCH_THEN (SUBST1_TAC o SYM)
       THEN REMOVE_THEN "F6" (MP_TAC o SPEC `m:num` o CONJUNCT2 o CONJUNCT2 o CONJUNCT2 o CONJUNCT2)
       THEN REWRITE_TAC[LE_REFL]
       THEN DISCH_THEN SUBST1_TAC
       THEN REMOVE_THEN "F3" (fun th -> MESON_TAC[th; is_path]); ALL_TAC]
    THEN STRIP_TAC
    THENL[GEN_TAC
       THEN DISCH_THEN (fun th -> (REWRITE_TAC[MATCH_MP (ARITH_RULE `i:num <= n ==> ~(i = n + SUC m)`) th; COND_ELIM_THM]) THEN MP_TAC th)
       THEN USE_THEN "F6" (fun th -> REWRITE_TAC[CONJUNCT1(CONJUNCT2(CONJUNCT2(CONJUNCT2 th)))]); ALL_TAC] 
    THEN REPEAT STRIP_TAC
    THEN ASM_CASES_TAC `i:num  = SUC m`
    THENL[POP_ASSUM SUBST1_TAC THEN REWRITE_TAC[COND_ELIM_THM]; ALL_TAC]
    THEN POP_ASSUM (fun th -> (REWRITE_TAC[COND_ELIM_THM; MATCH_MP (ARITH_RULE `~(i:num = SUC m) ==> ~((n:num) + i = n + SUC m)`) th] THEN ASSUME_TAC th))
    THEN USE_THEN "F6" (fun th -> MP_TAC (SPEC `i:num` (CONJUNCT2(CONJUNCT2(CONJUNCT2(CONJUNCT2 th))))))
    THEN POP_ASSUM (fun th1 -> (POP_ASSUM (fun th2 -> (REWRITE_TAC[MATCH_MP (ARITH_RULE `~(i:num = SUC m) /\ (i <= SUC m) ==> i <= m`) (CONJ th1 th2)]))))
);;

let concatenate_paths = prove(`!H:(A)hypermap p:num->A q:num->A n:num m:num. is_path H p n /\ is_path H q m /\ (p n = q 0) 
   ==> ?g:num->A. g 0 = p 0 /\ g (n+m) = q m /\ is_path H g (n+m)`,
   REPEAT GEN_TAC
   THEN DISCH_THEN (MP_TAC o MATCH_MP concatenate_two_paths)
   THEN MESON_TAC[]);;

let lemma_component_trans = prove(`!H:(A)hypermap x:A y:A z:A. y IN comb_component H x /\ z IN comb_component H y 
   ==> z IN comb_component H x`, 
   REPEAT GEN_TAC THEN REWRITE_TAC[IN_ELIM_THM; comb_component; is_in_component] 
   THEN REPEAT STRIP_TAC 
   THEN MP_TAC(ISPECL[`H:(A)hypermap`; `p:num->A`;`p':num->A`;`n:num`;`n':num`] concatenate_paths) 
   THEN ASM_REWRITE_TAC[] THEN MESON_TAC[]);;

let lemma_reverse_path = prove(`!H:(A)hypermap p:num->A n:num. is_path H p n ==> ?q:num->A m:num. q 0 = p n /\ q m = p 0 /\ is_path H q m`,
   REPLICATE_TAC 2 GEN_TAC
   THEN INDUCT_TAC
   THENL[REWRITE_TAC[is_path]
       THEN EXISTS_TAC `p:num->A` THEN EXISTS_TAC `0`
       THEN REWRITE_TAC[is_path]; ALL_TAC]
   THEN REWRITE_TAC[is_path]
   THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F1") (LABEL_TAC "F2"))
   THEN FIRST_X_ASSUM (MP_TAC o check (is_imp o concl))
   THEN REMOVE_THEN "F1" (fun th -> REWRITE_TAC[th])
   THEN DISCH_THEN (X_CHOOSE_THEN `g:num->A` (X_CHOOSE_THEN `m:num` (CONJUNCTS_THEN2 (LABEL_TAC "F3") (CONJUNCTS_THEN2 (LABEL_TAC "F4") (LABEL_TAC "F5")))))
   THEN USE_THEN "F2" MP_TAC
   THEN REWRITE_TAC[go_one_step]
   THEN STRIP_TAC
   THENL[MP_TAC (SPEC `H:(A)hypermap` hypermap_lemma)
      THEN DISCH_THEN (fun th-> (POP_ASSUM (fun th1 -> (MP_TAC (MATCH_MP inverse_relation (CONJ (CONJUNCT1 th) (CONJ (CONJUNCT1(CONJUNCT2 th)) th1)))))))
      THEN DISCH_THEN (X_CHOOSE_THEN `k:num` MP_TAC)
      THEN REWRITE_TAC[GSYM edge_path]
      THEN USE_THEN "F3" (SUBST1_TAC o SYM)
      THEN USE_THEN "F5" (fun th1 -> (DISCH_THEN (fun th ->  (MP_TAC (MATCH_MP concatenate_two_paths (CONJ (SPECL[`H:(A)hypermap`; `(p:num->A) (SUC n)`; `k:num`] lemma_edge_path) (CONJ th1 (SYM th))))))))
      THEN STRIP_TAC
      THEN EXISTS_TAC `g':num->A`
      THEN EXISTS_TAC `(k:num) + (m:num)`
      THEN ASM_REWRITE_TAC[edge_path; POWER_0; I_THM];
    MP_TAC (SPEC `H:(A)hypermap` hypermap_lemma)
      THEN DISCH_THEN (fun th-> (POP_ASSUM (fun th1 -> (MP_TAC (MATCH_MP inverse_relation (CONJ (CONJUNCT1 th) (CONJ (CONJUNCT1(CONJUNCT2(CONJUNCT2 th))) th1)))))))
      THEN DISCH_THEN (X_CHOOSE_THEN `k:num` MP_TAC)
      THEN REWRITE_TAC[GSYM node_path]
      THEN USE_THEN "F3" (SUBST1_TAC o SYM)
      THEN USE_THEN "F5" (fun th1 -> (DISCH_THEN (fun th ->  (MP_TAC (MATCH_MP concatenate_two_paths (CONJ (SPECL[`H:(A)hypermap`; `(p:num->A) (SUC n)`; `k:num`] lemma_node_path) (CONJ th1 (SYM th))))))))
      THEN STRIP_TAC
      THEN EXISTS_TAC `g':num->A`
      THEN EXISTS_TAC `(k:num) + (m:num)`
      THEN ASM_REWRITE_TAC[node_path; POWER_0; I_THM]; ALL_TAC]
   THEN MP_TAC (SPEC `H:(A)hypermap` hypermap_lemma)
   THEN DISCH_THEN (fun th-> (POP_ASSUM (fun th1 -> (MP_TAC (MATCH_MP inverse_relation (CONJ (CONJUNCT1 th) (CONJ (CONJUNCT1(CONJUNCT2(CONJUNCT2(CONJUNCT2 th)))) th1)))))))
   THEN DISCH_THEN (X_CHOOSE_THEN `k:num` MP_TAC)
   THEN REWRITE_TAC[GSYM face_path]
   THEN USE_THEN "F3" (SUBST1_TAC o SYM)
   THEN USE_THEN "F5" (fun th1 -> (DISCH_THEN (fun th ->  (MP_TAC (MATCH_MP concatenate_two_paths (CONJ (SPECL[`H:(A)hypermap`; `(p:num->A) (SUC n)`; `k:num`] lemma_face_path) (CONJ th1 (SYM th))))))))
   THEN STRIP_TAC
   THEN EXISTS_TAC `g':num->A`
   THEN EXISTS_TAC `(k:num) + (m:num)`
   THEN ASM_REWRITE_TAC[face_path; POWER_0; I_THM]);;

let lemma_component_symmetry = prove(`!H:(A)hypermap x:A y:A. y IN comb_component H x 
   ==> x IN comb_component H y`,
   REPEAT GEN_TAC THEN REWRITE_TAC[IN_ELIM_THM; comb_component; is_in_component] 
   THEN REPEAT STRIP_TAC THEN POP_ASSUM (MP_TAC o MATCH_MP lemma_reverse_path) 
   THEN ASM_REWRITE_TAC[]);;

let partition_components = prove(`!(H:(A)hypermap) x:A y:A. 
   comb_component H x = comb_component H y \/ comb_component H x INTER comb_component H y ={}`, 
   REPEAT GEN_TAC THEN ASM_CASES_TAC `comb_component (H:(A)hypermap) (x:A) INTER comb_component H (y:A) ={}` 
   THEN ASM_REWRITE_TAC[] THEN POP_ASSUM MP_TAC THEN REWRITE_TAC[GSYM MEMBER_NOT_EMPTY] 
   THEN DISCH_THEN (X_CHOOSE_THEN `t:A` MP_TAC) THEN REWRITE_TAC[INTER; IN_ELIM_THM] 
   THEN DISCH_THEN(CONJUNCTS_THEN2 (LABEL_TAC "F1") (LABEL_TAC "F2")) THEN REWRITE_TAC[EXTENSION] 
   THEN GEN_TAC THEN  EQ_TAC THENL[USE_THEN "F1" (LABEL_TAC "F3"  o MATCH_MP lemma_component_symmetry) 
   THEN DISCH_THEN (LABEL_TAC "F4") 
   THEN REMOVE_THEN "F4"(fun th1 -> REMOVE_THEN "F3" (fun th2 -> MP_TAC (MATCH_MP lemma_component_trans (CONJ th2 th1)))) 
   THEN DISCH_THEN(fun th1 -> (REMOVE_THEN "F2" (fun th2 -> MP_TAC (MATCH_MP lemma_component_trans (CONJ th2 th1))))) THEN REWRITE_TAC[];ALL_TAC] 
   THEN USE_THEN "F2" (LABEL_TAC "F5"  o MATCH_MP lemma_component_symmetry) 
   THEN DISCH_THEN (LABEL_TAC "F6") 
   THEN REMOVE_THEN "F6"(fun th1 -> REMOVE_THEN "F5" (fun th2 -> MP_TAC (MATCH_MP lemma_component_trans (CONJ th2 th1)))) 
   THEN DISCH_THEN(fun th1 -> (REMOVE_THEN "F1" (fun th2 -> MP_TAC (MATCH_MP lemma_component_trans (CONJ th2 th1))))) 
   THEN REWRITE_TAC[]);;

let lemma_partition_by_components = prove(`!(H:(A)hypermap). dart H = UNIONS (set_of_components H)`,
  GEN_TAC THEN REWRITE_TAC[set_of_components; set_part_components; EXTENSION; IN_UNIONS]
  THEN GEN_TAC THEN EQ_TAC
  THENL[STRIP_TAC
	  THEN REWRITE_TAC[IN_ELIM_THM]
	  THEN MP_TAC (SPECL[`H:(A)hypermap`;`x:A`] lemma_component_reflect)
	  THEN ASM_REWRITE_TAC[]
	  THEN STRIP_TAC
	  THEN EXISTS_TAC `comb_component (H:(A)hypermap) (x:A)`
	  THEN ASM_REWRITE_TAC[]
	  THEN EXISTS_TAC `x:A` THEN ASM_REWRITE_TAC[]; ALL_TAC]
  THEN REWRITE_TAC[IN_ELIM_THM] THEN STRIP_TAC
  THEN FIRST_ASSUM (MP_TAC o MATCH_MP lemma_component_subset) THEN SET_TAC[]);;

(* We define the CONTOUR PATHS *)

let one_step_contour = new_definition `one_step_contour (H:(A)hypermap) (x:A) (y:A) <=> (y = (face_map H) x) \/ (y = (inverse (node_map H)) x)`;;

let is_contour = new_recursive_definition num_RECURSION  `(is_contour (H:(A)hypermap) (p:num->A) 0 <=> T)/\
            (is_contour (H:(A)hypermap) (p:num->A) (SUC n) <=> ((is_contour H p n) /\ one_step_contour H (p n) (p (SUC n))))`;; 

let lemma_subcontour = prove(`!H:(A)hypermap p:num->A n:num. is_contour H p n ==> (!i. i <= n ==> is_contour H p i)`,
   REPLICATE_TAC 2 GEN_TAC THEN INDUCT_TAC 
   THENL[SIMP_TAC[is_contour; ARITH_RULE `i <= 0 ==> i = 0`]; ALL_TAC] 
   THEN STRIP_TAC THEN GEN_TAC THEN REWRITE_TAC[ARITH_RULE `i<=SUC n <=> i = SUC n \/ i <= n`] 
   THEN STRIP_TAC 
   THENL[ASM_REWRITE_TAC[]; 
   UNDISCH_TAC `is_contour (H:(A)hypermap) (p:num->A) (SUC n)` THEN ASM_REWRITE_TAC[is_contour] THEN ASM_MESON_TAC[]]);;

let lemma_def_contour = prove(`!H:(A)hypermap p:num->A n:num.(is_contour H p n <=> (!i:num. i < n ==> one_step_contour H (p i) (p (SUC i))))`, 
   REPLICATE_TAC 2 GEN_TAC THEN INDUCT_TAC 
   THENL[REWRITE_TAC[is_contour] THEN ARITH_TAC; ALL_TAC] 
   THEN ASM_REWRITE_TAC[is_contour] THEN EQ_TAC 
   THENL[STRIP_TAC THEN  GEN_TAC THEN REWRITE_TAC[ARITH_RULE `i<SUC n <=> i = n \/ i < n`] THEN ASM_MESON_TAC[]; ALL_TAC] 
   THEN REWRITE_TAC[ARITH_RULE `i<SUC n <=> i = n \/ i < n`] 
   THEN STRIP_TAC 
   THEN ASM_MESON_TAC[ARITH_RULE `n < SUC n /\ i < SUC n <=> (i = n \/ i < n)`]);;

let identify_contour = prove(`!(H:(A)hypermap) p:num->A q:num->A n:num. is_contour H p n /\ (!i:num. i<= n ==> p i = q i) ==> is_contour H q n`,
   REPLICATE_TAC 3 GEN_TAC THEN INDUCT_TAC 
   THENL[STRIP_TAC THEN REWRITE_TAC[is_contour]; ALL_TAC] 
   THEN POP_ASSUM (LABEL_TAC "F1") 
   THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F2") (LABEL_TAC "F3")) 
   THEN REMOVE_THEN "F2" MP_TAC THEN GEN_REWRITE_TAC (LAND_CONV o ONCE_DEPTH_CONV) [is_contour] 
   THEN STRIP_TAC THEN REMOVE_THEN "F1" MP_TAC THEN ASM_REWRITE_TAC[] 
   THEN SUBGOAL_THEN `!i:num. i <= (n:num) ==> (p:num->A) i = (q:num->A) i` ASSUME_TAC 
   THENL[REPEAT STRIP_TAC THEN MP_TAC(ARITH_RULE `i:num <= n:num ==> i <= SUC n`) THEN ASM_REWRITE_TAC[]; ALL_TAC] 
   THEN ASM_REWRITE_TAC[] THEN STRIP_TAC THEN ASM_REWRITE_TAC[is_contour] 
   THEN SUBGOAL_THEN `(p:num->A) (n:num) = (q:num->A) (n:num)` ASSUME_TAC 
   THENL[ASM_MESON_TAC[ARITH_RULE `n <= SUC n`];ALL_TAC] 
   THEN SUBGOAL_THEN `(p:num->A) (SUC(n:num)) = (q:num->A) (SUC(n:num))` ASSUME_TAC 
   THENL[ASM_MESON_TAC[ARITH_RULE `SUC n <= SUC n`];ALL_TAC] 
   THEN UNDISCH_THEN `one_step_contour (H:(A)hypermap) ((p:num->A) (n:num)) ((p:num->A) (SUC n:num))` MP_TAC 
   THEN ASM_REWRITE_TAC[]);;

let concatenate_contours = prove(`!H:(A)hypermap p:num->A q:num->A n:num m:num. is_contour H p n /\ is_contour  H q m /\ (p n = q 0) 
==> ?g:num->A. g 0 = p 0 /\ g (n+m) = q m /\ is_contour H g (n+m) /\ (!i:num. i <= n ==> g i = p i) /\ (!i:num. i <= m ==> g (n+i) = q i)`,
   REPLICATE_TAC 4 GEN_TAC
   THEN INDUCT_TAC
   THENL[ REPEAT STRIP_TAC THEN EXISTS_TAC `p:num->A`
        THEN ASM_REWRITE_TAC[ADD_0; LE]
        THEN GEN_TAC
        THEN DISCH_THEN SUBST1_TAC
        THEN ASM_REWRITE_TAC[ADD_0]; ALL_TAC]
   THEN POP_ASSUM (LABEL_TAC "F1")
   THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F2")(CONJUNCTS_THEN2 (LABEL_TAC "F3") (LABEL_TAC "F4")))
   THEN USE_THEN "F3" (MP_TAC o SPEC `m:num` o MATCH_MP lemma_subcontour)
   THEN SIMP_TAC [ARITH_RULE `m <= SUC m`]
   THEN DISCH_THEN (LABEL_TAC "F5") THEN REMOVE_THEN "F1" MP_TAC
   THEN ASM_REWRITE_TAC[]
   THEN DISCH_THEN(X_CHOOSE_THEN `h:num->A` (LABEL_TAC "F6"))
   THEN EXISTS_TAC `(\k:num. if k = (n:num) + (SUC (m:num)) then (q:num->A) (SUC m) else (h:num->A) k)`
   THEN ASM_REWRITE_TAC[ARITH_RULE `~((n:num)+SUC m = 0)`]
   THEN STRIP_TAC
   THENL[REWRITE_TAC [ADD_SUC]
       THEN ABBREV_TAC `t = (\k:num. if k = SUC ((n:num)+(m:num)) then (q:num->A) (SUC m) else (h:num->A) k)`
       THEN SUBGOAL_THEN `!i:num. i <= (n:num) + (m:num) ==> (h:num->A) i = (t:num->A) i` (LABEL_TAC "FA")
       THENL[REPEAT  STRIP_TAC THEN MP_TAC(ARITH_RULE `(i:num) <= (n:num)+(m:num) ==> ~(i = SUC (n+m))`)
	       THEN POP_ASSUM (fun th -> REWRITE_TAC[th])
	       THEN STRIP_TAC THEN EXPAND_TAC "t"
	       THEN POP_ASSUM (fun th -> REWRITE_TAC[th; COND_ELIM_THM]); ALL_TAC]
       THEN SUBGOAL_THEN `(t:num->A) (SUC((n:num) + (m:num))) = (q:num->A) (SUC m)` ASSUME_TAC
       THENL[EXPAND_TAC "t" THEN REWRITE_TAC[COND_ELIM_THM]; ALL_TAC]     
       THEN MP_TAC(SPECL[`H:(A)hypermap`; `h:num->A`;`t:num->A`;`(n:num)+(m:num)` ] identify_contour)
       THEN USE_THEN "FA" (fun th -> SIMP_TAC[th])
       THEN USE_THEN "F6" (fun th -> REWRITE_TAC[th])
       THEN REWRITE_TAC[is_contour]
       THEN DISCH_THEN (fun th -> REWRITE_TAC[th])
       THEN REMOVE_THEN "FA" (MP_TAC o SPEC `(n:num) + (m:num)`)
       THEN REWRITE_TAC[LE_REFL]
       THEN POP_ASSUM SUBST1_TAC
       THEN DISCH_THEN (SUBST1_TAC o SYM)
       THEN REMOVE_THEN "F6" (MP_TAC o SPEC `m:num` o CONJUNCT2 o CONJUNCT2 o CONJUNCT2 o CONJUNCT2)
       THEN REWRITE_TAC[LE_REFL]
       THEN DISCH_THEN SUBST1_TAC
       THEN REMOVE_THEN "F3" (fun th -> MESON_TAC[th; is_contour]); ALL_TAC]
    THEN STRIP_TAC
    THENL[GEN_TAC
       THEN DISCH_THEN (fun th -> (REWRITE_TAC[MATCH_MP (ARITH_RULE `i:num <= n ==> ~(i = n + SUC m)`) th; COND_ELIM_THM]) THEN MP_TAC th)
       THEN USE_THEN "F6" (fun th -> REWRITE_TAC[CONJUNCT1(CONJUNCT2(CONJUNCT2(CONJUNCT2 th)))]); ALL_TAC] 
    THEN REPEAT STRIP_TAC
    THEN ASM_CASES_TAC `i:num  = SUC m`
    THENL[POP_ASSUM SUBST1_TAC THEN REWRITE_TAC[COND_ELIM_THM]; ALL_TAC]
    THEN POP_ASSUM (fun th -> (REWRITE_TAC[COND_ELIM_THM; MATCH_MP (ARITH_RULE `~(i:num = SUC m) ==> ~((n:num) + i = n + SUC m)`) th] THEN ASSUME_TAC th))
    THEN USE_THEN "F6" (fun th -> MP_TAC (SPEC `i:num` (CONJUNCT2(CONJUNCT2(CONJUNCT2(CONJUNCT2 th))))))
    THEN POP_ASSUM (fun th1 -> (POP_ASSUM (fun th2 -> (REWRITE_TAC[MATCH_MP (ARITH_RULE `~(i:num = SUC m) /\ (i <= SUC m) ==> i <= m`) (CONJ th1 th2)]))))
);;


let node_contour = new_definition `!(H:(A)hypermap) (x:A) (i:num). node_contour H x i = ((inverse (node_map H)) POWER i) x`;;

(* face contour is exactly: face_path *)

let face_contour = new_definition `!(H:(A)hypermap) (x:A) (i:num). face_contour H x i  = ((face_map H) POWER i) x`;; 

let lemma_node_contour = prove(`!(H:(A)hypermap) (x:A) (k:num). is_contour H (node_contour H x) k`,
     REPLICATE_TAC 2 GEN_TAC
     THEN INDUCT_TAC THENL[REWRITE_TAC[is_contour]; ALL_TAC]
     THEN REWRITE_TAC[is_contour]
     THEN ASM_REWRITE_TAC[]
     THEN REWRITE_TAC[one_step_contour]
     THEN DISJ2_TAC THEN REWRITE_TAC[node_contour; COM_POWER; o_THM]);;

let lemma_face_contour = prove(`!(H:(A)hypermap) (x:A) (k:num). is_contour H (face_contour H x) k`,
     REPLICATE_TAC 2 GEN_TAC
     THEN INDUCT_TAC THENL[REWRITE_TAC[is_contour]; ALL_TAC]
     THEN REWRITE_TAC[is_contour]
     THEN ASM_REWRITE_TAC[]
     THEN REWRITE_TAC[one_step_contour]
     THEN DISJ1_TAC THEN REWRITE_TAC[face_contour; COM_POWER; o_THM]);;



let existence_contour = prove(`!(H:(A)hypermap) p:num->A n:num. is_path H p n ==> ?q:num->A m:num. q 0 = p 0 /\ q m = p n /\ is_contour H q m`,
   REPLICATE_TAC 2 GEN_TAC THEN INDUCT_TAC
   THENL[REWRITE_TAC[is_path]
       THEN EXISTS_TAC `p:num->A` THEN EXISTS_TAC `0` THEN ASM_REWRITE_TAC[is_contour]; ALL_TAC]
   THEN REWRITE_TAC[is_path]
   THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F1") (LABEL_TAC "F2"))
   THEN FIRST_X_ASSUM (MP_TAC o check (is_imp o concl))
   THEN REMOVE_THEN "F1" (fun th -> REWRITE_TAC[th])
   THEN DISCH_THEN (X_CHOOSE_THEN `q:num->A` (X_CHOOSE_THEN `m:num` (CONJUNCTS_THEN2 (LABEL_TAC "F3") (CONJUNCTS_THEN2 (LABEL_TAC "F4") (LABEL_TAC "F5")))))
   THEN REMOVE_THEN "F2" MP_TAC
   THEN REWRITE_TAC[go_one_step]
   THEN STRIP_TAC
   THENL[ POP_ASSUM (LABEL_TAC "G1")
       THEN MP_TAC (SPECL[`H:(A)hypermap`; `(q:num->A) (m:num)`; `0`] node_contour)
       THEN REWRITE_TAC[POWER_0; I_THM]
       THEN USE_THEN "F5" (fun th1 -> (DISCH_THEN (fun th2 -> MP_TAC(MATCH_MP concatenate_contours (CONJ th1 (CONJ (SPECL[`H:(A)hypermap`; `(q:num->A) (m:num)`; `1`] lemma_node_contour) (SYM th2)))))))
       THEN REWRITE_TAC[GSYM ADD1]
       THEN DISCH_THEN (X_CHOOSE_THEN `g:num->A` (CONJUNCTS_THEN2 (LABEL_TAC "G2") (CONJUNCTS_THEN2 (LABEL_TAC "G3") (LABEL_TAC "G4" o CONJUNCT1))))
       THEN REMOVE_THEN "G3" MP_TAC
       THEN REWRITE_TAC[node_contour; POWER_1]
       THEN DISCH_THEN (LABEL_TAC "G2")
       THEN MP_TAC (SPEC `H:(A)hypermap` hypermap_lemma)
       THEN DISCH_THEN (fun th -> MP_TAC(MATCH_MP inverse_element_lemma (CONJ (CONJUNCT1 th) (CONJUNCT1(CONJUNCT2(CONJUNCT2(CONJUNCT2 th)))))))
       THEN DISCH_THEN (X_CHOOSE_THEN `j:num` (LABEL_TAC "G7" o SYM))
       THEN MP_TAC (SPECL[`H:(A)hypermap`; `(g:num->A) (SUC m)`; `0:num`] face_contour)
       THEN REWRITE_TAC[POWER_0; I_THM]
       THEN USE_THEN "G4" (fun th1 -> (DISCH_THEN (fun th2 -> MP_TAC(MATCH_MP concatenate_contours (CONJ th1 (CONJ (SPECL[`H:(A)hypermap`; `(g:num->A) (SUC m)`; `j:num`] lemma_face_contour) (SYM th2)))))))
       THEN REWRITE_TAC[face_contour]
       THEN DISCH_THEN (X_CHOOSE_THEN `w:num->A` STRIP_ASSUME_TAC)
       THEN EXISTS_TAC `w:num->A`
       THEN EXISTS_TAC `(SUC m) + (j:num)`
       THEN ASM_REWRITE_TAC[]
       THEN GEN_REWRITE_TAC (LAND_CONV o ONCE_DEPTH_CONV) [GSYM o_THM]
       THEN REWRITE_TAC[GSYM inverse2_hypermap_maps];
       POP_ASSUM (LABEL_TAC "G1")
       THEN MP_TAC (SPEC `H:(A)hypermap` hypermap_lemma)
       THEN DISCH_THEN (fun th -> MP_TAC(MATCH_MP inverse_element_lemma (CONJ (CONJUNCT1 th) (CONJUNCT1(CONJUNCT2(CONJUNCT2 th))))))
       THEN DISCH_THEN (X_CHOOSE_THEN `j:num` (LABEL_TAC "G7" o SYM))
       THEN MP_TAC (SPECL[`H:(A)hypermap`; `(q:num->A) (m:num)`; `0:num`] node_contour)
       THEN REWRITE_TAC[POWER_0; I_THM]
       THEN USE_THEN "F5" (fun th1 -> (DISCH_THEN (fun th2 -> MP_TAC(MATCH_MP concatenate_contours (CONJ th1 (CONJ (SPECL[`H:(A)hypermap`; `(q:num->A) (m:num)`; `j:num`] lemma_node_contour) (SYM th2)))))))
       THEN REWRITE_TAC[node_contour]
       THEN DISCH_THEN (X_CHOOSE_THEN `w:num->A` STRIP_ASSUME_TAC)
       THEN EXISTS_TAC `w:num->A`
       THEN EXISTS_TAC `(m:num) + (j:num)`
       THEN ASM_REWRITE_TAC[]
       THEN CONV_TAC SYM_CONV
       THEN REWRITE_TAC[GSYM(MATCH_MP inverse_power_function (CONJUNCT1(CONJUNCT2(CONJUNCT2(SPEC `H:(A)hypermap` hypermap_lemma)))))]
       THEN GEN_REWRITE_TAC (RAND_CONV o ONCE_DEPTH_CONV) [GSYM o_THM]
       THEN REWRITE_TAC[GSYM POWER]
       THEN REWRITE_TAC[COM_POWER; o_THM]
       THEN USE_THEN "G7" SUBST1_TAC
       THEN REWRITE_TAC[node_map_inverse_representation]; ALL_TAC]
   THEN POP_ASSUM (LABEL_TAC "G1")
   THEN MP_TAC (SPECL[`H:(A)hypermap`; `(q:num->A) (m:num)`; `0`] face_contour)
   THEN REWRITE_TAC[POWER_0; I_THM]
   THEN USE_THEN "F5" (fun th1 -> (DISCH_THEN (fun th2 -> MP_TAC(MATCH_MP concatenate_contours (CONJ th1 (CONJ (SPECL[`H:(A)hypermap`; `(q:num->A) (m:num)`; `1`] lemma_face_contour) (SYM th2)))))))
   THEN REWRITE_TAC[GSYM ADD1]
   THEN STRIP_TAC
   THEN EXISTS_TAC `g:num->A`
   THEN EXISTS_TAC `(SUC m)`
   THEN ASM_REWRITE_TAC[face_contour; POWER_1]);;

let lemmaKDAEDEX = prove(`!H:(A)hypermap x:A y:A. y IN comb_component H x 
   ==> ?p:num->A n:num. (p 0 = x) /\ (p n = y) /\ (is_contour H p n)`, 
   REPEAT GEN_TAC THEN REWRITE_TAC[IN_ELIM_THM; comb_component; is_in_component] 
   THEN REPEAT STRIP_TAC THEN POP_ASSUM (MP_TAC o MATCH_MP existence_contour) 
   THEN REPEAT STRIP_TAC THEN EXISTS_TAC `q:num->A` THEN EXISTS_TAC `m:num` 
   THEN ASM_REWRITE_TAC[]);;


(* the definition of injectve contours *)

let is_inj_contour = new_recursive_definition num_RECURSION  `(is_inj_contour (H:(A)hypermap) (p:num->A) 0 <=> T) /\ 
        (is_inj_contour (H:(A)hypermap) (p:num->A) (SUC n) <=> ((is_inj_contour H p n) /\ one_step_contour H (p n) (p (SUC n)) /\ 
                 (!i:num. i <= n ==> ~(p i = p (SUC n))) ))`;; 

let lemma_sub_inj_contour = prove(`!H:(A)hypermap p:num->A n:num. is_inj_contour H p n
    ==> (!i. i <= n ==> is_inj_contour H p i)`,
   REPLICATE_TAC 2 GEN_TAC THEN INDUCT_TAC 
   THENL[ SIMP_TAC[is_inj_contour; ARITH_RULE `i <= 0 ==> i = 0`]; ALL_TAC] 
   THEN STRIP_TAC THEN GEN_TAC THEN 
   REWRITE_TAC[ARITH_RULE `i<=SUC n <=> i = SUC n \/ i <= n`] 
   THEN STRIP_TAC  THENL[ASM_REWRITE_TAC[]; 
   UNDISCH_TAC `is_inj_contour (H:(A)hypermap) (p:num->A) (SUC n)` 
   THEN ASM_REWRITE_TAC[is_inj_contour] THEN ASM_MESON_TAC[]]);;

let identify_inj_contour = prove(`!(H:(A)hypermap) p:num->A q:num->A n:num. is_inj_contour H p n /\ (!i:num. i<= n ==> p i = q i) 
   ==> is_inj_contour H q n`, 
   REPLICATE_TAC 3 GEN_TAC THEN INDUCT_TAC 
   THENL[STRIP_TAC THEN REWRITE_TAC[is_inj_contour]; ALL_TAC] 
   THEN POP_ASSUM (LABEL_TAC "F1") 
   THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F2") (LABEL_TAC "F3")) 
   THEN REMOVE_THEN "F2" MP_TAC 
   THEN GEN_REWRITE_TAC (LAND_CONV o ONCE_DEPTH_CONV) [is_inj_contour] 
   THEN STRIP_TAC THEN REMOVE_THEN "F1" MP_TAC THEN ASM_REWRITE_TAC[] 
   THEN SUBGOAL_THEN `!i:num. i <= (n:num) ==> (p:num->A) i = (q:num->A) i` ASSUME_TAC 
   THENL[REPEAT STRIP_TAC THEN MP_TAC(ARITH_RULE `i:num <= n:num ==> i <= SUC n`) 
     THEN ASM_REWRITE_TAC[]; ALL_TAC] 
   THEN ASM_REWRITE_TAC[] THEN STRIP_TAC 
   THEN ASM_REWRITE_TAC[is_inj_contour] 
   THEN SUBGOAL_THEN `(p:num->A) (n:num) = (q:num->A) (n:num)` (ASSUME_TAC o SYM) 
   THENL[ASM_MESON_TAC[ARITH_RULE `n <= SUC n`]; ALL_TAC] 
   THEN  SUBGOAL_THEN `(p:num->A) (SUC(n:num)) = (q:num->A) (SUC(n:num))`  (ASSUME_TAC o SYM) 
   THENL[ASM_MESON_TAC[ARITH_RULE `SUC n <= SUC n`]; ALL_TAC] 
   THEN UNDISCH_THEN `one_step_contour (H:(A)hypermap) ((p:num->A) (n:num)) ((p:num->A) (SUC n:num))` 
   MP_TAC THEN STRIP_TAC THEN ASM_REWRITE_TAC[] THEN REPLICATE_TAC 2 STRIP_TAC 
   THEN UNDISCH_THEN `!i:num. i <= (n:num) ==> (p:num->A) i = (q:num->A) i` (MP_TAC o SPEC `i:num`) 
   THEN ASM_REWRITE_TAC[] THEN DISCH_THEN (SUBST1_TAC o SYM) 
   THEN ASM_MESON_TAC[ARITH_RULE `i <= n ==> i <= SUC n`]);;


let lemma_def_inj_contour = prove(`!(H:(A)hypermap) p:num->A n:num. 
    is_inj_contour H p n <=> is_contour H p n /\ (!i:num j:num. i <= n /\ j < i ==> ~(p j = p i))`, 
REPLICATE_TAC 2 GEN_TAC THEN INDUCT_TAC 
   THENL[REWRITE_TAC[is_inj_contour; is_contour] THEN ARITH_TAC; ALL_TAC] 
   THEN POP_ASSUM (LABEL_TAC "B1") 
   THEN ASM_REWRITE_TAC[is_inj_contour; is_contour] THEN EQ_TAC 
   THENL[STRIP_TAC THEN ASM_REWRITE_TAC[] THEN REMOVE_THEN "B1" MP_TAC 
      THEN ASM_REWRITE_TAC[] THEN REPEAT STRIP_TAC 
      THEN ASM_CASES_TAC `i:num = SUC (n:num)` 
      THENL[POP_ASSUM SUBST_ALL_TAC THEN MP_TAC (ARITH_RULE `j:num < SUC (n:num) ==> j <= n`) 
      THEN ASM_REWRITE_TAC[] THEN STRIP_TAC 
      THEN UNDISCH_THEN `!i:num. i <= (n:num) ==> ~((p:num->A) i = p (SUC n))` (MP_TAC o SPEC `j:num`) 
      THEN ASM_REWRITE_TAC[]; ALL_TAC]
      THEN MP_TAC (ARITH_RULE `(i:num <= SUC (n:num)) /\ ~(i = SUC n) ==> i <= n`) 
      THEN ASM_REWRITE_TAC[] THEN STRIP_TAC 
      THEN UNDISCH_THEN `!(i:num) (j:num). i <= (n:num) /\ j < i ==> ~((p:num->A) j = p i)` (MP_TAC o ISPECL[`i:num`;`j:num`]) 
   THEN ASM_REWRITE_TAC[]; ALL_TAC] 
   THEN STRIP_TAC THEN ASM_REWRITE_TAC[] THEN STRIP_TAC 
   THENL[REPEAT STRIP_TAC THEN MP_TAC(ARITH_RULE `i:num <= n:num ==> i <= SUC n`) 
      THEN ASM_REWRITE_TAC[] THEN STRIP_TAC THEN 
      UNDISCH_THEN `!i:num j:num. i <= SUC (n:num) /\ j < i ==> ~((p:num->A) j = p i)` (MP_TAC o SPECL[`i:num`;`j:num`]) 
      THEN ASM_REWRITE_TAC[]; ALL_TAC] 
   THEN REPEAT STRIP_TAC THEN MP_TAC(ARITH_RULE `i:num <= n:num ==> i < SUC n`) 
   THEN ASM_REWRITE_TAC[] THEN STRIP_TAC 
   THEN UNDISCH_THEN `!i:num j:num. i <= SUC (n:num) /\ j < i ==> ~((p:num->A) j = p i)` (MP_TAC o SPECL[`SUC(n:num)`;`i:num`]) 
   THEN ASM_REWRITE_TAC[] THEN ARITH_TAC);;

let lemma4dot11 = prove(`!(H:(A)hypermap) p:num->A n:num. is_contour H p n 
   ==> ?q:num->A m:num. q 0 = p 0 /\ q m = p n /\ is_inj_contour H q m /\ (!i:num. (i < m)==>(?j:num. j < n /\ q i = p j /\ q (SUC i) = p (SUC j)) )`, 
   REPLICATE_TAC 2 GEN_TAC THEN INDUCT_TAC 
   THENL[STRIP_TAC THEN EXISTS_TAC `p:num->A` THEN EXISTS_TAC `0` THEN ASM_REWRITE_TAC[is_inj_contour] THEN  ARITH_TAC; ALL_TAC]
   THEN REWRITE_TAC[is_contour] THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F1") (LABEL_TAC "F2")) 
   THEN FIRST_X_ASSUM(MP_TAC o check(is_imp o concl))
   THEN ASM_REWRITE_TAC[] THEN STRIP_TAC THEN ASM_CASES_TAC `?k:num. k <= m:num /\ (q:num->A) k = p (SUC n:num)`
   THENL[POP_ASSUM (X_CHOOSE_THEN `k:num` STRIP_ASSUME_TAC) 
      THEN EXISTS_TAC `q:num->A` 
      THEN EXISTS_TAC `k:num` THEN ASM_REWRITE_TAC[] 
      THEN UNDISCH_THEN `is_inj_contour (H:(A)hypermap) (q:num->A) (m:num)` (MP_TAC o (SPEC `k:num`) o MATCH_MP lemma_sub_inj_contour) 
      THEN ASM_REWRITE_TAC[] THEN STRIP_TAC THEN ASM_REWRITE_TAC[] 
      THEN REPEAT STRIP_TAC THEN MP_TAC(ARITH_RULE `k:num <= m:num /\ i < k ==> i < m`) THEN ASM_REWRITE_TAC[] THEN STRIP_TAC 
      THEN UNDISCH_THEN `!(i:num). i < (m:num) ==> (?(j:num). j < (n:num) /\ (q:num->A) i = (p:num->A) j /\ q (SUC i) = p (SUC j))` (MP_TAC o SPEC `i:num`)
      THEN ASM_REWRITE_TAC[] THEN DISCH_THEN(X_CHOOSE_THEN `j:num` MP_TAC) THEN STRIP_TAC THEN 
      EXISTS_TAC `j:num` THEN ASM_REWRITE_TAC[] THEN UNDISCH_THEN `j:num < n:num` MP_TAC  THEN ARITH_TAC; ALL_TAC]
   THEN REPLICATE_TAC 2 (POP_ASSUM MP_TAC) THEN DISCH_THEN (LABEL_TAC "F3") 
   THEN DISCH_THEN (LABEL_TAC "F4") 
   THEN EXISTS_TAC `(\l:num. if l = SUC (m:num) then (p:num->A) (SUC (n:num)) else (q:num->A) l)` 
   THEN EXISTS_TAC `SUC (m:num)` 
   THEN ABBREV_TAC `t = (\l:num. if l = SUC (m:num) then (p:num->A) (SUC (n:num)) else (q:num->A) l)` 
   THEN SUBGOAL_THEN `!i:num. i <= m:num ==> (q:num->A) i= (t:num->A) i` (LABEL_TAC "B1")
   THENL[REPEAT STRIP_TAC THEN MP_TAC(ARITH_RULE `i:num <= m:num ==> ~(i = SUC m)`) THEN ASM_REWRITE_TAC[] 
      THEN EXPAND_TAC "t" THEN DISCH_THEN (fun th -> (REWRITE_TAC[th;COND_ELIM_THM])); ALL_TAC]
   THEN SUBGOAL_THEN `(t:num->A) (SUC (m:num)) = (p:num->A) (SUC (n:num))` (LABEL_TAC "B2") 
   THENL[EXPAND_TAC "t" THEN REWRITE_TAC[]; ALL_TAC]
   THEN USE_THEN "B1" (MP_TAC o SPEC `0`) THEN REWRITE_TAC[LE_0] 
   THEN DISCH_THEN (ASSUME_TAC o SYM) THEN ASM_REWRITE_TAC[] THEN STRIP_TAC
   THENL[UNDISCH_THEN `is_inj_contour (H:(A)hypermap) (q:num->A) (m:num)` (fun th1 -> USE_THEN "B1" (fun th2 -> ASSUME_TAC(MATCH_MP identify_inj_contour (CONJ th1 (th2))))) 
      THEN ASM_REWRITE_TAC[is_inj_contour] THEN USE_THEN "B1" (MP_TAC o SPEC `m:num`) 
      THEN REWRITE_TAC[ARITH_RULE `(m:num) <= m`] THEN DISCH_THEN (ASSUME_TAC o SYM) THEN ASM_REWRITE_TAC[] 
      THEN REPEAT STRIP_TAC THEN REMOVE_THEN "F4" MP_TAC 
      THEN REWRITE_TAC[CONTRAPOS_THM] THEN EXISTS_TAC `i: num` THEN ASM_REWRITE_TAC[] 
   THEN REMOVE_THEN "B1" (MP_TAC o SPEC `i:num`) THEN ASM_REWRITE_TAC[]; ALL_TAC]
   THEN REPEAT STRIP_TAC THEN ASM_CASES_TAC `i:num = m:num`
   THENL[EXISTS_TAC `n:num` THEN ASM_REWRITE_TAC[LT_PLUS] 
      THEN USE_THEN "B1" (MP_TAC o SPEC `m:num`) 
      THEN REWRITE_TAC[LE_REFL] 
      THEN DISCH_THEN (ASSUME_TAC o SYM) THEN ASM_REWRITE_TAC[]; ALL_TAC]
   THEN MP_TAC(ARITH_RULE `i:num < SUC (m:num) /\ ~(i = m) ==> i < m`) THEN ASM_REWRITE_TAC[] 
   THEN STRIP_TAC THEN REMOVE_THEN "F3" (MP_TAC o SPEC `i:num`) THEN ASM_REWRITE_TAC[] 
   THEN DISCH_THEN (X_CHOOSE_THEN `j:num` STRIP_ASSUME_TAC) THEN EXISTS_TAC `j:num` 
   THEN MP_TAC(ARITH_RULE `j:num < n:num ==> j < SUC n`) THEN ASM_REWRITE_TAC[] 
   THEN STRIP_TAC THEN MP_TAC(SPECL[`i:num`; `m:num`] LT_IMP_LE)
   THEN ASM_REWRITE_TAC[] THEN STRIP_TAC THEN USE_THEN "B1" (MP_TAC o SPEC `i:num`) 
   THEN POP_ASSUM(fun th-> REWRITE_TAC[th]) THEN DISCH_THEN(fun th -> REWRITE_TAC[SYM th]) 
   THEN MP_TAC(ARITH_RULE `i:num < m:num ==> SUC i <= m`) THEN ASM_REWRITE_TAC[] 
   THEN  STRIP_TAC THEN USE_THEN "B1" (MP_TAC o SPEC `SUC (i:num)`) 
   THEN POP_ASSUM(fun th-> REWRITE_TAC[th]) 
   THEN DISCH_THEN(fun th -> REWRITE_TAC[SYM th]) THEN ASM_REWRITE_TAC[]) ;;

(* The theory of walkup in detail here with many trial facts *)

let isolated_dart = new_definition `!(H:(A)hypermap) (x:A). isolated_dart H x  <=> (edge_map H x = x /\ node_map H x = x /\ face_map H x = x)`;;

let is_edge_degenerate = new_definition `is_edge_degenerate (H:(A)hypermap) (x:A) 
   <=>  (edge_map H x = x) /\ ~(node_map H x = x) /\ ~(face_map H x = x)`;;

let is_node_degenerate = new_definition `is_node_degenerate (H:(A)hypermap) (x:A) 
   <=>  ~(edge_map H x = x) /\ (node_map H x = x) /\ ~(face_map H x = x)`;;

let is_face_degenerate = new_definition `is_face_degenerate (H:(A)hypermap) (x:A) 
   <=>  ~(edge_map H x = x) /\ ~(node_map H x = x) /\ (face_map H x = x)`;;


let degenerate_lemma = prove(`!(H:(A)hypermap) (x:A). dart_degenerate H x 
   <=> isolated_dart H x \/ is_edge_degenerate H x \/  is_node_degenerate H x \/  is_face_degenerate H x`, 
   
REPEAT GEN_TAC THEN STRIP_ASSUME_TAC (SPEC `H:(A)hypermap` hypermap_lemma) 
   THEN REWRITE_TAC[dart_degenerate;isolated_dart; is_edge_degenerate; is_node_degenerate; is_face_degenerate] 
   THEN POP_ASSUM (LABEL_TAC "F1") THEN ABBREV_TAC `D = dart (H:(A)hypermap)` 
   THEN ABBREV_TAC `e = edge_map (H:(A)hypermap)` 
   THEN ABBREV_TAC `n = node_map (H:(A)hypermap)` 
   THEN ABBREV_TAC `f = face_map (H:(A)hypermap)` 
   THEN MP_TAC(SPECL[`D:A->bool`; `e:A->A`;`n:A->A`;`f:A->A`] cyclic_maps) THEN ASM_REWRITE_TAC[] 
   THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F2") (LABEL_TAC "F3")) THEN EQ_TAC
   THENL[STRIP_TAC THENL [ASM_REWRITE_TAC[] THEN ASM_CASES_TAC `(n:A->A) (x:A) = x` 
      THENL[ASM_REWRITE_TAC[] THEN USE_THEN "F3" (fun th -> (MP_TAC(AP_THM th `x:A`))) 
      THEN ASM_REWRITE_TAC[o_THM;I_THM]; ASM_REWRITE_TAC[] THEN STRIP_TAC 
      THEN USE_THEN "F2" (fun th -> (MP_TAC(AP_THM th `x:A`))) 
      THEN ASM_REWRITE_TAC[o_THM;I_THM]] ; ASM_REWRITE_TAC[] 
      THEN ASM_CASES_TAC `(e:A->A) (x:A) = x` 
      THENL[ ASM_REWRITE_TAC[] THEN USE_THEN "F3" (fun th -> (MP_TAC(AP_THM th `x:A`))) 
         THEN ASM_REWRITE_TAC[o_THM;I_THM]; ASM_REWRITE_TAC[] THEN STRIP_TAC 
         THEN USE_THEN "F1" (fun th -> (MP_TAC(AP_THM th `x:A`))) THEN ASM_REWRITE_TAC[o_THM;I_THM]]; 
      ASM_REWRITE_TAC[] THEN ASM_CASES_TAC `(e:A->A) (x:A) = x` 
      THENL[ASM_REWRITE_TAC[] THEN USE_THEN "F2" (fun th -> (MP_TAC(AP_THM th `x:A`))) 
         THEN ASM_REWRITE_TAC[o_THM;I_THM]; ASM_REWRITE_TAC[] THEN STRIP_TAC THEN 
      USE_THEN "F1" (fun th -> (MP_TAC(AP_THM th `x:A`))) THEN ASM_REWRITE_TAC[o_THM;I_THM]]]; 
      MESON_TAC[]]);;

let lemma_category_darts = prove(`!(H:(A)hypermap) (x:A). dart_nondegenerate H x \/ dart_degenerate H x`,
     REPEAT STRIP_TAC
     THEN ASM_CASES_TAC `dart_degenerate (H:(A)hypermap) (x:A)`
     THENL[ASM_REWRITE_TAC[]; ALL_TAC]
     THEN ASM_REWRITE_TAC[]
     THEN POP_ASSUM MP_TAC
     THEN REWRITE_TAC[dart_degenerate; dart_nondegenerate]
     THEN MESON_TAC[]);;

(* Some trivial lemmas on PAIRS *)

let lemma_pair_representation = prove(`!(S:((A->bool)#(A->A)#(A->A)#(A->A))). 
    S = (FST S, FST (SND S), FST(SND(SND S)), SND(SND(SND S)))`,
    REWRITE_TAC[PAIR_SURJECTIVE]);;

let lemma_pair_eq = prove(`!(S:((A->bool)#(A->A)#(A->A)#(A->A))) (U:((A->bool)#(A->A)#(A->A)#(A->A))). 
   ((FST S = FST U) /\ (FST (SND S) = FST (SND U)) /\ (FST(SND(SND S)) = FST(SND(SND U))) /\ (SND(SND(SND S))) = SND(SND(SND U))) ==>(S = U)`, 
    ASM_MESON_TAC[lemma_pair_representation]);;

let lemma_hypermap_eq = prove(`!(H:(A)hypermap) (H':(A)hypermap). 
    H = H' <=> dart H = dart H' /\ edge_map H = edge_map H' /\ node_map H = node_map H' /\ face_map H = face_map H'`, 
    REPEAT GEN_TAC THEN  EQ_TAC 
    THENL[ASM_MESON_TAC[hypermap_tybij; dart; edge_map; node_map; face_map]; ALL_TAC] 
    THEN ASM_REWRITE_TAC[hypermap_tybij; dart; edge_map; node_map; face_map] 
    THEN REPEAT STRIP_TAC 
    THEN SUBGOAL_THEN `tuple_hypermap (H:(A)hypermap) = tuple_hypermap (H':(A)hypermap)` ASSUME_TAC 
       THENL[ASM_MESON_TAC[lemma_pair_eq]; ASM_MESON_TAC[CONJUNCT1 hypermap_tybij]]);;

let lemma_hypermap_representation = prove(`!(D:A->bool) (e:A->A) (n:A->A) (f:A->A). (FINITE D /\ e permutes D /\ n permutes D /\ f permutes D /\ (e o n o f = I)) ==> ?(H:(A)hypermap). (H = hypermap (D, e, n, f)) /\ dart H = D /\ edge_map H = e /\ node_map H = n /\ face_map H = f `, 
    REPEAT STRIP_TAC THEN EXISTS_TAC `hypermap (D:A->bool, e:A->A, n:A->A, f:A->A)` 
    THEN REWRITE_TAC[] THEN REWRITE_TAC[dart; edge_map; node_map; face_map] 
    THEN MP_TAC (SPEC `(D:A->bool, e:A->A, n:A->A, f:A->A)` (CONJUNCT2 hypermap_tybij)) 
    THEN ASM_REWRITE_TAC[] THEN  STRIP_TAC THEN ASM_REWRITE_TAC[]);;

let shift = new_definition `shift (H:(A)hypermap) =  hypermap(dart H, node_map H, face_map H, edge_map H)`;;

let shift_lemma = prove(`!(H:(A)hypermap). dart H = dart (shift H) /\ edge_map H = face_map (shift H) /\ node_map H = edge_map (shift H) /\ face_map H = node_map (shift H)`, 
   GEN_TAC THEN REWRITE_TAC [shift] 
   THEN STRIP_ASSUME_TAC(SPEC `H:(A)hypermap` hypermap_lemma) 
   THEN MP_TAC(SPECL[`dart (H:(A)hypermap)`; `edge_map (H:(A)hypermap)`; `node_map (H:(A)hypermap)`; `face_map (H:(A)hypermap)`] cyclic_maps) 
   THEN ASM_REWRITE_TAC[] THEN STRIP_TAC 
   THEN MP_TAC (SPECL[`dart (H:(A)hypermap)`; `node_map (H:(A)hypermap)`; `face_map (H:(A)hypermap)`; `edge_map (H:(A)hypermap)`]  lemma_hypermap_representation) 
   THEN ASM_REWRITE_TAC[] 
   THEN ABBREV_TAC `G = hypermap(dart (H:(A)hypermap), node_map H, face_map H, edge_map H)` 
   THEN STRIP_TAC THEN UNDISCH_THEN `H':(A)hypermap = G:(A)hypermap` SUBST_ALL_TAC 
   THEN ASM_SIMP_TAC[]);;

let double_shift_lemma = prove( `!(H:(A)hypermap). dart H = dart (shift(shift H)) /\ edge_map H = node_map (shift(shift H)) /\ node_map H = face_map (shift(shift H)) /\ face_map H = edge_map (shift (shift H))`, 
   GEN_TAC THEN STRIP_ASSUME_TAC(SPEC `shift(H:(A)hypermap)` shift_lemma) 
   THEN STRIP_ASSUME_TAC(SPEC `H:(A)hypermap` shift_lemma) THEN ASM_REWRITE_TAC[]);;

(* the definition of walkups *)

let edge_walkup = new_definition `edge_walkup (H:(A)hypermap) (x:A) = hypermap((dart H) DELETE x,inverse(swap(x, face_map H x) o face_map H) o inverse(swap(x, node_map H x) o node_map H) , swap(x, node_map H x) o node_map H, swap(x, face_map H x) o face_map H)`;;

let node_walkup = new_definition `node_walkup (H:(A)hypermap) (x:A) = shift(shift(edge_walkup (shift H) x))`;;

let face_walkup = new_definition `face_walkup (H:(A)hypermap) (x:A) = shift(edge_walkup (shift (shift H)) x)`;;

let double_edge_walkup = new_definition `double_edge_walkup (H:(A)hypermap) (x:A) (y:A) = edge_walkup (edge_walkup H x) y`;;

let double_node_walkup = new_definition `double_node_walkup (H:(A)hypermap) (x:A) (y:A) = node_walkup (node_walkup H x) y`;;

let double_face_walkup = new_definition `double_face_walkup (H:(A)hypermap) (x:A) (y:A) = face_walkup (face_walkup H x) y`;;

let walkup_permutes = prove(`!(D:A->bool) (p:A->A) (x:A). FINITE D /\p permutes D ==> (swap(x, p x) o p) permutes (D DELETE x)`,
   REPEAT STRIP_TAC THEN UNDISCH_THEN `FINITE (D:A->bool)` (fun th -> ASSUME_TAC th THEN MP_TAC(SPEC `x:A` (MATCH_MP FINITE_DELETE_IMP th))) 
   THEN ASM_REWRITE_TAC[] THEN STRIP_TAC 
   THEN ASM_CASES_TAC `x:A IN (D:A->bool)` 
   THENL[MP_TAC (SET_RULE `(x:A) IN (D:A->bool) ==> (D = x INSERT (D DELETE x))`) 
      THEN ASM_REWRITE_TAC[] THEN ABBREV_TAC `S = (D:A->bool) DELETE (x:A)` 
      THEN DISCH_THEN SUBST_ALL_TAC THEN MP_TAC(ISPECL[`p:A->A`;`x:A`;`(S:A->bool)`] PERMUTES_INSERT_LEMMA) 
      THEN ASM_REWRITE_TAC[]; ALL_TAC] 
   THEN MP_TAC (SET_RULE `~((x:A) IN (D:A->bool)) ==> D DELETE x = D`) 
   THEN ASM_REWRITE_TAC[] THEN DISCH_THEN SUBST_ALL_TAC 
   THEN UNDISCH_THEN `p:A->A permutes (D:A->bool)` (fun th -> ASSUME_TAC th THEN MP_TAC th) 
   THEN GEN_REWRITE_TAC(LAND_CONV o ONCE_DEPTH_CONV) [permutes] 
   THEN DISCH_THEN (MP_TAC o SPEC `x:A` o CONJUNCT1) THEN ASM_REWRITE_TAC[] 
   THEN DISCH_THEN (fun th -> ASM_REWRITE_TAC[th; SWAP_REFL; I_O_ID]));;

let PERMUTES_COMPOSITION = prove(`!p q s. p permutes s /\ q permutes s ==> (q o p) permutes s`,
   REWRITE_TAC[permutes; o_THM] THEN MESON_TAC[]);;

let lemma_edge_walkup = prove(`!(H:(A)hypermap) (x:A). dart (edge_walkup H x) = dart H DELETE x /\ edge_map (edge_walkup H x) =  inverse(swap(x, face_map H x) o face_map H) o inverse(swap(x, node_map H x) o node_map H) /\ node_map (edge_walkup H x) =  swap(x, node_map H x) o node_map H /\ face_map (edge_walkup H x) =  swap(x, face_map H x) o face_map H`, 
   REPEAT GEN_TAC THEN REWRITE_TAC[edge_walkup] 
   THEN label_hypermap_TAC `H:(A)hypermap` 
   THEN ABBREV_TAC `D = dart (H:(A)hypermap)` 
   THEN ABBREV_TAC `e = edge_map (H:(A)hypermap)` 
   THEN ABBREV_TAC `n = node_map (H:(A)hypermap)` 
   THEN ABBREV_TAC `f = face_map (H:(A)hypermap)` 
   THEN ABBREV_TAC `n' = swap(x:A, (n:A->A) x) o n` 
   THEN ABBREV_TAC `f' = swap(x:A, (f:A->A) x) o f` 
   THEN ABBREV_TAC `D' = (D:A->bool) DELETE (x:A)`  
   THEN MP_TAC(ISPECL[`D:A->bool`;`n:A->A`; `x:A`] walkup_permutes) 
   THEN ASM_REWRITE_TAC[] THEN MP_TAC(ISPECL[`D:A->bool`;`f:A->A`; `x:A`] walkup_permutes) 
   THEN ASM_REWRITE_TAC[] 
   THEN REPLICATE_TAC 2 STRIP_TAC 
   THEN ABBREV_TAC `e' = inverse (f':A->A) o inverse (n':A->A)` 
   THEN SUBGOAL_THEN `(e':A->A) permutes (D':A->bool)` MP_TAC 
   THENL[UNDISCH_THEN `(n':A->A) permutes (D':A->bool)` (MP_TAC o MATCH_MP PERMUTES_INVERSE) 
       THEN UNDISCH_THEN `(f':A->A) permutes (D':A->bool)` (MP_TAC o MATCH_MP PERMUTES_INVERSE) 
       THEN REPEAT STRIP_TAC THEN MP_TAC (ISPECL[`inverse(n':A->A)`; `inverse(f':A->A)`; `D':A->bool`] 
       PERMUTES_COMPOSITION) THEN ASM_REWRITE_TAC[]; ALL_TAC] 
   THEN STRIP_TAC THEN SUBGOAL_THEN `(e':A->A) o (n':A->A) o (f':A->A) = I` ASSUME_TAC 
   THENL[MP_TAC ((ISPECL[`n':A->A`; `D':A->bool`] PERMUTES_INVERSES_o)) 
      THEN ASM_REWRITE_TAC[] THEN MP_TAC ((ISPECL[`f':A->A`; `D':A->bool`] PERMUTES_INVERSES_o)) 
      THEN ASM_REWRITE_TAC[] THEN REPEAT STRIP_TAC THEN EXPAND_TAC "e'" 
      THEN REWRITE_TAC[GSYM o_ASSOC] THEN REWRITE_TAC[lemma_4functions] 
      THEN POP_ASSUM (fun th -> REWRITE_TAC[th]) THEN ASM_REWRITE_TAC[I_O_ID]; ALL_TAC] 
   THEN MP_TAC (SPECL[`D':A->bool`; `e':A->A`; `n':A->A`; `f':A->A`]  lemma_hypermap_representation) 
   THEN MP_TAC (ISPECL[`D:A->bool`; `x:A`] FINITE_DELETE_IMP) 
   THEN ASM_REWRITE_TAC[] THEN STRIP_TAC THEN ASM_REWRITE_TAC[] 
   THEN ABBREV_TAC `G = hypermap(D':A->bool, e':A->A, n':A->A, f':A->A)` 
   THEN STRIP_TAC THEN UNDISCH_THEN `H':(A)hypermap = G:(A)hypermap` SUBST_ALL_TAC 
   THEN ASM_SIMP_TAC[]);;


let node_map_walkup = prove(`!(H:(A)hypermap) (x:A) (y:A). node_map (edge_walkup H x) x = x /\ node_map (edge_walkup H x) (inverse (node_map H) x) = node_map H x /\ (~(y = x) /\ ~(y = inverse (node_map H) x) ==> node_map (edge_walkup H x) y = node_map H y)`,
   REPEAT GEN_TAC THEN LABEL_TAC "F1" (CONJUNCT1 (CONJUNCT2(CONJUNCT2(SPEC `H:(A)hypermap` hypermap_lemma)))) 
   THEN REWRITE_TAC[CONJUNCT1 (CONJUNCT2(CONJUNCT2(SPECL[`H:(A)hypermap`; `x:A`] lemma_edge_walkup)))] 
   THEN REWRITE_TAC[o_THM] THEN ABBREV_TAC `D = dart (H:(A)hypermap)` 
   THEN ABBREV_TAC `n = node_map (H:(A)hypermap)` THEN STRIP_TAC 
   THENL[ABBREV_TAC `z = (n:A->A) (x:A)` THEN REWRITE_TAC[swap] THEN ASM_CASES_TAC `z:A = x:A` THENL[ASM_MESON_TAC[]; ASM_MESON_TAC[]]; ALL_TAC]
   THEN STRIP_TAC 
   THENL[SUBGOAL_THEN `(n:A->A)(inverse(n) (x:A)) = x` (fun th-> REWRITE_TAC[th]) 
      THENL[GEN_REWRITE_TAC (LAND_CONV o ONCE_DEPTH_CONV) [GSYM o_THM] 
         THEN REMOVE_THEN "F1" (ASSUME_TAC o CONJUNCT1 o MATCH_MP PERMUTES_INVERSES_o) 
         THEN POP_ASSUM (fun th -> REWRITE_TAC[th; I_THM]); MESON_TAC[swap]];ALL_TAC]
   THEN STRIP_TAC THEN REWRITE_TAC[o_THM] THEN SUBGOAL_THEN `~((n:A->A) (y:A) = n (x:A))` MP_TAC
   THENL[USE_THEN "F1"(MP_TAC o SPECL[`y:A`;`x:A`] o MATCH_MP PERMUTES_INJECTIVE) THEN ASM_REWRITE_TAC[]; ALL_TAC]
   THEN STRIP_TAC THEN SUBGOAL_THEN `~((n:A->A) (y:A) = (x:A))` ASSUME_TAC
   THENL[STRIP_TAC THEN POP_ASSUM(fun th1 -> (USE_THEN "F1"(fun th2 -> MP_TAC(MATCH_MP inverse_function (CONJ th2 th1))))) THEN ASM_REWRITE_TAC[]; ALL_TAC]
   THEN ASM_MESON_TAC[swap]);;


let face_map_walkup = prove(`!(H:(A)hypermap) (x:A) (y:A). face_map (edge_walkup H x) x = x /\ face_map (edge_walkup H x) (inverse (face_map H) x) = face_map H x /\ (~(y = x) /\ ~(y = inverse (face_map H) x) ==> face_map (edge_walkup H x) y = face_map H y)`,
   REPEAT GEN_TAC THEN LABEL_TAC "F1" (CONJUNCT1 (CONJUNCT2(CONJUNCT2(CONJUNCT2(SPEC `H:(A)hypermap` hypermap_lemma))))) 
   THEN REWRITE_TAC[CONJUNCT2(CONJUNCT2(CONJUNCT2(SPECL[`H:(A)hypermap`; `x:A`] lemma_edge_walkup)))] 
   THEN REWRITE_TAC[o_THM] THEN ABBREV_TAC `D = dart (H:(A)hypermap)` 
   THEN ABBREV_TAC `f = face_map (H:(A)hypermap)` THEN STRIP_TAC 
   THENL[ABBREV_TAC `z = (n:A->A) (x:A)` THEN REWRITE_TAC[swap] THEN ASM_CASES_TAC `z:A = x:A` THENL[ASM_MESON_TAC[]; ASM_MESON_TAC[]]; ALL_TAC]
   THEN STRIP_TAC 
   THENL[SUBGOAL_THEN `(f:A->A)(inverse(f) (x:A)) = x` (fun th-> REWRITE_TAC[th]) 
      THENL[GEN_REWRITE_TAC (LAND_CONV o ONCE_DEPTH_CONV) [GSYM o_THM] 
         THEN REMOVE_THEN "F1" (ASSUME_TAC o CONJUNCT1 o MATCH_MP PERMUTES_INVERSES_o) 
      THEN POP_ASSUM (fun th -> REWRITE_TAC[th; I_THM]); MESON_TAC[swap]];ALL_TAC]
   THEN STRIP_TAC THEN REWRITE_TAC[o_THM] THEN SUBGOAL_THEN `~((f:A->A) (y:A) = f (x:A))` MP_TAC
   THENL[USE_THEN "F1"(MP_TAC o SPECL[`y:A`;`x:A`] o MATCH_MP PERMUTES_INJECTIVE) THEN ASM_REWRITE_TAC[]; ALL_TAC]
   THEN STRIP_TAC THEN SUBGOAL_THEN `~((f:A->A) (y:A) = (x:A))` ASSUME_TAC
   THENL[STRIP_TAC THEN POP_ASSUM(fun th1 -> (USE_THEN "F1"(fun th2 -> MP_TAC(MATCH_MP inverse_function (CONJ th2 th1))))) THEN ASM_REWRITE_TAC[]; ALL_TAC]
   THEN ASM_MESON_TAC[swap]);;

let lemma_edge_degenarate =  prove(`!(H:(A)hypermap) (x:A). (edge_map H x = x) <=> (face_map H x = (inverse (node_map H)) x)`,
   REPEAT STRIP_TAC THEN label_hypermap_TAC `H:(A)hypermap` 
   THEN MP_TAC(AP_THM (SYM (CONJUNCT1(CONJUNCT2(SPEC `H:(A)hypermap` inverse_hypermap_maps)))) `x:A`)
   THEN ABBREV_TAC `D = dart (H:(A)hypermap)`
   THEN ABBREV_TAC `e = edge_map (H:(A)hypermap)` 
   THEN ABBREV_TAC `n = node_map (H:(A)hypermap)` 
   THEN ABBREV_TAC `f = face_map (H:(A)hypermap)`
   THEN REWRITE_TAC[o_THM] THEN DISCH_THEN (LABEL_TAC "F1") THEN EQ_TAC
   THENL[DISCH_TAC THEN REMOVE_THEN "F1" MP_TAC THEN ASM_REWRITE_TAC[o_THM]; ALL_TAC]
   THEN DISCH_THEN (fun th1 -> (USE_THEN "F1" (fun th2 -> (MP_TAC (MATCH_MP EQ_TRANS (CONJ th2 (SYM th1)) )))))
   THEN DISCH_TAC THEN USE_THEN "H4" (MP_TAC o ISPECL[`(e:A->A) (x:A)`; `x:A`] o MATCH_MP PERMUTES_INJECTIVE)
   THEN POP_ASSUM (fun th -> REWRITE_TAC[th]));;

let lemma_node_degenarate =  prove(`!(H:(A)hypermap) (x:A). (node_map H x = x) <=> (edge_map H x = (inverse (face_map H)) x)`,
   REPEAT STRIP_TAC THEN label_hypermap_TAC `H:(A)hypermap` 
   THEN MP_TAC(AP_THM (SYM (CONJUNCT2(CONJUNCT2(SPEC `H:(A)hypermap` inverse_hypermap_maps)))) `x:A`)
   THEN ABBREV_TAC `D = dart (H:(A)hypermap)`
   THEN ABBREV_TAC `e = edge_map (H:(A)hypermap)` 
   THEN ABBREV_TAC `n = node_map (H:(A)hypermap)` 
   THEN ABBREV_TAC `f = face_map (H:(A)hypermap)`
   THEN REWRITE_TAC[o_THM] THEN DISCH_THEN (LABEL_TAC "F1") THEN EQ_TAC
   THENL[DISCH_TAC THEN REMOVE_THEN "F1" MP_TAC THEN ASM_REWRITE_TAC[o_THM]; ALL_TAC]
   THEN DISCH_THEN (fun th1 -> (USE_THEN "F1" (fun th2 -> (MP_TAC (MATCH_MP EQ_TRANS (CONJ th2 (SYM th1)) )))))
   THEN DISCH_TAC THEN USE_THEN "H2" (MP_TAC o ISPECL[`(n:A->A) (x:A)`; `x:A`] o MATCH_MP PERMUTES_INJECTIVE) 
   THEN POP_ASSUM (fun th -> REWRITE_TAC[th]));;

let lemma_face_degenarate =  prove(`!(H:(A)hypermap) (x:A). (face_map H x = x) <=> (node_map H x = (inverse (edge_map H)) x)`,
   REPEAT STRIP_TAC THEN label_hypermap_TAC `H:(A)hypermap` 
   THEN MP_TAC(AP_THM (SYM (CONJUNCT1(SPEC `H:(A)hypermap` inverse_hypermap_maps))) `x:A`)
   THEN ABBREV_TAC `D = dart (H:(A)hypermap)`
   THEN ABBREV_TAC `e = edge_map (H:(A)hypermap)` 
   THEN ABBREV_TAC `n = node_map (H:(A)hypermap)` 
   THEN ABBREV_TAC `f = face_map (H:(A)hypermap)`
   THEN REWRITE_TAC[o_THM] THEN DISCH_THEN (LABEL_TAC "F1") THEN EQ_TAC
   THENL[DISCH_TAC THEN REMOVE_THEN "F1" MP_TAC THEN ASM_REWRITE_TAC[o_THM]; ALL_TAC]
   THEN DISCH_THEN (fun th1 -> (USE_THEN "F1" (fun th2 -> (MP_TAC (MATCH_MP EQ_TRANS (CONJ th2 (SYM th1)) )))))
   THEN DISCH_TAC THEN USE_THEN "H3" (MP_TAC o ISPECL[`(f:A->A) (x:A)`; `x:A`] o MATCH_MP PERMUTES_INJECTIVE)
   THEN POP_ASSUM (fun th -> REWRITE_TAC[th]));;

let fixed_point_lemma = prove(`!(D:A->bool) (p:A->A). p permutes D ==> (!(x:A). p x = x <=> inverse p x = x)`,
   REPEAT STRIP_TAC THEN EQ_TAC
   THENL[POP_ASSUM (fun th1 -> (DISCH_THEN(fun th2 -> (MP_TAC(MATCH_MP inverse_function (CONJ th1 th2))))))
   THEN DISCH_THEN (fun th-> REWRITE_TAC[SYM th]); ALL_TAC]
   THEN DISCH_THEN (MP_TAC o AP_TERM `p:A->A`)
   THEN GEN_REWRITE_TAC (LAND_CONV o LAND_CONV) [GSYM o_THM]
   THEN (POP_ASSUM (ASSUME_TAC o CONJUNCT1 o MATCH_MP PERMUTES_INVERSES_o))
   THEN ASM_REWRITE_TAC[I_THM] THEN DISCH_THEN (fun th-> REWRITE_TAC[SYM th]));;

let non_fixed_point_lemma = prove(`!(s:A->bool) (p:A->A). p permutes s ==> (!(x:A). ~(p x = x) <=> ~(inverse p x = x))`,
   REPEAT STRIP_TAC THEN REWRITE_TAC[TAUT `(~p <=> ~q) <=> (p <=> q)`] 
   THEN ASM_MESON_TAC[fixed_point_lemma]);;

let lemma_inverse_maps_at_nondegenerate_dart = prove(`!(H:(A)hypermap) (x:A). dart_nondegenerate H x ==> ~((inverse (edge_map H) x) = x) /\ ~((inverse (node_map H) x) = x) /\ ~((inverse (face_map H) x) = x)`,
     REPEAT GEN_TAC THEN REWRITE_TAC[dart_nondegenerate]
     THEN MESON_TAC[hypermap_lemma; non_fixed_point_lemma]);;

let aux_permutes_conversion = prove(
`!(D:A->bool) (p:A->A) (q:A->A) (x:A) (y:A). (p permutes D) /\ (q permutes D) ==> ((inverse p)((inverse q) x) = y <=> q ( p y) = x)`,

   REPEAT GEN_TAC THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F1") (LABEL_TAC "F2")) 
   THEN USE_THEN "F1" (MP_TAC o ISPECL[`y:A`; `inverse(q:A->A) (x:A)`] o MATCH_MP PERMUTES_INVERSE_EQ)
   THEN DISCH_THEN (fun th -> REWRITE_TAC[th]) 
   THEN USE_THEN "F2" (MP_TAC o ISPECL[`(p:A->A) (y:A)`; `(x:A)`] o MATCH_MP PERMUTES_INVERSE_EQ)
   THEN MESON_TAC[]);;


let  edge_map_walkup   = prove(`!(H:(A)hypermap) (x:A) (y:A). edge_map (edge_walkup H x) x = x /\ ( ~(node_map H x = x) /\ ~(edge_map H x = x) ==> edge_map (edge_walkup H x) (node_map H x) = edge_map H x) /\ (~(inverse (face_map H)  x = x) /\ ~(inverse(edge_map H) x = x)  ==> edge_map (edge_walkup H x) (inverse(edge_map H) x) = inverse(face_map H) x) /\ (~(y = x) /\ ~(y = (inverse (edge_map H)) x) /\ ~(y = (node_map H) x) ==> (edge_map (edge_walkup H x)) y = edge_map H y)`,
   REPEAT GEN_TAC THEN label_hypermap_TAC `H:(A)hypermap` THEN label_hypermapG_TAC `(edge_walkup (H:(A)hypermap) (x:A))`
   THEN LABEL_TAC "A1" (SPECL[`H:(A)hypermap`;`x:A`] node_map_walkup) THEN LABEL_TAC "A2" (SPECL[`H:(A)hypermap`;`x:A`] face_map_walkup)
   THEN ABBREV_TAC `D = dart (H:(A)hypermap)` 
   THEN ABBREV_TAC `e = edge_map (H:(A)hypermap)` 
   THEN ABBREV_TAC `n = node_map (H:(A)hypermap)` 
   THEN ABBREV_TAC `f = face_map (H:(A)hypermap)`
   THEN ABBREV_TAC `G = edge_walkup (H:(A)hypermap) (x:A)` 
   THEN ABBREV_TAC `D' = dart (G:(A)hypermap)`
   THEN ABBREV_TAC `e' = edge_map (G:(A)hypermap)` 
   THEN ABBREV_TAC `n' = node_map (G:(A)hypermap)` 
   THEN ABBREV_TAC `f' = face_map (G:(A)hypermap)`
   THEN MP_TAC(CONJUNCT1 (SPEC `G:(A)hypermap` inverse2_hypermap_maps))
   THEN ASM_REWRITE_TAC[] THEN DISCH_THEN SUBST_ALL_TAC THEN REWRITE_TAC[o_THM] 
   THEN STRIP_TAC
   THENL[REMOVE_THEN "A1" (MP_TAC o CONJUNCT1 o SPEC `y:A`)
      THEN DISCH_THEN (fun th -> (USE_THEN "G3" (fun th1 ->MP_TAC (MATCH_MP inverse_function (CONJ th1 th)))))
      THEN DISCH_THEN (SUBST1_TAC o SYM) THEN REMOVE_THEN "A2" (MP_TAC o CONJUNCT1 o SPEC `y:A`)
      THEN DISCH_THEN (fun th -> (USE_THEN "G4" (fun th1 ->MP_TAC (MATCH_MP inverse_function (CONJ th1 th)))))
      THEN DISCH_THEN (fun th -> REWRITE_TAC[SYM th]); ALL_TAC]
   THEN STRIP_TAC 
   THENL[MP_TAC (SPECL[`D':A->bool`; `f':A->A`; `n':A->A`; `(n:A->A) (x:A)`; `(e:A->A) (x:A)`] aux_permutes_conversion)
      THEN ASM_REWRITE_TAC[] THEN DISCH_THEN (fun th-> REWRITE_TAC[th])
      THEN  STRIP_TAC 
      THEN SUBGOAL_THEN `~((e:A->A) (x:A) = inverse (f:A->A) x)` ASSUME_TAC
      THENL[UNDISCH_THEN `~((n:A->A) (x:A) = x)` (MP_TAC o GSYM)
         THEN REWRITE_TAC[CONTRAPOS_THM]
         THEN USE_THEN "H2" (MP_TAC o SYM o  SPECL[`x:A`; `inverse(f:A->A) x:A`] o  MATCH_MP PERMUTES_INVERSE_EQ)
         THEN DISCH_THEN(fun th -> REWRITE_TAC[th])
         THEN GEN_REWRITE_TAC (LAND_CONV o LAND_CONV) [GSYM o_THM]
         THEN MP_TAC (CONJUNCT1(CONJUNCT2(SPECL[`H:(A)hypermap`] inverse2_hypermap_maps)))
         THEN ASM_REWRITE_TAC[]
         THEN DISCH_THEN (fun th -> REWRITE_TAC[SYM th])
         THEN DISCH_THEN (fun th -> MP_TAC (SYM th)) THEN SIMP_TAC[]; ALL_TAC]
     THEN REMOVE_THEN "A2" (MP_TAC o CONJUNCT2 o CONJUNCT2 o SPEC `(e:A->A) (x:A)`)
     THEN ASM_REWRITE_TAC[] THEN DISCH_THEN (fun th -> REWRITE_TAC[th])
     THEN MP_TAC(CONJUNCT1(CONJUNCT2(SPEC `H:(A)hypermap` inverse_hypermap_maps)))
     THEN ASM_REWRITE_TAC[] THEN DISCH_THEN(fun th -> MP_TAC(SYM(AP_THM th `x:A`)))
     THEN REWRITE_TAC[o_THM] THEN DISCH_THEN (fun th -> REWRITE_TAC[th])
     THEN REMOVE_THEN "A1" (MP_TAC o CONJUNCT1 o CONJUNCT2 o SPEC `x:A`) THEN REWRITE_TAC[]; ALL_TAC]
   THEN STRIP_TAC
   THENL[STRIP_TAC THEN MP_TAC (SPECL[`D':A->bool`; `f':A->A`; `n':A->A`; `inverse (e:A->A) (x:A)`; `inverse(f:A->A) (x:A)`] aux_permutes_conversion)
     THEN ASM_REWRITE_TAC[]
     THEN DISCH_THEN (fun th-> REWRITE_TAC[th])
     THEN SUBGOAL_THEN `~((f:A->A) (x:A) = inverse (n:A->A) x)` ASSUME_TAC
     THENL[POP_ASSUM MP_TAC THEN REWRITE_TAC[CONTRAPOS_THM]
        THEN USE_THEN "H4" (MP_TAC o SYM o  SPECL[`x:A`; `inverse(n:A->A) x:A`] o  MATCH_MP PERMUTES_INVERSE_EQ)
        THEN DISCH_THEN(fun th -> REWRITE_TAC[th])
        THEN GEN_REWRITE_TAC (LAND_CONV o LAND_CONV) [GSYM o_THM]
        THEN MP_TAC (CONJUNCT1(SPECL[`H:(A)hypermap`] inverse2_hypermap_maps))
        THEN ASM_REWRITE_TAC[]
        THEN DISCH_THEN (fun th -> REWRITE_TAC[SYM th])
        THEN STRIP_TAC THEN USE_THEN "H2" (MP_TAC o SPEC `x:A` o MATCH_MP fixed_point_lemma)
        THEN POP_ASSUM (fun th -> REWRITE_TAC[th]); ALL_TAC]
     THEN SUBGOAL_THEN `~((f:A->A) (x:A) = x)` ASSUME_TAC
     THENL[UNDISCH_TAC `~(inverse (f:A->A) (x:A) = x)`
        THEN REWRITE_TAC[CONTRAPOS_THM]
        THEN STRIP_TAC THEN USE_THEN "H4" (MP_TAC o SPEC `x:A` o MATCH_MP fixed_point_lemma)
        THEN POP_ASSUM (fun th -> REWRITE_TAC[th]); ALL_TAC]
     THEN REMOVE_THEN "A1" (MP_TAC o CONJUNCT2 o CONJUNCT2 o SPEC `(f:A->A) (x:A)`)
     THEN ASM_REWRITE_TAC[] THEN DISCH_THEN (fun th -> REWRITE_TAC[th])
     THEN GEN_REWRITE_TAC (LAND_CONV) [GSYM o_THM]
     THEN MP_TAC(CONJUNCT1(SPEC `H:(A)hypermap` inverse_hypermap_maps))
     THEN ASM_REWRITE_TAC[] THEN  DISCH_THEN(fun th -> REWRITE_TAC[SYM th]); ALL_TAC]
   THEN STRIP_TAC THEN MP_TAC (ISPECL[`D':A->bool`; `f':A->A`; `n':A->A`; `y:A`; `(e:A->A) (y:A)`] aux_permutes_conversion)
   THEN ASM_REWRITE_TAC[] THEN DISCH_THEN (fun th -> REWRITE_TAC[th])
   THEN SUBGOAL_THEN `~((e:A->A) (y:A) = (inverse (f:A->A)) (x:A))` ASSUME_TAC
   THENL[STRIP_TAC THEN UNDISCH_THEN `~((y:A) = (n:A->A) (x:A))` MP_TAC THEN REWRITE_TAC[] 
      THEN POP_ASSUM (MP_TAC o AP_TERM `inverse (e:A->A)`)
      THEN GEN_REWRITE_TAC (LAND_CONV o LAND_CONV) [GSYM o_THM]
      THEN USE_THEN "H2" (MP_TAC o CONJUNCT2 o MATCH_MP PERMUTES_INVERSES_o)
      THEN DISCH_THEN (fun th-> REWRITE_TAC[th; I_THM])
      THEN GEN_REWRITE_TAC (LAND_CONV o RAND_CONV) [GSYM o_THM]
      THEN MP_TAC (CONJUNCT1(CONJUNCT2(SPEC `H:(A)hypermap` inverse2_hypermap_maps)))
      THEN ASM_REWRITE_TAC[] THEN DISCH_THEN (fun th -> REWRITE_TAC[SYM th]); ALL_TAC]
   THEN SUBGOAL_THEN `~((e:A->A) (y:A) = (x:A))` ASSUME_TAC
   THENL[UNDISCH_TAC `~(y:A = inverse (e:A->A) (x:A))`
      THEN REWRITE_TAC[CONTRAPOS_THM] 
      THEN DISCH_THEN (fun th -> (USE_THEN "H2" (fun th1 -> (MP_TAC (MATCH_MP inverse_function (CONJ th1 th))))))
      THEN REWRITE_TAC[]; ALL_TAC]
   THEN REMOVE_THEN "A2" (MP_TAC o CONJUNCT2 o CONJUNCT2 o SPEC `(e:A->A) (y:A)`)
   THEN ASM_REWRITE_TAC[] THEN GEN_REWRITE_TAC (LAND_CONV o RAND_CONV) [GSYM o_THM] 
   THEN MP_TAC(CONJUNCT1(CONJUNCT2(SPEC `H:(A)hypermap` inverse_hypermap_maps)))
   THEN ASM_REWRITE_TAC[] THEN DISCH_THEN (fun th -> REWRITE_TAC[SYM th])
   THEN SUBGOAL_THEN `~(inverse (n:A->A) (y:A) = inverse (n:A->A) (x:A))` ASSUME_TAC
   THENL[UNDISCH_TAC `~(y:A = x:A)` THEN REWRITE_TAC[CONTRAPOS_THM] THEN USE_THEN "H3" (MP_TAC o MATCH_MP PERMUTES_INVERSE)
      THEN DISCH_THEN (MP_TAC o ISPECL[`y:A`; `x:A`] o MATCH_MP PERMUTES_INJECTIVE)
      THEN MESON_TAC[]; ALL_TAC]
   THEN SUBGOAL_THEN `~(inverse (n:A->A) (y:A) = x:A)` ASSUME_TAC
   THENL[UNDISCH_TAC `~(y:A = (n:A->A) (x:A))` 
      THEN REWRITE_TAC[CONTRAPOS_THM]
      THEN DISCH_THEN (MP_TAC o AP_TERM `n:A->A`)
      THEN GEN_REWRITE_TAC (LAND_CONV o LAND_CONV) [GSYM o_THM]
      THEN USE_THEN "H3" (MP_TAC o CONJUNCT1 o MATCH_MP PERMUTES_INVERSES_o)
      THEN DISCH_THEN (fun th -> REWRITE_TAC[th; I_THM]); ALL_TAC]
   THEN DISCH_TAC THEN REMOVE_THEN "A1" (MP_TAC o CONJUNCT2 o CONJUNCT2 o SPEC `(inverse (n:A->A)) (y:A)`)
   THEN ASM_REWRITE_TAC[] THEN GEN_REWRITE_TAC (LAND_CONV o RAND_CONV) [GSYM o_THM] 
   THEN USE_THEN "H3" (MP_TAC o CONJUNCT1 o MATCH_MP PERMUTES_INVERSES_o)
   THEN DISCH_THEN (fun th -> REWRITE_TAC[th; I_THM]));;


(* We describe the cycle structure for a permutation on a finite set *)


let CARD_SINGLETON = prove(`!x:A. CARD{x} = 1`,  GEN_TAC THEN ASSUME_TAC (CONJUNCT1 CARD_CLAUSES)
  THEN ASSUME_TAC (CONJUNCT1 FINITE_RULES) THEN MP_TAC(SPECL[`x:A`;`{}:A->bool`] (CONJUNCT2 CARD_CLAUSES))
  THEN ASM_REWRITE_TAC[NOT_IN_EMPTY] THEN ARITH_TAC);;

let FINITE_SINGLETON = prove(`!x:A. FINITE {x}`, 
  REPEAT STRIP_TAC THEN ASSUME_TAC (CONJUNCT1 FINITE_RULES)
  THEN MP_TAC (ISPECL[`x:A`; `{}:A->bool`] (CONJUNCT2 FINITE_RULES))
  THEN ASM_REWRITE_TAC[]);;

let CARD_TWO_ELEMENTS = prove(`!x:A y:A. ~(x = y) ==> CARD {x ,y} = 2`,
  REPEAT STRIP_TAC
  THEN ASSUME_TAC(SPEC `y:A` FINITE_SINGLETON)
  THEN ASSUME_TAC(SPEC `y:A` CARD_SINGLETON)
  THEN MP_TAC(SPECL[`x:A`; `{y:A}`] (CONJUNCT2 CARD_CLAUSES))
  THEN ASM_REWRITE_TAC[IN_SING; TWO]);;

let FINITE_TWO_ELEMENTS = prove(`!x:A y:A. FINITE {x ,y}`,
  REPEAT STRIP_TAC THEN ASSUME_TAC(SPEC `y:A` FINITE_SINGLETON)
  THEN MP_TAC(SPECL[`x:A`; `{y:A}`] (CONJUNCT2 FINITE_RULES))
  THEN ASM_REWRITE_TAC[]);;

let CARD_ATLEAST_1 = prove(`!s:A->bool x:A. FINITE s /\ x IN s ==> 1 <= CARD s`,
  REPEAT STRIP_TAC
  THEN SUBGOAL_THEN `{x:A} SUBSET s` ASSUME_TAC
  THENL[SET_TAC[]; ALL_TAC]
  THEN ASSUME_TAC(SPEC `x:A` CARD_SINGLETON)
  THEN MP_TAC (SPECL[`{x:A}`; `s:A->bool`] CARD_SUBSET)
  THEN ASM_REWRITE_TAC[]);;

let CARD_ATLEAST_2 = prove(`!s:A->bool x:A y:A. FINITE s /\ x IN s /\ y IN s /\ ~(x = y) ==> 2 <= CARD s`,
  REPEAT STRIP_TAC
  THEN SUBGOAL_THEN `{x:A, y:A} SUBSET s` ASSUME_TAC
  THENL[SET_TAC[]; ALL_TAC]
  THEN MP_TAC(SPECL[`x:A`;`y:A`] CARD_TWO_ELEMENTS)
  THEN ASM_REWRITE_TAC[]
  THEN DISCH_THEN (SUBST1_TAC o SYM)
  THEN MP_TAC(SPECL[`{x:A, y:A}`; `s:A->bool`] CARD_SUBSET)
  THEN ASM_REWRITE_TAC[]);;

let elim_power_function = prove(
   `!s:A->bool p:A->A x:A n:num m:num. p permutes s /\ (p POWER (m+n)) x = (p POWER m) x 
   ==> (p POWER n) x = x`,
  REPEAT GEN_TAC THEN DISCH_THEN(CONJUNCTS_THEN2 (LABEL_TAC "c1") (MP_TAC)) 
  THEN REWRITE_TAC[addition_exponents; o_THM] THEN DISCH_TAC 
  THEN REMOVE_THEN "c1" (ASSUME_TAC o (SPEC `m:num`) o MATCH_MP power_permutation) 
  THEN POP_ASSUM (MP_TAC o ISPECL[`((p:A->A) POWER (n:num)) (x:A)`; `x:A` ] o MATCH_MP PERMUTES_INJECTIVE) 
  THEN ASM_REWRITE_TAC[]);;

let orbit_single_lemma = prove(`!f:A->A x:A y:A. orbit_map f y = {x} ==> x = y`,
   REPEAT STRIP_TAC THEN CONV_TAC SYM_CONV
   THEN REWRITE_TAC[GSYM IN_SING]
   THEN POP_ASSUM (SUBST1_TAC o SYM)
   THEN MP_TAC (SPECL[`f:A->A`; `0`; `y:A`] lemma_in_orbit)
   THEN REWRITE_TAC[POWER_0; I_THM]);;

let inj_orbit = new_recursive_definition num_RECURSION 
   `(inj_orbit (p:A->A) (x:A) 0 <=> T) /\ (inj_orbit (p:A->A) (x:A) (SUC n) 
    <=> (inj_orbit p x n) /\ (!j:num. j <= n ==> ~((p POWER (SUC n)) x =  (p POWER j) x)))`;;

let lemma_def_inj_orbit = prove(`!(p:A->A) (x:A) (n:num). (inj_orbit p x n 
   <=> (!i:num j:num. i <= n /\ j < i ==> ~((p POWER i) x = (p POWER j) x)))`,
   REPEAT  GEN_TAC THEN EQ_TAC 
   THENL[SPEC_TAC(`n:num`, `n:num`) THEN INDUCT_TAC
      THENL[REWRITE_TAC[inj_orbit; LE] THEN ARITH_TAC; ALL_TAC]
      THEN POP_ASSUM (LABEL_TAC "F1") THEN REWRITE_TAC[inj_orbit]
      THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F2") (LABEL_TAC "F3"))
      THEN REMOVE_THEN "F1" MP_TAC THEN ASM_REWRITE_TAC[] THEN DISCH_THEN (LABEL_TAC "F4")
      THEN REWRITE_TAC[LE] THEN REPEAT STRIP_TAC
      THENL[UNDISCH_THEN `i:num = SUC (n:num)` SUBST_ALL_TAC 
          THEN REMOVE_THEN "F3" (MP_TAC o SPEC `j:num`)
          THEN REWRITE_TAC[GSYM LT_SUC_LE] THEN ASM_REWRITE_TAC[]; ALL_TAC]
      THEN REMOVE_THEN "F4" (MP_TAC o SPECL[`i:num`; `j:num`])
      THEN ASM_REWRITE_TAC[]; ALL_TAC]
   THEN SPEC_TAC(`n:num`, `n:num`) THEN INDUCT_TAC
   THENL[REWRITE_TAC[inj_orbit; ARITH]; ALL_TAC]
   THEN POP_ASSUM (LABEL_TAC "A1")
   THEN DISCH_THEN (LABEL_TAC "A4")
   THEN SUBGOAL_THEN `!i:num j:num. i <= (n:num) /\ j < i ==> ~((p POWER i)(x:A) = (p POWER j) x)` (LABEL_TAC "C1")
   THENL[REPLICATE_TAC 3 STRIP_TAC THEN MP_TAC(ARITH_RULE `i:num <= n:num ==> i <= SUC n`)
       THEN ASM_REWRITE_TAC[] THEN STRIP_TAC THEN REMOVE_THEN "A4" (MP_TAC o SPECL[`i:num`; `j:num`])
       THEN ASM_SIMP_TAC[]; ALL_TAC]
   THEN REMOVE_THEN "A1" MP_TAC
   THEN POP_ASSUM (fun th -> REWRITE_TAC[th])
   THEN STRIP_TAC THEN ASM_REWRITE_TAC[inj_orbit] THEN REPEAT STRIP_TAC
   THEN REMOVE_THEN "A4" (MP_TAC o SPECL[`SUC (n:num)`; `j:num`])
   THEN ASM_REWRITE_TAC[LE_REFL; LT_SUC_LE]);;

let lemma_sub_inj_orbit = prove(`!(p:A->A) x:A n:num. inj_orbit p x n ==> !m:num. m <= n ==> inj_orbit p x m`,
   REPEAT GEN_TAC THEN REWRITE_TAC[lemma_def_inj_orbit] THEN REPEAT STRIP_TAC
   THEN FIRST_X_ASSUM (MP_TAC o SPECL[`i:num`; `j:num`] o check (is_forall o concl))
   THEN ASM_REWRITE_TAC[] THEN UNDISCH_TAC `m:num <= n:num` THEN UNDISCH_TAC `i:num <= m:num` THEN ARITH_TAC);;

let inj_orbit_step = prove(`!(s:A->bool) (p:A->A) (x:A) (n:num). (p permutes s) /\ (inj_orbit p x n) /\ ~((p POWER (SUC n:num)) x = x) 
                            ==> (inj_orbit p x (SUC n))`,
   REPEAT STRIP_TAC 
   THEN REWRITE_TAC[inj_orbit] THEN ASM_REWRITE_TAC[]
   THEN REPLICATE_TAC 2 STRIP_TAC THEN FIRST_X_ASSUM (MP_TAC o check(is_neg o concl))
   THEN REWRITE_TAC[CONTRAPOS_THM]
   THEN ASM_CASES_TAC `j:num = 0`
   THENL[POP_ASSUM SUBST1_TAC THEN REWRITE_TAC[POWER_0; I_THM]; ALL_TAC]
   THEN UNDISCH_TAC `j:num <= n:num` THEN REWRITE_TAC[GSYM LT_SUC_LE]
   THEN REWRITE_TAC[LT_EXISTS] THEN DISCH_THEN(X_CHOOSE_THEN `d:num` (LABEL_TAC "G"))
   THEN USE_THEN "G" SUBST1_TAC
   THEN UNDISCH_THEN `(p:A->A) permutes (s:A->bool)` (fun th1 -> (DISCH_THEN (fun th2 -> (MP_TAC ( MATCH_MP elim_power_function (CONJ th1 th2))))))
   THEN MP_TAC(ARITH_RULE `~(j = 0) /\ SUC (n:num) = j + SUC (d:num) ==> SUC d <= n`)
   THEN ASM_REWRITE_TAC[]
   THEN REPEAT STRIP_TAC 
   THEN MP_TAC(SPECL[`p:A->A`; `x:A`; `n:num`] lemma_def_inj_orbit)
   THEN ASM_REWRITE_TAC[] THEN DISCH_THEN (MP_TAC o SPECL[`SUC (d:num)`; `0`])
   THEN ASM_REWRITE_TAC[LT_NZ; POWER_0; ARITH; I_THM] THEN ARITH_TAC);;

let lemma_subset_orbit = prove(`!(p:A->A) x:A n:num. {(p POWER (i:num)) x | i <= n} SUBSET orbit_map p x`,
   REPEAT STRIP_TAC THEN REWRITE_TAC[SUBSET] THEN GEN_TAC 
   THEN REWRITE_TAC[orbit_map; IN_ELIM_THM] THEN STRIP_TAC
   THEN EXISTS_TAC `i:num` THEN ASM_REWRITE_TAC[] THEN ARITH_TAC);;

let lemma_segment_orbit = prove(`!(s:A->bool) (p:A->A) (x:A). FINITE s /\ p permutes s ==> (!m:num. m < CARD(orbit_map p x) ==> inj_orbit p x m)`,
   REPLICATE_TAC 4 STRIP_TAC THEN INDUCT_TAC
   THENL[REWRITE_TAC[inj_orbit]; ALL_TAC]
   THEN POP_ASSUM (LABEL_TAC "F1") THEN DISCH_THEN (LABEL_TAC "F2")
   THEN MP_TAC (ARITH_RULE `SUC (m:num) < CARD (orbit_map (p:A->A) (x:A)) ==> m < CARD (orbit_map p x)`)
   THEN ASM_REWRITE_TAC[] THEN STRIP_TAC THEN REMOVE_THEN "F1" MP_TAC THEN POP_ASSUM (fun th-> REWRITE_TAC[th]) THEN STRIP_TAC
   THEN MATCH_MP_TAC inj_orbit_step
   THEN EXISTS_TAC `s:A->bool` THEN ASM_REWRITE_TAC[] THEN STRIP_TAC
   THEN MP_TAC(SPECL[`p:A->A`; `SUC (m:num)`; `x:A`] card_orbit_le)
   THEN ASM_REWRITE_TAC[ARITH_RULE `~(SUC(d:num) = 0)`]
   THEN  REMOVE_THEN "F2" MP_TAC THEN ARITH_TAC);;

let lemma_cycle_orbit = prove(`!(s:A->bool) (p:A->A) (x:A). FINITE s /\ p permutes s  ==> (p POWER (CARD(orbit_map p x))) x = x`,
   REPEAT STRIP_TAC
   THEN MP_TAC(SPECL[`s:A->bool`; `p:A->A`; `x:A`] lemma_segment_orbit)
   THEN ASM_REWRITE_TAC[] THEN DISCH_THEN (MP_TAC o SPEC `PRE(CARD(orbit_map (p:A->A) (x:A)))`)
   THEN ABBREV_TAC `n = CARD(orbit_map (p:A->A) (x:A))` THEN MP_TAC (SPECL[`p:A->A`; `x:A`] orbit_reflect) THEN ASM_REWRITE_TAC[]
   THEN STRIP_TAC
   THEN MP_TAC (SPECL[`s:A->bool`; `p:A->A`] lemma_orbit_finite) 
   THEN ASM_REWRITE_TAC[] THEN DISCH_THEN (MP_TAC o SPEC `x:A`) THEN ASM_REWRITE_TAC[]
   THEN STRIP_TAC THEN MP_TAC(SPECL[`orbit_map (p:A->A) (x:A)`;`x:A`] lemma_card_atleast_one) 
   THEN ASM_REWRITE_TAC[] THEN STRIP_TAC
   THEN MP_TAC (ARITH_RULE `n:num >= 1 ==> PRE n < n`) THEN ASM_REWRITE_TAC[] 
   THEN DISCH_THEN(fun th-> REWRITE_TAC[th])
   THEN MP_TAC (ARITH_RULE `n:num >= 1 ==> n = (PRE n) + 1`)
   THEN ABBREV_TAC `m = PRE (n:num)` THEN ASM_REWRITE_TAC[] 
   THEN UNDISCH_THEN `(p:A->A) permutes (s:A->bool)` (LABEL_TAC "F1")
   THEN DISCH_THEN (LABEL_TAC "F2")
   THEN STRIP_TAC THEN MP_TAC(SPECL[`p:A->A`; `x:A`;`m:num`] lemma_def_inj_orbit)
   THEN ASM_REWRITE_TAC[] THEN DISCH_THEN (LABEL_TAC "F2") 
   THEN UNDISCH_THEN `CARD(orbit_map (p:A->A) (x:A)) = n:num` MP_TAC
   THEN ONCE_REWRITE_TAC[GSYM CONTRAPOS_THM] THEN STRIP_TAC THEN STRIP_TAC
   THEN SUBGOAL_THEN `!i:num j:num. i < (m:num) + 2 /\ j < i ==> ~((p POWER i) (x:A) = (p POWER j) x)` ASSUME_TAC
   THENL[REPEAT STRIP_TAC THEN MP_TAC(ARITH_RULE `i:num < (m:num) +2 ==> i = m + 1 \/ i <= m`)
      THEN ASM_REWRITE_TAC[] THEN STRIP_TAC
      THENL[POP_ASSUM SUBST_ALL_TAC THEN POP_ASSUM MP_TAC
         THEN ASM_CASES_TAC `j:num = 0`
         THENL[POP_ASSUM SUBST_ALL_TAC THEN ASM_REWRITE_TAC[POWER; I_THM]; ALL_TAC]
         THEN UNDISCH_TAC `j:num <(m:num)+1`
         THEN REWRITE_TAC[LT_EXISTS] THEN DISCH_THEN( X_CHOOSE_THEN `d:num` ASSUME_TAC) 
         THEN MP_TAC(ARITH_RULE `(m:num)+1 = (j:num) + SUC (d:num) ==> m = j + d`)
         THEN POP_ASSUM(fun th->REWRITE_TAC[th])
         THEN DISCH_THEN SUBST_ALL_TAC THEN STRIP_TAC
         THEN MP_TAC(SPECL[`s:A->bool`; `p:A->A`; `x:A`; `SUC (d:num)`;`(j:num)`] elim_power_function)
         THEN ASM_REWRITE_TAC[] THEN  REMOVE_THEN "F2" (MP_TAC o SPECL[`SUC (d:num)`; `0`])
         THEN MP_TAC(ARITH_RULE `~(j:num = 0) ==> SUC (d:num) <= j + d`)
         THEN ASM_REWRITE_TAC[LT_0]
         THEN DISCH_THEN (fun th -> REWRITE_TAC[th])
         THEN REWRITE_TAC[POWER; I_THM]; ALL_TAC]
     THEN REMOVE_THEN "F2" (MP_TAC o SPECL[`i:num`; `j:num`])
     THEN ASM_REWRITE_TAC[]; ALL_TAC]
   THEN MP_TAC (SPECL[`(m:num)+2`; `(\k:num. ((p:A->A) POWER k) (x:A))`] CARD_FINITE_SERIES_EQ)
   THEN ASM_REWRITE_TAC[] THEN REWRITE_TAC[ARITH_RULE `i:num < (m:num) + 2 <=> i <= m + 1`]
   THEN STRIP_TAC THEN ASSUME_TAC(ISPECL[`p:A->A`; `x:A`; `(m:num) +1`] lemma_subset_orbit)
   THEN MP_TAC (ISPECL[`{((p:A->A) POWER (i:num)) (x:A) | i <= (m:num) + 1}`;`orbit_map (p:A->A) (x:A)`] CARD_SUBSET)
   THEN ASM_REWRITE_TAC[] THEN ARITH_TAC);;

let lemma_card_orbit = prove(`!(s:A->bool) (p:A->A) (x:A) (n:num). 
       (FINITE s /\ p permutes s /\ inj_orbit p x n) /\ (p POWER (SUC n)) x = x ==> CARD(orbit_map p x) = SUC n`,
   REPEAT STRIP_TAC THEN ABBREV_TAC `m = CARD(orbit_map (p:A->A) (x:A))`
   THEN  MP_TAC(SPECL[`p:A->A`; `SUC n:num`; `x:A`] card_orbit_le)
   THEN ASM_REWRITE_TAC[ARITH_RULE `~(SUC (n:num) = 0)`]
   THEN STRIP_TAC
   THEN ASM_CASES_TAC `m:num = SUC n:num`
   THENL[ASM_REWRITE_TAC[]; ALL_TAC]
   THEN MP_TAC(ARITH_RULE `m:num <= SUC (n:num) /\ ~(m = SUC n) ==> m < SUC n`)
   THEN ASM_REWRITE_TAC[] THEN POP_ASSUM MP_TAC THEN REWRITE_TAC[CONTRAPOS_THM]
   THEN STRIP_TAC THEN MP_TAC(SPECL[`s:A->bool`; `p:A->A`; `x:A`] lemma_cycle_orbit)
   THEN ASM_REWRITE_TAC[] THEN MP_TAC (SPECL[`orbit_map (p:A->A) (x:A)`; `x:A`] lemma_card_atleast_one)
   THEN MP_TAC(SPECL[`p:A->A`; `x:A`]  orbit_reflect)
   THEN MP_TAC (SPECL[`s:A->bool`; `p:A->A`; `x:A`] lemma_orbit_finite)
   THEN ASM_REWRITE_TAC[] THEN REPLICATE_TAC 2 (DISCH_THEN(fun th -> REWRITE_TAC[th]))
   THEN STRIP_TAC THEN UNDISCH_TAC `m:num < SUC (n:num)`
   THEN REWRITE_TAC[LT_SUC_LE] THEN STRIP_TAC
   THEN UNDISCH_TAC `inj_orbit (p:A->A) (x:A) (n:num)`
   THEN REWRITE_TAC[lemma_def_inj_orbit]
   THEN DISCH_THEN(MP_TAC o SPECL[`m:num`; `0:num`])
   THEN MP_TAC (ARITH_RULE `m:num >= 1 ==> 0 < m`) THEN ASM_REWRITE_TAC[]
   THEN DISCH_THEN (fun th -> SIMP_TAC[POWER_0; I_THM; th]) THEN SIMP_TAC[]);;

let lemma_add_exponent_function = prove(`!(p:A->A) m:num n:num x:A. (p POWER (m+n)) x =  (p POWER m) ((p POWER n) x)`, 
   REPEAT STRIP_TAC THEN ASSUME_TAC (SPECL[`m:num`;`n:num`; `p:A->A`] addition_exponents)
   THEN POP_ASSUM (fun th -> (MP_TAC(AP_THM th `x:A`))) THEN REWRITE_TAC[o_THM]);;

let iterate_map_valuation = prove(`!(p:A->A) (n:num) (x:A). p ((p POWER n) x) = (p POWER (SUC n)) x`,
   REPEAT STRIP_TAC THEN ASSUME_TAC (SPECL[`n:num`; `p:A->A`] (GSYM COM_POWER))
   THEN POP_ASSUM (fun th -> (MP_TAC (AP_THM th `x:A`)))
   THEN REWRITE_TAC[o_THM]);;

let iterate_map_valuation2 = prove(`!(p:A->A) (n:num) (x:A). (p POWER n) (p x) = (p POWER (SUC n)) x`,
   REPEAT STRIP_TAC THEN ASSUME_TAC (SPECL[`p:A->A`; `n:num`] (CONJUNCT2 POWER))
   THEN POP_ASSUM (fun th -> (MP_TAC (AP_THM th `x:A`)))
   THEN REWRITE_TAC[o_THM; EQ_SYM]);;


let lemma_identity_segment = prove(`!(p:A->A) (q:A->A) (x:A) (n:num). 
   (!i:num. i <= n ==> (q POWER i) x = (p POWER i) x) /\  inj_orbit p x n  ==> inj_orbit q x n`,
   REPLICATE_TAC 3 GEN_TAC THEN INDUCT_TAC
   THENL[REWRITE_TAC[inj_orbit]; ALL_TAC]
   THEN POP_ASSUM (LABEL_TAC "F1") THEN REWRITE_TAC[inj_orbit]
   THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F2") (LABEL_TAC "F3"))
   THEN SUBGOAL_THEN `(!i:num. i <= n:num ==> ((q:A->A) POWER i) (x:A) = ((p:A->A) POWER i) x)` (LABEL_TAC "F4")
   THENL[REPEAT STRIP_TAC
       THEN POP_ASSUM (ASSUME_TAC o MATCH_MP (ARITH_RULE `i:num <= n:num ==> i <= SUC n`))
       THEN REMOVE_THEN "F2" (MP_TAC o SPEC `i:num`)
       THEN ASM_REWRITE_TAC[]; ALL_TAC]
   THEN REMOVE_THEN "F1" MP_TAC
   THEN ASM_REWRITE_TAC[] THEN DISCH_THEN (fun th -> REWRITE_TAC[th])
   THEN REPLICATE_TAC 2 STRIP_TAC
   THEN POP_ASSUM (fun th -> (ASSUME_TAC th THEN ASSUME_TAC(MATCH_MP (ARITH_RULE `i:num <= n:num ==> i <= SUC n`) th)))
   THEN USE_THEN "F2" (MP_TAC o SPEC `j:num`)
   THEN POP_ASSUM (fun th -> REWRITE_TAC[th])
   THEN DISCH_THEN SUBST1_TAC
   THEN USE_THEN "F2" (MP_TAC o SPEC `SUC (n:num)`)
   THEN REWRITE_TAC[LE_REFL] THEN DISCH_THEN SUBST1_TAC
   THEN REMOVE_THEN "F3" (MP_TAC o SPEC `j:num` o CONJUNCT2) 
   THEN POP_ASSUM (fun th -> REWRITE_TAC[th]));;

let is_edge_merge = new_definition `!(H:(A)hypermap) (x:A). is_edge_merge H x <=> dart_nondegenerate H x /\ ~(node_map H x IN edge H x)`;;

let is_node_merge = new_definition `!(H:(A)hypermap) (x:A). is_node_merge H x <=> dart_nondegenerate H x /\ ~(face_map H x IN node H x)`;;

let is_face_merge = new_definition `!(H:(A)hypermap) (x:A). is_face_merge H x <=> dart_nondegenerate H x /\ ~(edge_map H x IN face H x)`;;

let is_edge_split = new_definition `!(H:(A)hypermap) (x:A). is_edge_split H x <=> dart_nondegenerate H x /\  node_map H x IN edge H x`;;

let is_node_split = new_definition  `!(H:(A)hypermap) (x:A). is_node_split H x <=> dart_nondegenerate H x /\  face_map H x IN node H x`;;

let is_face_split = new_definition  `!(H:(A)hypermap) (x:A). is_face_split H x  <=> dart_nondegenerate H x /\  edge_map H x IN face H x`;;

let INVERSE_EVALUATION = prove(`!s:A->bool p:A->A x:A. FINITE s /\ p permutes s ==> ?j:num. (inverse p) x = (p POWER j) x`,
  REPEAT STRIP_TAC
  THEN MP_TAC (SPECL[`s:A->bool`; `p:A->A`] inverse_element_lemma)
  THEN ASM_REWRITE_TAC[]
  THEN DISCH_THEN (X_CHOOSE_THEN `j:num` (fun th -> (ASSUME_TAC (AP_THM th `x:A`))))
  THEN EXISTS_TAC `j:num`
  THEN ASM_REWRITE_TAC[]);;

let lemma_orbit_identity = prove(`!s:A->bool p:A->A  x:A y:A. FINITE s /\ p permutes s /\ y IN orbit_map p x 
   ==> orbit_map p x = orbit_map p y`,
  REPEAT STRIP_TAC
  THEN MP_TAC (SPECL[`s:A->bool`; `p:A->A`] partition_orbit)
  THEN ASM_REWRITE_TAC[]
  THEN DISCH_THEN (MP_TAC o SPECL[`x:A`; `y:A`])
  THEN ASSUME_TAC (SPECL[`p:A->A`; `y:A`] orbit_reflect)
  THEN SUBGOAL_THEN `?z:A.z IN orbit_map (p:A->A) (x:A) INTER orbit_map (p:A->A) (y:A)` MP_TAC
  THENL[MP_TAC (ISPECL[`orbit_map (p:A->A) (x:A)`; `orbit_map (p:A->A) (y:A)`; `y:A`] IN_INTER)
	THEN ASM_REWRITE_TAC[]
	THEN DISCH_TAC THEN EXISTS_TAC `y:A`
	THEN POP_ASSUM (fun th -> REWRITE_TAC[th]); ALL_TAC]
  THEN REWRITE_TAC[MEMBER_NOT_EMPTY]
  THEN DISCH_THEN (fun th -> REWRITE_TAC[th]));;

let lemma_orbit_disjoint = prove(`!s:A->bool p:A->A  x:A y:A. FINITE s /\ p permutes s /\ ~(y IN orbit_map p x) 
   ==> orbit_map p x INTER orbit_map p y = {}`,
  REPEAT STRIP_TAC
  THEN MP_TAC (SPECL[`s:A->bool`; `p:A->A`] partition_orbit)
  THEN ASM_REWRITE_TAC[] THEN DISCH_THEN (MP_TAC o SPECL[`x:A`; `y:A`])
  THEN SUBGOAL_THEN `~(orbit_map (p:A->A) (x:A) = orbit_map (p:A->A) (y:A))` ASSUME_TAC
  THENL[POP_ASSUM MP_TAC
      THEN REWRITE_TAC[CONTRAPOS_THM]
      THEN DISCH_THEN SUBST1_TAC
      THEN REWRITE_TAC[orbit_reflect]; ALL_TAC]
  THEN ASM_REWRITE_TAC[]);;

let INVERSE_POWER_MAP = prove(`!s:A->bool p:A->A n:num. FINITE s /\ p permutes s 
  ==> (inverse p) o (p POWER (SUC n)) = p POWER n`,
  REPEAT STRIP_TAC THEN REWRITE_TAC[COM_POWER; o_ASSOC]
  THEN POP_ASSUM (MP_TAC o CONJUNCT2 o  MATCH_MP PERMUTES_INVERSES_o)
  THEN DISCH_THEN SUBST1_TAC THEN REWRITE_TAC[I_O_ID]);;

let INVERSE_POWER_EVALUATION = prove(`!s:A->bool p:A->A x:A n:num. FINITE s /\ p permutes s 
   ==> (inverse p)((p POWER (SUC n)) x) = (p POWER n) x`,
  REPEAT STRIP_TAC
  THEN MP_TAC (SPECL[`s:A->bool`; `p:A->A`; `n:num`] INVERSE_POWER_MAP)
  THEN ASM_REWRITE_TAC[]
  THEN DISCH_THEN (fun th -> (MP_TAC (AP_THM th `x:A`)))
  THEN REWRITE_TAC[o_THM]);;

let lemma_in_disjoint = prove(`!s:A->bool t:A->bool x:A. s INTER  t = {} /\ x IN s ==> ~(x IN t)`,
  REPEAT STRIP_TAC
  THEN MP_TAC(SPECL[`s:A->bool`; `t:A->bool`; `x:A`] IN_INTER)
  THEN ASM_REWRITE_TAC[] THEN REWRITE_TAC[NOT_IN_EMPTY]);;

let lemma_not_in_orbit = prove(`!s:A->bool p :A->A x:A y:A n:num. FINITE s /\ p permutes s /\ ~(y IN orbit_map p x) ==> ~(y = (p POWER n) x)`,
  REPEAT STRIP_TAC
  THEN FIRST_X_ASSUM (MP_TAC o check (is_neg o concl))
  THEN REWRITE_TAC[]
  THEN REWRITE_TAC[orbit_map; IN_ELIM_THM]
  THEN EXISTS_TAC `n:num` THEN ASM_REWRITE_TAC[GE; LE_0]);;

let lemma_orbit_power = prove(`!(s:A->bool) (p:A->A) (x:A) (n:num). (FINITE s /\ p permutes s) ==> (orbit_map p x = orbit_map p ((p POWER n) x))`,
  REPEAT STRIP_TAC
  THEN MP_TAC(SPECL[`p:A->A`; `n:num`; `x:A`; `((p:A->A) POWER (n:num)) (x:A)` ] in_orbit_lemma)
  THEN SIMP_TAC[] THEN STRIP_TAC
  THEN MP_TAC (SPECL[`s:A->bool`; `p:A->A`; `x:A`; `((p:A->A) POWER (n:num)) (x:A)`] lemma_orbit_identity)
  THEN ASM_REWRITE_TAC[]);;

let lemma_inverse_in_orbit = prove(`!s:A->bool p:A->A x:A. FINITE s /\ p permutes s ==> (inverse p) x IN orbit_map p x`,
  REPEAT GEN_TAC
  THEN DISCH_THEN (fun th -> (ASSUME_TAC th THEN MP_TAC(SPEC `x:A` (MATCH_MP INVERSE_EVALUATION th))))
  THEN DISCH_THEN (X_CHOOSE_THEN `j:num` SUBST1_TAC)
  THEN POP_ASSUM (SUBST1_TAC o SPECL[`x:A`; `j:num`] o MATCH_MP lemma_orbit_power)
  THEN REWRITE_TAC[orbit_reflect]);;


(* merge case *)

let lemma_edge_merge = prove(`!(H:(A)hypermap) (x:A). x IN dart H /\ is_edge_merge H x 
   ==> {x} UNION (edge (edge_walkup H x) (node_map H x)) = (edge H x) UNION (edge H (node_map H x))`,
REPEAT GEN_TAC THEN  REWRITE_TAC[is_edge_merge; dart_nondegenerate; edge]
  THEN STRIP_TAC THEN label_hypermap_TAC `H:(A)hypermap`
  THEN ABBREV_TAC `D = dart (H:(A)hypermap)` 
  THEN ABBREV_TAC `e = edge_map (H:(A)hypermap)` 
  THEN ABBREV_TAC `n = node_map (H:(A)hypermap)` 
  THEN ABBREV_TAC `f = face_map (H:(A)hypermap)`
  THEN ABBREV_TAC `G = edge_walkup (H:(A)hypermap) (x:A)` 
  THEN ABBREV_TAC `D' = dart (G:(A)hypermap)`
  THEN ABBREV_TAC `e' = edge_map (G:(A)hypermap)`
  THEN MP_TAC (SPECL[`e:A->A`; `1`; `x:A`; `(e:A->A) (x:A)`] in_orbit_lemma)
  THEN REWRITE_TAC[POWER_1]
  THEN DISCH_THEN (LABEL_TAC "F1")
  THEN MP_TAC(SPECL[`D:A->bool`; `e:A->A`; `x:A`] INVERSE_EVALUATION)
  THEN ASM_REWRITE_TAC[]
  THEN DISCH_THEN (X_CHOOSE_THEN `j:num`((LABEL_TAC "F2") o MATCH_MP in_orbit_lemma ))
  THEN LABEL_TAC "F3" (SPECL[`e:A->A`; `x:A`] orbit_reflect)
  THEN USE_THEN "H1"(fun th1 -> (USE_THEN "H2" (fun th2 -> (LABEL_TAC "F4" (SPEC `x:A` (MATCH_MP lemma_orbit_finite (CONJ th1 th2)))))))
  THEN MP_TAC (SPECL[`orbit_map (e:A->A) (x:A)`; `x:A`; `(e:A->A) (x:A)`] CARD_ATLEAST_2)
  THEN ASM_REWRITE_TAC[LE_EXISTS; ADD_SYM]
  THEN DISCH_THEN (X_CHOOSE_THEN `r:num` (LABEL_TAC "F5"))
  THEN MP_TAC (SPECL[`e:A->A`; `1`; `(n:A->A) (x:A)`; `(inverse (f:A->A)) (x:A)`] in_orbit_lemma)
  THEN REWRITE_TAC[POWER_1]
  THEN GEN_REWRITE_TAC (LAND_CONV o LAND_CONV o RAND_CONV) [POWER_1; GSYM o_THM]
  THEN REWRITE_TAC[GSYM inverse_hypermap_maps]
  THEN MP_TAC (CONJUNCT2(CONJUNCT2(SPEC `H:(A)hypermap` inverse_hypermap_maps)))
  THEN ASM_REWRITE_TAC[]
  THEN DISCH_THEN (SUBST1_TAC o SYM)
  THEN REWRITE_TAC[] THEN DISCH_THEN (LABEL_TAC "F6")
  THEN LABEL_TAC "F7" (SPECL[`e:A->A`; `(n:A->A) (x:A)`] orbit_reflect)
  THEN USE_THEN "H1"(fun th1 -> (USE_THEN "H2" (fun th2 -> (LABEL_TAC "F8" (SPEC `(n:A->A) (x:A)` (MATCH_MP lemma_orbit_finite (CONJ th1 th2)))))))
  THEN MP_TAC (SPECL[`orbit_map (e:A->A) ((n:A->A) (x:A))`; `(n:A->A) (x:A)`] CARD_ATLEAST_1)
  THEN ASM_REWRITE_TAC[] THEN REWRITE_TAC[LE_EXISTS; ADD_SYM]
  THEN DISCH_THEN (X_CHOOSE_THEN `l:num` (LABEL_TAC "F9"))
  THEN MP_TAC (SPECL[`D:A->bool`; `e:A->A`; `x:A`; `(n:A->A) (x:A)` ] lemma_orbit_disjoint)
   THEN ASM_REWRITE_TAC[] THEN DISCH_THEN (LABEL_TAC "F10")
   THEN MP_TAC(SPECL[`D:A->bool`; `e:A->A`; `(n:A->A) (x:A)`;  `(inverse (f:A->A)) (x:A)`] lemma_orbit_identity)
   THEN ASM_REWRITE_TAC[] THEN DISCH_THEN SUBST_ALL_TAC
   THEN MP_TAC(SPECL[`D:A->bool`; `e:A->A`; `(x:A)`;  `(e:A->A) (x:A)`] lemma_orbit_identity)
   THEN ASM_REWRITE_TAC[] THEN DISCH_THEN SUBST_ALL_TAC
   THEN MP_TAC (SPECL[`D:A->bool`; `e:A->A`; `(e:A->A) (x:A)`] lemma_cycle_orbit)
   THEN ASM_REWRITE_TAC[ARITH_RULE `(r:num)+2 = SUC (r+1)`]
   THEN DISCH_THEN (MP_TAC o AP_TERM `inverse (e:A->A)`)
   THEN MP_TAC(SPECL[`D:A->bool`; `e:A->A`; `(e:A->A) (x:A)`; `(r:num)+1`] INVERSE_POWER_EVALUATION)
   THEN ASM_REWRITE_TAC[]
   THEN DISCH_THEN SUBST1_TAC
   THEN GEN_REWRITE_TAC (LAND_CONV o RAND_CONV) [GSYM o_THM]
   THEN USE_THEN "H2" (fun th-> (REWRITE_TAC[CONJUNCT2 (MATCH_MP PERMUTES_INVERSES_o th); I_THM]))
   THEN DISCH_THEN (fun th -> (LABEL_TAC "F11" th THEN MP_TAC th))
   THEN REWRITE_TAC[GSYM ADD1] THEN DISCH_THEN (MP_TAC o AP_TERM `inverse (e:A->A)`)
   THEN MP_TAC(SPECL[`D:A->bool`; `e:A->A`; `(e:A->A) (x:A)`; `r:num`] INVERSE_POWER_EVALUATION)
   THEN ASM_REWRITE_TAC[] THEN DISCH_THEN SUBST1_TAC
   THEN DISCH_THEN (LABEL_TAC "F12")
   THEN MP_TAC (SPECL[`D:A->bool`; `e:A->A`; `(inverse(f:A->A)) (x:A)`] lemma_cycle_orbit)
  THEN ASM_REWRITE_TAC[GSYM ADD1]
  THEN DISCH_THEN (MP_TAC o AP_TERM `inverse (e:A->A)`)
  THEN MP_TAC(SPECL[`D:A->bool`; `e:A->A`; `inverse((f:A->A)) (x:A)`; `l:num`] INVERSE_POWER_EVALUATION)
  THEN ASM_REWRITE_TAC[] THEN DISCH_THEN SUBST1_TAC
  THEN GEN_REWRITE_TAC (LAND_CONV o RAND_CONV) [GSYM o_THM]
  THEN MP_TAC(CONJUNCT1 (CONJUNCT2(SPEC `H:(A)hypermap` inverse2_hypermap_maps)))
  THEN ASM_REWRITE_TAC[] THEN DISCH_THEN (SUBST1_TAC o SYM)
  THEN DISCH_THEN (LABEL_TAC "F14")
   THEN SUBGOAL_THEN `!v:num. v <= r:num ==> (e POWER v) ((e:A->A) (x:A)) = (e' POWER v) (e x)` (LABEL_TAC "F15")
  THENL[INDUCT_TAC THENL [REWRITE_TAC[LE_0; POWER]; ALL_TAC]
   THEN DISCH_THEN (LABEL_TAC "G1")
   THEN FIRST_X_ASSUM (MP_TAC o check(is_imp o concl))
   THEN USE_THEN "G1"(fun th -> REWRITE_TAC[MATCH_MP (ARITH_RULE `SUC (v:num) <= r:num ==> v <= r`) th])
   THEN DISCH_THEN ((LABEL_TAC "G2") o SYM)
   THEN USE_THEN "H1" (fun th1 -> (USE_THEN "H2" (fun th2 -> (MP_TAC (SPECL[`(e:A->A) (x:A)`] (MATCH_MP lemma_segment_orbit (CONJ th1 th2)))))))
   THEN ASM_REWRITE_TAC[]
   THEN DISCH_THEN (LABEL_TAC "G3")
   THEN USE_THEN "G3" (MP_TAC o SPEC `(r:num)+1`)
   THEN REWRITE_TAC[ARITH_RULE `(r:num)+1 < r + 2`]
   THEN REWRITE_TAC[lemma_def_inj_orbit]
   THEN DISCH_THEN (MP_TAC o SPECL[`(r:num)+1`; `v:num`])
   THEN ASM_REWRITE_TAC[LE_REFL]
   THEN USE_THEN "G1" (fun th -> REWRITE_TAC[MP (ARITH_RULE `SUC (v:num) <= r ==> v < r + 1`) th])
   THEN DISCH_THEN (ASSUME_TAC o GSYM)
   THEN USE_THEN "G3" (MP_TAC o SPEC `r:num`)
   THEN REWRITE_TAC[ARITH_RULE `r:num < r + 2`]
   THEN REWRITE_TAC[lemma_def_inj_orbit]
   THEN DISCH_THEN (MP_TAC o SPECL[`r:num`; `v:num`])
   THEN ASM_REWRITE_TAC[LE_REFL]
   THEN USE_THEN "G1" (fun th -> REWRITE_TAC[MP (ARITH_RULE `SUC (v:num) <= r ==> v < r`) th])
   THEN DISCH_THEN (ASSUME_TAC o GSYM)
   THEN UNDISCH_THEN `~((n:A->A) (x:A) IN orbit_map e (e x))` (fun th1 -> (USE_THEN "H1" (fun th2 -> (USE_THEN "H2" (fun th3 -> (MP_TAC (SPEC `v:num` (MATCH_MP lemma_not_in_orbit (CONJ th2 (CONJ th3 th1))))))))))
   THEN DISCH_THEN (ASSUME_TAC o GSYM)
   THEN REWRITE_TAC[COM_POWER; o_THM]
   THEN REMOVE_THEN "G2" SUBST1_TAC
   THEN MP_TAC (CONJUNCT2(CONJUNCT2(CONJUNCT2(SPECL[`H:(A)hypermap`; `x:A`; `((e:A->A) POWER (v:num)) (e (x:A))`] edge_map_walkup))))
   THEN ASM_REWRITE_TAC[]
   THEN DISCH_THEN(fun th -> REWRITE_TAC[th]); ALL_TAC]
    THEN ABBREV_TAC `y = (inverse (f:A->A)) (x:A)`
   THEN SUBGOAL_THEN `!v:num. v <= l:num ==> ((e:A->A) POWER v) (y:A) = ((e':A->A) POWER v) y` (LABEL_TAC "F16")
   THENL[ INDUCT_TAC THENL[REWRITE_TAC[LE_0; POWER]; ALL_TAC]
       THEN DISCH_THEN (LABEL_TAC "G1")
       THEN FIRST_X_ASSUM (MP_TAC o check(is_imp o concl))
       THEN USE_THEN "G1"(fun th -> REWRITE_TAC[MATCH_MP (ARITH_RULE `SUC (v:num) <= r:num ==> v <= r`) th])
       THEN DISCH_THEN ((LABEL_TAC "G2") o SYM)
       THEN USE_THEN "H1" (fun th1 -> (USE_THEN "H2" (fun th2 -> (MP_TAC (SPECL[`y:A`] (MATCH_MP lemma_segment_orbit (CONJ th1 th2)))))))
       THEN ASM_REWRITE_TAC[]
       THEN DISCH_THEN (LABEL_TAC "G3")
       THEN USE_THEN "G3" (MP_TAC o SPEC `l:num`)
       THEN REWRITE_TAC[ARITH_RULE `(l:num) < l + 1`]
       THEN REWRITE_TAC[lemma_def_inj_orbit]
       THEN DISCH_THEN (MP_TAC o SPECL[`l:num`; `v:num`])
       THEN ASM_REWRITE_TAC[LE_REFL]
       THEN USE_THEN "G1" (fun th -> REWRITE_TAC[MP (ARITH_RULE `SUC (v:num) <= l ==> v < l`) th])
       THEN DISCH_THEN (ASSUME_TAC o GSYM)
       THEN USE_THEN "F10" (fun th1 -> (USE_THEN "F3" (fun th2 -> (MP_TAC (MATCH_MP lemma_in_disjoint (CONJ th1 th2))))))
       THEN DISCH_THEN (fun th1 -> (USE_THEN "H1" (fun th2 -> (USE_THEN "H2" (fun th3 -> (MP_TAC (SPEC `v:num` (MATCH_MP lemma_not_in_orbit (CONJ th2 (CONJ th3 th1))))))))))
       THEN DISCH_THEN (ASSUME_TAC o GSYM)
       THEN USE_THEN "F10" (fun th1 -> (USE_THEN "F2" (fun th2 -> (MP_TAC (MATCH_MP lemma_in_disjoint (CONJ th1 th2))))))
       THEN DISCH_THEN (fun th1 -> (USE_THEN "H1" (fun th2 -> (USE_THEN "H2" (fun th3 -> (MP_TAC (SPEC `v:num` (MATCH_MP lemma_not_in_orbit (CONJ th2 (CONJ th3 th1))))))))))
       THEN DISCH_THEN (ASSUME_TAC o GSYM)
       THEN REWRITE_TAC[COM_POWER; o_THM]
       THEN REMOVE_THEN "G2" SUBST1_TAC
       THEN MP_TAC (CONJUNCT2(CONJUNCT2(CONJUNCT2(SPECL[`H:(A)hypermap`; `x:A`; `((e:A->A) POWER (v:num)) (y:A)`] edge_map_walkup))))
       THEN ASM_REWRITE_TAC[]
       THEN DISCH_THEN(fun th -> REWRITE_TAC[th]); ALL_TAC]
   THEN ABBREV_TAC `z = (e:A->A) (x:A)`
   THEN MP_TAC (CONJUNCT1(CONJUNCT2(SPECL[`H:(A)hypermap`; `x:A`; `((e:A->A) POWER (l:num)) (y:A)`] edge_map_walkup)))
   THEN ASM_REWRITE_TAC[] THEN DISCH_THEN (LABEL_TAC "F17")
   THEN MP_TAC (CONJUNCT1(CONJUNCT2(CONJUNCT2(SPECL[`H:(A)hypermap`; `x:A`; `((e:A->A) POWER (r:num)) (z:A)`] edge_map_walkup))))
   THEN ASM_REWRITE_TAC[] THEN EXPAND_TAC "y"
   THEN USE_THEN "H2" (fun th -> (MP_TAC(SPEC `x:A` (MATCH_MP non_fixed_point_lemma th))))
   THEN USE_THEN "H4" (fun th -> (MP_TAC(SPEC `x:A` (MATCH_MP non_fixed_point_lemma th))))
   THEN ASM_REWRITE_TAC[]
   THEN DISCH_THEN (fun th -> REWRITE_TAC[th])
   THEN DISCH_THEN (fun th -> REWRITE_TAC[th])
   THEN DISCH_THEN (LABEL_TAC "F18")
   THEN USE_THEN "F15" (MP_TAC o SPEC `r:num`)
   THEN REWRITE_TAC[LE_REFL]
   THEN USE_THEN "F12" (fun th -> REWRITE_TAC[th])
   THEN DISCH_THEN (fun th -> (MP_TAC (AP_TERM `e':A->A` (SYM th))))
   THEN USE_THEN "F18" (fun th -> REWRITE_TAC[th])
   THEN GEN_REWRITE_TAC (LAND_CONV o LAND_CONV) [GSYM o_THM]
   THEN REWRITE_TAC [GSYM COM_POWER; ADD1]
   THEN DISCH_THEN (LABEL_TAC "F19")
   THEN USE_THEN "F19"(MP_TAC o AP_TERM `(e':A->A) POWER (l:num)`)
   THEN GEN_REWRITE_TAC (LAND_CONV o LAND_CONV) [GSYM o_THM]
   THEN REWRITE_TAC[GSYM addition_exponents]
   THEN USE_THEN "F16" (MP_TAC o SPEC `l:num`)
   THEN REWRITE_TAC[LE_REFL]
   THEN USE_THEN "F14" (fun th -> REWRITE_TAC[th])
   THEN DISCH_THEN (fun th -> (LABEL_TAC "F20"  (SYM th) THEN REWRITE_TAC[SYM th]))
   THEN DISCH_THEN (LABEL_TAC "F21")
   THEN MP_TAC (SPEC `G:(A)hypermap` hypermap_lemma)
   THEN ASM_REWRITE_TAC[]
   THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F22") (LABEL_TAC "F23" o CONJUNCT1))
   THEN MP_TAC(SPECL[`e':A->A`; `1`; `(n:A->A) (x:A)`; `z:A`] in_orbit_lemma)
   THEN REWRITE_TAC[POWER_1]
   THEN USE_THEN "F17" (fun th -> GEN_REWRITE_TAC (LAND_CONV o LAND_CONV o  DEPTH_CONV) [SYM th])
   THEN REWRITE_TAC[]
   THEN DISCH_THEN (fun th1 -> (USE_THEN "F22" (fun th2 -> (USE_THEN "F23" (fun th3 -> (MP_TAC (MATCH_MP lemma_orbit_identity (CONJ th2 (CONJ th3 th1)))))))))
   THEN DISCH_THEN SUBST1_TAC
   THEN USE_THEN "F21" (MP_TAC o AP_TERM `e':A->A`)
   THEN GEN_REWRITE_TAC (LAND_CONV o LAND_CONV) [GSYM o_THM]
   THEN REWRITE_TAC[GSYM COM_POWER; ARITH_RULE `SUC ((l:num) + (r:num) + 1) = l + r + 2`]
   THEN USE_THEN "F17" (fun th -> REWRITE_TAC[th])
   THEN DISCH_THEN ASSUME_TAC
   THEN MP_TAC (SPECL[`e':A->A`; `(l:num) + (r:num) + 2`; `z:A`] orbit_cyclic)
   THEN POP_ASSUM(fun th -> REWRITE_TAC[th; ARITH_RULE `~((l:num) + (r:num) + 2 = 0)`])
   THEN DISCH_THEN SUBST1_TAC
   THEN USE_THEN "H1" (fun th1 -> (USE_THEN "H2"(fun th2 -> (MP_TAC (SPEC `z:A` (MATCH_MP lemma_cycle_orbit (CONJ th1 th2)))))))
   THEN USE_THEN "F5" (fun th -> REWRITE_TAC[th])
   THEN DISCH_THEN ASSUME_TAC
   THEN MP_TAC (SPECL[`e:A->A`; `(r:num) + 2`; `z:A`] orbit_cyclic)
   THEN POP_ASSUM(fun th -> REWRITE_TAC[th; ARITH_RULE `~((r:num) + 2 = 0)`])
   THEN DISCH_THEN SUBST1_TAC
   THEN USE_THEN "H1" (fun th1 -> (USE_THEN "H2"(fun th2 -> (MP_TAC (SPEC `y:A` (MATCH_MP lemma_cycle_orbit (CONJ th1 th2)))))))
   THEN USE_THEN "F9" (fun th -> REWRITE_TAC[th])
   THEN DISCH_THEN ASSUME_TAC
   THEN MP_TAC (SPECL[`e:A->A`; `(l:num) + 1`; `y:A`] orbit_cyclic)
   THEN POP_ASSUM(fun th -> REWRITE_TAC[th; ARITH_RULE `~((l:num) + 1 = 0)`])
   THEN DISCH_THEN SUBST1_TAC
   THEN REWRITE_TAC[EXTENSION; IN_UNION; IN_SING; IN_ELIM_THM]
   THEN STRIP_TAC THEN EQ_TAC
   THENL[STRIP_TAC
     THENL[DISJ1_TAC THEN EXISTS_TAC `(r:num)+1`
	     THEN POP_ASSUM (fun th -> REWRITE_TAC[ARITH_RULE `(r:num) + 1 < r + 2`; th])
	     THEN USE_THEN "F11" (fun th -> REWRITE_TAC[SYM th]); ALL_TAC]
     THEN POP_ASSUM SUBST1_TAC
     THEN ASM_CASES_TAC `k:num <= r:num`
     THENL[DISJ1_TAC THEN EXISTS_TAC `k:num`
	     THEN FIND_ASSUM (fun th -> (REWRITE_TAC[MP (ARITH_RULE `k:num <= (r:num) ==> k < r + 2`) th])) `k:num <= r:num`
	     THEN USE_THEN "F15" (MP_TAC o SPEC `k:num`)
	     THEN POP_ASSUM (fun th -> REWRITE_TAC[th])
	     THEN DISCH_THEN (fun th -> REWRITE_TAC[SYM th]); ALL_TAC]
     THEN DISJ2_TAC
     THEN POP_ASSUM MP_TAC
     THEN GEN_REWRITE_TAC (LAND_CONV o DEPTH_CONV) [NOT_LE; LT_EXISTS]
     THEN REWRITE_TAC[ADD1]
     THEN DISCH_THEN (X_CHOOSE_THEN `d:num` SUBST_ALL_TAC)
     THEN POP_ASSUM (fun th -> (ASSUME_TAC (MATCH_MP (ARITH_RULE `(r:num)+(d:num) + 1 < (l:num) + r + 2 ==> d < l + 1`) th)))
     THEN EXISTS_TAC `d:num`
     THEN FIND_ASSUM (fun th -> REWRITE_TAC[th]) `d:num < (l:num) + 1`
     THEN POP_ASSUM (fun th -> ASSUME_TAC (MATCH_MP (ARITH_RULE `d:num < (l:num) + 1 ==> d <= l`) th))
     THEN REWRITE_TAC[ARITH_RULE `(r:num)+(d:num) + 1 = d + (r + 1)`]
     THEN MP_TAC(SPECL[`e':A->A`; `d:num`; `(r:num) +1`; `z:A`] lemma_add_exponent_function)
     THEN USE_THEN "F19" SUBST1_TAC
     THEN DISCH_THEN SUBST1_TAC
     THEN USE_THEN "F16" (MP_TAC o SPEC `d:num`)
     THEN POP_ASSUM(fun th-> REWRITE_TAC[th])
     THEN DISCH_THEN(fun th -> REWRITE_TAC[SYM th]); ALL_TAC]
   THEN STRIP_TAC 
   THENL[ASM_CASES_TAC `k:num = (r:num) + 1`
       THENL[POP_ASSUM SUBST_ALL_TAC
	       THEN POP_ASSUM MP_TAC
	       THEN USE_THEN "F11" SUBST1_TAC
	       THEN SIMP_TAC[]; ALL_TAC]
       THEN DISJ2_TAC THEN EXISTS_TAC `k:num`
       THEN MP_TAC(ARITH_RULE `k:num < (r:num) + 2 ==> k < l + r + 2`)
       THEN FIND_ASSUM (fun th -> REWRITE_TAC[th]) `k:num < (r:num) + 2`
       THEN DISCH_THEN (fun th -> REWRITE_TAC[th])
       THEN UNDISCH_THEN `k:num < (r:num) + 2` (fun th1 -> (POP_ASSUM (fun th2 -> (MP_TAC (MATCH_MP (ARITH_RULE `k:num < (r:num) + 2 /\ ~(k = r+1) ==> k <= r`) (CONJ th1 th2))))))
       THEN POP_ASSUM SUBST1_TAC
       THEN DISCH_TAC
       THEN USE_THEN "F15" (MP_TAC o SPEC `k:num`)
       THEN POP_ASSUM(fun th -> REWRITE_TAC[th]); ALL_TAC]
   THEN DISJ2_TAC THEN EXISTS_TAC `(k:num)+ (r:num) +1`
  THEN POP_ASSUM SUBST1_TAC
  THEN MP_TAC (ARITH_RULE `(k:num) < (l:num) + 1 ==> k + (r:num) + 1 < l + r + 2`)
  THEN FIND_ASSUM (fun th-> REWRITE_TAC[th]) `k:num < (l:num) + 1`
  THEN DISCH_THEN (fun th -> REWRITE_TAC[th])
  THEN POP_ASSUM (fun th -> ASSUME_TAC (MP (ARITH_RULE `k:num < (l:num) + 1 ==> k <= l`) th))
  THEN USE_THEN "F16" (MP_TAC o SPEC `k:num`)
  THEN POP_ASSUM (fun th -> REWRITE_TAC[th])
  THEN DISCH_THEN SUBST1_TAC
  THEN USE_THEN "F19" (SUBST1_TAC o SYM)
  THEN REWRITE_TAC[GSYM lemma_add_exponent_function]);;


(* splitting case *)


let lemma_edge_split = prove(`!(H:(A)hypermap) (x:A). x IN dart H /\ is_edge_split H x 
   ==> (~((inverse(face_map H)) x IN edge (edge_walkup H x) (node_map H x))) /\
 (edge H x = {x} UNION (edge (edge_walkup H x) (node_map H x)) UNION (edge (edge_walkup H x) ((inverse (face_map H)) x)))`,
  REPEAT GEN_TAC THEN  REWRITE_TAC[is_edge_split; dart_nondegenerate; edge]
  THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "S1") (CONJUNCTS_THEN2 (CONJUNCTS_THEN2 (LABEL_TAC "S2") (CONJUNCTS_THEN2 (LABEL_TAC "S3") (LABEL_TAC "S4"))) (LABEL_TAC "S5")))
 THEN label_hypermap_TAC `H:(A)hypermap`
  THEN ABBREV_TAC `D = dart (H:(A)hypermap)` 
  THEN ABBREV_TAC `e = edge_map (H:(A)hypermap)` 
  THEN ABBREV_TAC `n = node_map (H:(A)hypermap)` 
  THEN ABBREV_TAC `f = face_map (H:(A)hypermap)`
  THEN ABBREV_TAC `G = edge_walkup (H:(A)hypermap) (x:A)` 
  THEN ABBREV_TAC `D' = dart (G:(A)hypermap)`
  THEN ABBREV_TAC `e' = edge_map (G:(A)hypermap)`
  THEN MP_TAC (SPECL[`e:A->A`; `1`; `x:A`; `(e:A->A) (x:A)`] in_orbit_lemma)
  THEN REWRITE_TAC[POWER_1]
  THEN DISCH_THEN (LABEL_TAC "F1")
  THEN MP_TAC(SPECL[`D:A->bool`; `e:A->A`; `x:A`] INVERSE_EVALUATION)
  THEN ASM_REWRITE_TAC[]
  THEN DISCH_THEN (X_CHOOSE_THEN `j:num`((LABEL_TAC "F2") o MATCH_MP in_orbit_lemma ))
  THEN LABEL_TAC "F3" (SPECL[`e:A->A`; `x:A`] orbit_reflect)
  THEN USE_THEN "H1"(fun th1 -> (USE_THEN "H2" (fun th2 -> (LABEL_TAC "F4" (SPEC `x:A` (MATCH_MP lemma_orbit_finite (CONJ th1 th2)))))))
  THEN MP_TAC (SPECL[`orbit_map (e:A->A) (x:A)`; `x:A`; `(e:A->A) (x:A)`] CARD_ATLEAST_2)
  THEN ASM_REWRITE_TAC[LE_EXISTS; ADD_SYM]
  THEN DISCH_THEN (X_CHOOSE_THEN `r:num` (LABEL_TAC "F5"))
  THEN MP_TAC (SPECL[`e:A->A`; `1`; `(n:A->A) (x:A)`; `(inverse (f:A->A)) (x:A)`] in_orbit_lemma)
  THEN REWRITE_TAC[POWER_1]
  THEN GEN_REWRITE_TAC (LAND_CONV o LAND_CONV o RAND_CONV) [POWER_1; GSYM o_THM]
  THEN MP_TAC (CONJUNCT2(CONJUNCT2(SPEC `H:(A)hypermap` inverse_hypermap_maps)))
  THEN ASM_REWRITE_TAC[]
  THEN DISCH_THEN (SUBST1_TAC o SYM)
  THEN REWRITE_TAC[]
  THEN DISCH_THEN (fun th1 -> (USE_THEN "S5" (fun th2 -> (LABEL_TAC "F6" (MATCH_MP orbit_trans (CONJ th1 th2))))))
  THEN MP_TAC(SPECL[`D:A->bool`; `e:A->A`; `(x:A)`;  `(e:A->A) (x:A)`] lemma_orbit_identity)
  THEN ASM_REWRITE_TAC[] THEN DISCH_THEN SUBST_ALL_TAC
  THEN MP_TAC (SPECL[`D:A->bool`; `e:A->A`; `(e:A->A) (x:A)`] lemma_cycle_orbit)
  THEN ASM_REWRITE_TAC[]
  THEN DISCH_THEN (fun th -> (LABEL_TAC "F7" th  THEN MP_TAC th))
  THEN REWRITE_TAC[ARITH_RULE `(r:num)+2 = SUC (r+1)`]
  THEN DISCH_THEN (MP_TAC o AP_TERM `inverse (e:A->A)`)
  THEN MP_TAC(SPECL[`D:A->bool`; `e:A->A`; `(e:A->A) (x:A)`; `(r:num)+1`] INVERSE_POWER_EVALUATION)
  THEN ASM_REWRITE_TAC[]
  THEN DISCH_THEN SUBST1_TAC
  THEN GEN_REWRITE_TAC (LAND_CONV o RAND_CONV) [GSYM o_THM] 
  THEN USE_THEN "H2" (fun th-> (REWRITE_TAC[CONJUNCT2 (MATCH_MP PERMUTES_INVERSES_o th); I_THM]))
  THEN DISCH_THEN (fun th -> (LABEL_TAC "F8" th THEN MP_TAC th))
  THEN REWRITE_TAC[GSYM ADD1] THEN DISCH_THEN (MP_TAC o AP_TERM `inverse (e:A->A)`)
  THEN MP_TAC(SPECL[`D:A->bool`; `e:A->A`; `(e:A->A) (x:A)`; `r:num`] INVERSE_POWER_EVALUATION)
  THEN ASM_REWRITE_TAC[] THEN DISCH_THEN SUBST1_TAC
  THEN DISCH_THEN (LABEL_TAC "F9")
  THEN MP_TAC (SPECL[`e:A->A`; `(r:num) + 2`; `(e:A->A) (x:A)`] orbit_cyclic)
  THEN USE_THEN "F7" (fun th -> REWRITE_TAC[th; ARITH_RULE `~((r:num) + 2 = 0)`])
  THEN DISCH_THEN (LABEL_TAC "F10")
  THEN SUBGOAL_THEN `?m:num d:num. (r:num) = m + d + 1 /\ ((e:A->A) POWER m) ((e:A->A) (x:A)) = (n:A->A) (x:A)` ASSUME_TAC
  THENL[USE_THEN "S5" MP_TAC
	THEN POP_ASSUM (fun th -> REWRITE_TAC[th])
	THEN REWRITE_TAC[IN_ELIM_THM]
	THEN DISCH_THEN (X_CHOOSE_THEN `m:num` STRIP_ASSUME_TAC)
	THEN UNDISCH_TAC `m:num < (r:num) + 2`
	THEN REWRITE_TAC[LT_EXISTS]
	THEN DISCH_THEN (X_CHOOSE_THEN `n:num` MP_TAC)
	THEN REWRITE_TAC[ADD1; ARITH_RULE `(r:num) + 2 = (m:num) + (n:num) + 1 <=> r + 1 = m + n`]
	THEN ASM_CASES_TAC `n = 0`
        THENL[POP_ASSUM SUBST1_TAC
		THEN REWRITE_TAC[ADD_0]
		THEN DISCH_THEN (SUBST_ALL_TAC o SYM)
		THEN POP_ASSUM MP_TAC
		THEN USE_THEN "F8" (fun th -> REWRITE_TAC[th])
		THEN USE_THEN "S3" (fun th -> REWRITE_TAC[th]); ALL_TAC]
	THEN POP_ASSUM MP_TAC
	THEN REWRITE_TAC[GSYM LT_NZ; LT_EXISTS; ADD1; ADD]
	THEN DISCH_THEN (X_CHOOSE_THEN `n1:num` SUBST_ALL_TAC)
	THEN REWRITE_TAC[ARITH_RULE `(r:num)+1 = (m:num) + (n1:num) + 1 <=> r = m + n1`]
	THEN ASM_CASES_TAC `n1 = 0`
        THENL[POP_ASSUM SUBST1_TAC
		THEN REWRITE_TAC[ADD_0]
		THEN DISCH_THEN SUBST_ALL_TAC
		THEN POP_ASSUM MP_TAC
		THEN POP_ASSUM SUBST1_TAC
		THEN MP_TAC(SPECL[`H:(A)hypermap`; `x:A`] lemma_face_degenarate)
		THEN ASM_SIMP_TAC[]; ALL_TAC]
	THEN POP_ASSUM MP_TAC
	THEN REWRITE_TAC[GSYM LT_NZ; LT_EXISTS; ADD1; ADD]
	THEN DISCH_THEN (X_CHOOSE_THEN `d:num` SUBST_ALL_TAC)
	THEN DISCH_THEN ASSUME_TAC
	THEN EXISTS_TAC `m:num` THEN EXISTS_TAC `d:num`
	THEN ASM_REWRITE_TAC[]; ALL_TAC]
   THEN POP_ASSUM (X_CHOOSE_THEN `m:num` (X_CHOOSE_THEN `d:num` (CONJUNCTS_THEN2 (MP_TAC) (LABEL_TAC "F11"))))
   THEN REWRITE_TAC[ARITH_RULE `(m:num) + (d:num) + 1 = d + m + 1`]
   THEN DISCH_THEN SUBST_ALL_TAC
   THEN USE_THEN "F11" (MP_TAC o AP_TERM `e:A->A`)
   THEN REWRITE_TAC[iterate_map_valuation; ADD1]
   THEN GEN_REWRITE_TAC (LAND_CONV o RAND_CONV) [GSYM o_THM]
   THEN MP_TAC(CONJUNCT2(CONJUNCT2(SPEC `H:(A)hypermap` inverse_hypermap_maps)))
   THEN ASM_REWRITE_TAC[]
   THEN DISCH_THEN (SUBST1_TAC o SYM)
   THEN DISCH_THEN (LABEL_TAC "F12")
   THEN ABBREV_TAC `y:A = (inverse (f:A->A)) (x:A)`
   THEN USE_THEN "F12" (MP_TAC o SYM o AP_TERM `(e:A->A) POWER (d:num)`)
   THEN MP_TAC (SPECL[`e:A->A`; `d:num`; `(m:num) +1`; `(e:A->A) (x:A)`] lemma_add_exponent_function)
   THEN DISCH_THEN (SUBST1_TAC o SYM)
   THEN ASM_REWRITE_TAC[]
   THEN DISCH_THEN (LABEL_TAC "F14")
   THEN SUBST_ALL_TAC (ARITH_RULE `((d:num) +(m:num) + 1)+1 = d + m + 2`)
   THEN SUBST_ALL_TAC (ARITH_RULE `((d:num) +(m:num) + 1)+2 = d + m + 3`)
   THEN ABBREV_TAC `z = (e:A->A) (x:A)`
   THEN USE_THEN "H1" (fun th1 -> (USE_THEN "H2" (fun th2 -> (MP_TAC (SPECL[`(e:A->A) (x:A)`] (MATCH_MP lemma_segment_orbit (CONJ th1 th2)))))))
   THEN FIND_ASSUM (fun th -> REWRITE_TAC[th]) `(e:A->A) (x:A) = z:A`
   THEN ASM_REWRITE_TAC[]
   THEN DISCH_THEN (LABEL_TAC "FINJ")
   THEN SUBGOAL_THEN `!v:num. v <= m:num ==> (e POWER v) (z:A) = (e' POWER v) z` (LABEL_TAC "F15")
   THENL[INDUCT_TAC THENL[REWRITE_TAC[LE_0; POWER]; ALL_TAC]
     THEN DISCH_THEN (LABEL_TAC "G1")
     THEN FIRST_X_ASSUM (MP_TAC o check(is_imp o concl))
     THEN USE_THEN "G1"(fun th -> REWRITE_TAC[MATCH_MP (ARITH_RULE `SUC (v:num) <= r:num ==> v <= r`) th])
     THEN DISCH_THEN ((LABEL_TAC "G2") o SYM)    
     THEN USE_THEN "FINJ" (MP_TAC o SPEC `(d:num) + (m:num)+1`)
     THEN REWRITE_TAC[ARITH_RULE `(d:num) + (m:num)+1 < d+ m + 3`]
     THEN REWRITE_TAC[lemma_def_inj_orbit]
     THEN DISCH_THEN (MP_TAC o SPECL[`(d:num) + (m:num)+1`; `v:num`])
     THEN ASM_REWRITE_TAC[LE_REFL]
     THEN USE_THEN "G1" (fun th -> REWRITE_TAC[MP (ARITH_RULE `SUC (v:num) <= (m:num) ==> v < (d:num) + m + 1`) th])
     THEN DISCH_THEN (ASSUME_TAC o GSYM)
     THEN USE_THEN "FINJ" (MP_TAC o SPEC `m:num`)
     THEN REWRITE_TAC[ARITH_RULE `m:num < (d:num) + m + 3`]
     THEN REWRITE_TAC[lemma_def_inj_orbit]
     THEN DISCH_THEN (MP_TAC o SPECL[`m:num`; `v:num`])
     THEN ASM_REWRITE_TAC[LE_REFL]
     THEN USE_THEN "G1" (fun th -> REWRITE_TAC[MP (ARITH_RULE `SUC (v:num) <= (m:num) ==> v < m`) th])
     THEN DISCH_THEN (ASSUME_TAC o GSYM)
     THEN USE_THEN "FINJ" (MP_TAC o SPEC `(d:num) + (m:num) + 2`)
     THEN REWRITE_TAC[ARITH_RULE `(d:num) + (m:num) + 2 < d + m + 3`]
     THEN REWRITE_TAC[lemma_def_inj_orbit]
     THEN DISCH_THEN (MP_TAC o SPECL[`(d:num) + (m:num) + 2`; `v:num`])
     THEN ASM_REWRITE_TAC[LE_REFL]
     THEN USE_THEN "G1" (fun th -> REWRITE_TAC[MP (ARITH_RULE `SUC (v:num) <= (m:num) ==> v < (d:num) + m + 2`) th])
     THEN DISCH_THEN (ASSUME_TAC o GSYM)
     THEN MP_TAC (CONJUNCT2(CONJUNCT2(CONJUNCT2(SPECL[`H:(A)hypermap`; `x:A`; `((e:A->A) POWER (v:num)) (e (x:A))`] edge_map_walkup))))
     THEN ASM_REWRITE_TAC[]
     THEN REWRITE_TAC[iterate_map_valuation]
     THEN USE_THEN "G2" (SUBST1_TAC o SYM)
     THEN REWRITE_TAC[iterate_map_valuation]
     THEN DISCH_THEN(fun th -> REWRITE_TAC[th]); ALL_TAC]
   THEN SUBGOAL_THEN `!v:num. v <= d:num ==> ((e:A->A) POWER v) (y:A) = ((e':A->A) POWER v) y` (LABEL_TAC "F16")
   THENL[INDUCT_TAC THENL[REWRITE_TAC[LE_0; POWER]; ALL_TAC]
   THEN DISCH_THEN (LABEL_TAC "G1")
   THEN FIRST_X_ASSUM (MP_TAC o check(is_imp o concl))
   THEN USE_THEN "G1"(fun th -> REWRITE_TAC[MATCH_MP (ARITH_RULE `SUC (v:num) <= d:num ==> v <= d`) th])
   THEN DISCH_THEN ((LABEL_TAC "G2") o SYM)
   THEN USE_THEN "FINJ" (MP_TAC o SPEC `(v:num) + (m:num) + 1`)
   THEN USE_THEN "G1" (fun th -> REWRITE_TAC[MATCH_MP (ARITH_RULE `SUC (v:num) <= d:num ==> v + (m:num) + 1 < d + m + 3`) th])
   THEN REWRITE_TAC[lemma_def_inj_orbit]
   THEN DISCH_THEN (MP_TAC o SPECL[`(v:num)+(m:num) + 1`; `m:num`])
   THEN ASM_REWRITE_TAC[LE_REFL]
   THEN ASM_REWRITE_TAC[ARITH_RULE `m:num < (v:num) + m + 1 /\ m + 1 = SUC m`]
   THEN REWRITE_TAC[lemma_add_exponent_function]
   THEN ASM_REWRITE_TAC[ADD1]
   THEN DISCH_TAC
   THEN USE_THEN "FINJ" (MP_TAC o SPEC `(d:num) + (m:num) + 1`)
   THEN REWRITE_TAC[ARITH_RULE `d + (m:num) + 1 < d + m + 3`]
   THEN REWRITE_TAC[lemma_def_inj_orbit]
   THEN DISCH_THEN (MP_TAC o SPECL[`(d:num)+(m:num) + 1`; `(v:num)+(m:num) + 1`])
   THEN ASM_REWRITE_TAC[LE_REFL]
   THEN USE_THEN "G1" (fun th -> REWRITE_TAC[MATCH_MP (ARITH_RULE `SUC (v:num) <= d ==> (v:num) + m + 1 < d + m + 1`) th])
   THEN REWRITE_TAC[GSYM ADD1]
   THEN REWRITE_TAC[lemma_add_exponent_function]
   THEN ASM_REWRITE_TAC[ADD1]
   THEN DISCH_THEN (ASSUME_TAC o GSYM)
   THEN USE_THEN "FINJ" (MP_TAC o SPEC `(d:num) + (m:num) + 2`)
   THEN REWRITE_TAC[ARITH_RULE `d + (m:num) + 2 < d + m + 3`]
   THEN REWRITE_TAC[lemma_def_inj_orbit]
   THEN DISCH_THEN (MP_TAC o SPECL[`(d:num)+(m:num) + 2`; `(v:num)+(m:num) + 1`])
   THEN ASM_REWRITE_TAC[LE_REFL]
   THEN USE_THEN "G1" (fun th -> REWRITE_TAC[MATCH_MP (ARITH_RULE `SUC (v:num) <= d ==> (v:num) + m + 1 < d + m + 2`) th])
   THEN REWRITE_TAC[GSYM ADD1]
   THEN REWRITE_TAC[lemma_add_exponent_function]
   THEN ASM_REWRITE_TAC[ADD1]
   THEN DISCH_THEN (ASSUME_TAC o GSYM)
   THEN REWRITE_TAC[GSYM ADD1]
   THEN MP_TAC (CONJUNCT2(CONJUNCT2(CONJUNCT2(SPECL[`H:(A)hypermap`; `x:A`; `((e:A->A) POWER (v:num) ) (y:A)`] edge_map_walkup))))
   THEN ASM_REWRITE_TAC[]
   THEN REWRITE_TAC[COM_POWER; o_THM]
   THEN USE_THEN "G2" (SUBST1_TAC)
   THEN DISCH_THEN(fun th -> REWRITE_TAC[th]); ALL_TAC]
   THEN MP_TAC (CONJUNCT1(CONJUNCT2(SPECL[`H:(A)hypermap`; `x:A`; `((e:A->A) POWER (m:num)) (x:A)`] edge_map_walkup)))
  THEN ASM_REWRITE_TAC[]
  THEN DISCH_THEN (LABEL_TAC "F17")
  THEN MP_TAC (CONJUNCT1(CONJUNCT2(CONJUNCT2(SPECL[`H:(A)hypermap`; `x:A`; `((e:A->A) POWER ((d:num) + (m:num) + 1)) (x:A)`] edge_map_walkup))))
  THEN ASM_REWRITE_TAC[]
  THEN EXPAND_TAC "y"
  THEN USE_THEN "H2" (fun th -> (MP_TAC(SPEC `x:A` (MATCH_MP non_fixed_point_lemma th))))
  THEN USE_THEN "H4" (fun th -> (MP_TAC(SPEC `x:A` (MATCH_MP non_fixed_point_lemma th))))
  THEN ASM_REWRITE_TAC[]
  THEN DISCH_THEN (fun th -> REWRITE_TAC[th])
  THEN DISCH_THEN (fun th -> REWRITE_TAC[th])
  THEN DISCH_THEN (LABEL_TAC "F18")
  THEN MP_TAC (SPEC `G:(A)hypermap` hypermap_lemma)
  THEN ASM_REWRITE_TAC[]
  THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F19") (LABEL_TAC "F20" o CONJUNCT1))
  THEN MP_TAC(SPECL[`e':A->A`; `1`; `(n:A->A) (x:A)`; `z:A`] in_orbit_lemma)
  THEN REWRITE_TAC[POWER_1]
  THEN USE_THEN "F17" (fun th -> GEN_REWRITE_TAC (LAND_CONV o LAND_CONV o  DEPTH_CONV) [SYM th])
  THEN REWRITE_TAC[]
  THEN DISCH_THEN (fun th1 -> (USE_THEN "F19" (fun th2 -> (USE_THEN "F20" (fun th3 -> (MP_TAC (MATCH_MP lemma_orbit_identity (CONJ th2 (CONJ th3 th1)))))))))
  THEN DISCH_THEN SUBST1_TAC
   THEN USE_THEN "F16" (MP_TAC o GSYM o SPEC `d:num`)
   THEN REWRITE_TAC[LE_REFL]
   THEN DISCH_THEN (MP_TAC o AP_TERM `e':A->A`)
   THEN ASM_REWRITE_TAC[iterate_map_valuation; ADD1]
   THEN DISCH_TAC
   THEN MP_TAC(SPECL[`e':A->A`; `(d:num) + 1`; `y:A`] orbit_cyclic)
   THEN POP_ASSUM (fun th -> REWRITE_TAC[th; ARITH_RULE `~((d:num) + 1 = 0)`])
   THEN DISCH_THEN SUBST_ALL_TAC
   THEN USE_THEN "F15" (MP_TAC o GSYM o SPEC `m:num`)
   THEN REWRITE_TAC[LE_REFL]
   THEN DISCH_THEN (MP_TAC o AP_TERM `e':A->A`)
   THEN ASM_REWRITE_TAC[iterate_map_valuation; ADD1]
   THEN DISCH_TAC
   THEN MP_TAC(SPECL[`e':A->A`; `(m:num) + 1`; `z:A`] orbit_cyclic)
   THEN POP_ASSUM (fun th -> REWRITE_TAC[th; ARITH_RULE `~((m:num) + 1 = 0)`])
   THEN DISCH_THEN SUBST_ALL_TAC
   THEN STRIP_TAC
   THENL[REWRITE_TAC[IN_ELIM_THM; NOT_EXISTS_THM]
	   THEN REPEAT STRIP_TAC
	   THEN USE_THEN "FINJ" (MP_TAC o SPEC `(m:num) + 1`)
	   THEN REWRITE_TAC[ARITH_RULE `(m:num) + 1 < (d:num) + m + 3`]
	   THEN REWRITE_TAC[GSYM ADD1; inj_orbit]
	   THEN DISCH_TAC
	   THEN POP_ASSUM (MP_TAC o SPEC `k:num` o CONJUNCT2)
	   THEN FIND_ASSUM (fun th -> REWRITE_TAC[ADD1; MATCH_MP (ARITH_RULE `k:num < (m:num) + 1 ==> k <= m`) th]) `k:num < (m:num)+ 1`
	   THEN USE_THEN "F12" (fun th -> REWRITE_TAC[th])
	   THEN USE_THEN "F15" (MP_TAC o SPEC `k:num`)
	   THEN FIND_ASSUM (fun th -> REWRITE_TAC[MATCH_MP (ARITH_RULE `k:num < (m:num) + 1 ==> k <= m`) th]) `k:num < (m:num)+ 1`
	   THEN DISCH_THEN SUBST1_TAC
	   THEN POP_ASSUM(fun th -> REWRITE_TAC[th]); ALL_TAC]
   THEN REWRITE_TAC[EXTENSION; IN_ELIM_THM; IN_UNION; IN_SING ]
   THEN GEN_TAC THEN EQ_TAC
   THENL[DISCH_THEN (X_CHOOSE_THEN `k:num` (CONJUNCTS_THEN2 (LABEL_TAC "F30") (LABEL_TAC "F31")))
	  THEN ASM_CASES_TAC `k:num < (m:num) + 1`
	  THENL[POP_ASSUM (LABEL_TAC "F32")
		  THEN  DISJ2_TAC THEN DISJ1_TAC
		  THEN  EXISTS_TAC `k:num`
		  THEN  USE_THEN "F32" ( fun th -> REWRITE_TAC[th])
		  THEN  USE_THEN "F31" ( fun th -> REWRITE_TAC[th])
		  THEN  USE_THEN "F15" (MP_TAC o SPEC `k:num`)
		  THEN  USE_THEN "F32" (fun th -> REWRITE_TAC[MP (ARITH_RULE `k:num < (m:num) + 1 ==> k <= m`) th]); ALL_TAC]
	  THEN  ASM_CASES_TAC `k:num <=(d:num) + (m:num) + 1`
          THENL[DISJ2_TAC THEN DISJ2_TAC
		  THEN  UNDISCH_TAC `~((k:num) < (m:num) + 1)`
		  THEN  REWRITE_TAC[NOT_LT; LE_EXISTS]
		  THEN DISCH_THEN (X_CHOOSE_THEN `v:num` MP_TAC)
		  THEN REWRITE_TAC[ARITH_RULE `((m:num)+1) +(v:num) = v + m + 1`]
		  THEN POP_ASSUM (fun th -> (DISCH_THEN (fun th2 -> ((LABEL_TAC "F33" th2) THEN (LABEL_TAC "F34" (MP (ARITH_RULE `k:num <= (d:num) + (m:num) + 1 /\ k = (v:num) + m + 1 ==> v <= d`) (CONJ th th2)))))))
		  THEN EXISTS_TAC `v:num`
		  THEN USE_THEN "F34" ( fun th -> REWRITE_TAC[MP (ARITH_RULE `v:num <= d:num ==> v < d + 1`)th])
		  THEN USE_THEN "F16" (MP_TAC o SPEC `v:num`)
		  THEN USE_THEN "F34" (fun th -> REWRITE_TAC[th])
		  THEN DISCH_THEN (SUBST1_TAC o SYM)
		  THEN USE_THEN "F12" (SUBST1_TAC o SYM)
		  THEN REWRITE_TAC[GSYM ADD1]
		  THEN REWRITE_TAC[GSYM lemma_add_exponent_function; ADD1]
		  THEN USE_THEN "F33" (SUBST1_TAC o SYM)
		  THEN USE_THEN "F31" (fun th -> REWRITE_TAC[th]); ALL_TAC]
	  THEN DISJ1_TAC
	  THEN REMOVE_THEN "F30" (fun th1 -> (POP_ASSUM (fun th2 -> (ASSUME_TAC (MATCH_MP (ARITH_RULE `~(k:num <= (d:num) + (m:num) + 1) /\ k < d + m + 3 ==> k = d + m + 2`) (CONJ th2 th1))))))
	  THEN REMOVE_THEN "F31" MP_TAC
	  THEN POP_ASSUM SUBST1_TAC
	  THEN USE_THEN "F8" (fun th -> REWRITE_TAC[th]); ALL_TAC]
   THEN STRIP_TAC 
   THENL[EXISTS_TAC `(d:num) + (m:num) + 2`
	   THEN POP_ASSUM SUBST1_TAC 
	   THEN USE_THEN "F8" SUBST1_TAC
	   THEN ARITH_TAC;
           EXISTS_TAC `k:num`
	   THEN POP_ASSUM SUBST1_TAC
	   THEN FIND_ASSUM (fun th -> REWRITE_TAC[MP (ARITH_RULE `k:num < (m:num) + 1 ==> k < (d:num) + m + 3`) th]) `k:num < (m:num) + 1`
           THEN USE_THEN "F15" (MP_TAC o SPEC `k:num`)
	   THEN POP_ASSUM (fun th -> REWRITE_TAC[MP (ARITH_RULE `k:num < (m:num) + 1 ==> k <= m`) th])
	   THEN DISCH_THEN (fun th -> REWRITE_TAC[SYM th]);
           EXISTS_TAC `(k:num) + (m:num) + 1` 
           THEN FIND_ASSUM (fun th -> REWRITE_TAC[MP (ARITH_RULE `(k:num) < (d:num) + 1 ==> k + (m:num) + 1 < d + m + 3`) th]) `k:num < (d:num) + 1`
           THEN REWRITE_TAC[GSYM ADD1]
	   THEN REWRITE_TAC[lemma_add_exponent_function]
	   THEN REWRITE_TAC[ADD1]
	   THEN USE_THEN "F12" SUBST1_TAC
	   THEN POP_ASSUM SUBST1_TAC
	   THEN USE_THEN "F16" (MP_TAC o SPEC `k:num`)
	   THEN POP_ASSUM (fun th -> REWRITE_TAC[MP (ARITH_RULE `(k:num) < (d:num) + 1 ==> k <= d`) th])
	   THEN DISCH_THEN (fun th -> REWRITE_TAC[SYM th])]);;


(* Node *)


let lemma_shift_non_degenerate = prove(`!(H:(A)hypermap) (x:A). dart_nondegenerate H x <=>  dart_nondegenerate (shift H) x`,
    REPEAT GEN_TAC THEN REWRITE_TAC[dart_nondegenerate]
    THEN STRIP_ASSUME_TAC (SPEC `H:(A)hypermap` (GSYM shift_lemma))
    THEN ASM_REWRITE_TAC[] THEN MESON_TAC[]);;


let lemma_change_node_walkup = prove(`!(H:(A)hypermap) (x:A). (is_node_merge H x ==> is_edge_merge (shift H) x) /\ (is_node_split H x ==> is_edge_split (shift H) x)`,
REPEAT GEN_TAC
  THEN STRIP_ASSUME_TAC (SPEC `H:(A)hypermap` (GSYM shift_lemma))
  THEN ASM_REWRITE_TAC[is_node_merge; is_edge_merge; is_node_split; is_edge_split; edge; node]
  THEN STRIP_TAC
  THENL[STRIP_TAC
	  THEN ONCE_ASM_REWRITE_TAC[GSYM lemma_shift_non_degenerate]
	  THEN ASM_REWRITE_TAC[]; ALL_TAC]
  THEN STRIP_TAC
  THEN ONCE_ASM_REWRITE_TAC[GSYM lemma_shift_non_degenerate]
  THEN ASM_REWRITE_TAC[]);;


let lemma_node_merge = prove(`!(H:(A)hypermap) (x:A). x IN dart H /\ is_node_merge H x 
   ==> {x} UNION (node (node_walkup H x) (face_map H x)) = (node H x) UNION (node H (face_map H x))`,
  REPEAT GEN_TAC
  THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F1") (ASSUME_TAC))
  THEN REWRITE_TAC[node_walkup] 
  THEN MP_TAC (CONJUNCT1 (SPECL[`H:(A)hypermap`; `x:A`] lemma_change_node_walkup))
  THEN POP_ASSUM (fun th -> REWRITE_TAC[th])
  THEN DISCH_THEN (LABEL_TAC "F2")
  THEN label_4Gs_TAC (SPEC `H:(A)hypermap` (GSYM shift_lemma))
  THEN REMOVE_THEN "F1" MP_TAC
  THEN USE_THEN "G1" (SUBST1_TAC o SYM)
  THEN DISCH_THEN (LABEL_TAC "F3")
  THEN MP_TAC(SPECL[`shift (H:(A)hypermap)`; `x:A`] lemma_edge_merge)
  THEN ASM_REWRITE_TAC[node; edge]
  THEN STRIP_ASSUME_TAC (GSYM (SPEC `edge_walkup (shift(H:(A)hypermap)) (x:A)` double_shift_lemma))
  THEN ASM_REWRITE_TAC[]);;


let lemma_node_split = prove(`!(H:(A)hypermap) (x:A). x IN dart H /\ is_node_split H x 
   ==> (~((inverse(edge_map H)) x IN node (node_walkup H x) (face_map H x))) /\
 (node H x = {x} UNION (node (node_walkup H x) (face_map H x)) UNION (node (node_walkup H x) ((inverse (edge_map H)) x)))`,
  
  REPEAT GEN_TAC
  THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F1") (ASSUME_TAC))
  THEN REWRITE_TAC[node_walkup] 
  THEN MP_TAC (CONJUNCT2 (SPECL[`H:(A)hypermap`; `x:A`] lemma_change_node_walkup))
  THEN POP_ASSUM (fun th -> REWRITE_TAC[th])
  THEN DISCH_THEN (LABEL_TAC "F2")
  THEN label_4Gs_TAC (SPEC `H:(A)hypermap` (GSYM shift_lemma))
  THEN REMOVE_THEN "F1" MP_TAC
  THEN USE_THEN "G1" (SUBST1_TAC o SYM)
  THEN DISCH_THEN (LABEL_TAC "F3")
  THEN MP_TAC(SPECL[`shift (H:(A)hypermap)`; `x:A`] lemma_edge_split)
  THEN ASM_REWRITE_TAC[node; edge]
  THEN STRIP_ASSUME_TAC (GSYM (SPEC `edge_walkup (shift(H:(A)hypermap)) (x:A)` double_shift_lemma))
  THEN ASM_REWRITE_TAC[]);;


(* face *)


let lemma_double_shift_non_degenerate = prove(`!(H:(A)hypermap) (x:A). dart_nondegenerate H x <=>  dart_nondegenerate (shift(shift H)) x`,
    REPEAT GEN_TAC THEN REWRITE_TAC[dart_nondegenerate]
    THEN STRIP_ASSUME_TAC (SPEC `H:(A)hypermap` (GSYM double_shift_lemma))
    THEN ASM_REWRITE_TAC[] THEN MESON_TAC[]);;


let lemma_change_face_walkup = prove(`!(H:(A)hypermap) (x:A). (is_face_merge H x ==> is_edge_merge (shift(shift H)) x) /\ (is_face_split H x ==> is_edge_split (shift (shift H)) x)`,
REPEAT GEN_TAC
  THEN STRIP_ASSUME_TAC (SPEC `H:(A)hypermap` (GSYM double_shift_lemma))
  THEN ASM_REWRITE_TAC[is_face_merge; is_edge_merge; is_face_split; is_edge_split; edge; face]
  THEN STRIP_TAC
  THENL[STRIP_TAC
	  THEN ONCE_ASM_REWRITE_TAC[GSYM lemma_double_shift_non_degenerate]
	  THEN ASM_REWRITE_TAC[]; ALL_TAC]
  THEN STRIP_TAC
  THEN ONCE_ASM_REWRITE_TAC[GSYM lemma_double_shift_non_degenerate]
  THEN ASM_REWRITE_TAC[]);;


let lemma_face_merge = prove(`!(H:(A)hypermap) (x:A). x IN dart H /\ is_face_merge H x 
   ==> {x} UNION (face (face_walkup H x) (edge_map H x)) = (face H x) UNION (face H (edge_map H x))`,
  REPEAT GEN_TAC
  THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F1") (ASSUME_TAC))
  THEN REWRITE_TAC[face_walkup] 
  THEN MP_TAC (CONJUNCT1 (SPECL[`H:(A)hypermap`; `x:A`] lemma_change_face_walkup))
  THEN POP_ASSUM (fun th -> REWRITE_TAC[th])
  THEN DISCH_THEN (LABEL_TAC "F2")
  THEN label_4Gs_TAC (SPEC `H:(A)hypermap` (GSYM double_shift_lemma))
  THEN REMOVE_THEN "F1" MP_TAC
  THEN USE_THEN "G1" (SUBST1_TAC o SYM)
  THEN DISCH_THEN (LABEL_TAC "F3")
  THEN MP_TAC(SPECL[`shift(shift (H:(A)hypermap))`; `x:A`] lemma_edge_merge)
  THEN ASM_REWRITE_TAC[face; edge]
  THEN STRIP_ASSUME_TAC (GSYM (SPEC `edge_walkup (shift(shift(H:(A)hypermap))) (x:A)` shift_lemma))
  THEN ASM_REWRITE_TAC[]);;

let lemma_face_split = prove(`!(H:(A)hypermap) (x:A). x IN dart H /\ is_face_split H x 
   ==> (~((inverse(node_map H)) x IN face (face_walkup H x) (edge_map H x))) /\
 (face H x = {x} UNION (face (face_walkup H x) (edge_map H x)) UNION (face (face_walkup H x) ((inverse (node_map H)) x)))`,
  
  REPEAT GEN_TAC
  THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F1") (ASSUME_TAC))
  THEN REWRITE_TAC[face_walkup] 
  THEN MP_TAC (CONJUNCT2 (SPECL[`H:(A)hypermap`; `x:A`] lemma_change_face_walkup))
  THEN POP_ASSUM (fun th -> REWRITE_TAC[th])
  THEN DISCH_THEN (LABEL_TAC "F2")
  THEN label_4Gs_TAC (SPEC `H:(A)hypermap` (GSYM double_shift_lemma))
  THEN REMOVE_THEN "F1" MP_TAC
  THEN USE_THEN "G1" (SUBST1_TAC o SYM)
  THEN DISCH_THEN (LABEL_TAC "F3")
  THEN MP_TAC(SPECL[`shift(shift (H:(A)hypermap))`; `x:A`] lemma_edge_split)
  THEN ASM_REWRITE_TAC[face; edge]
  THEN STRIP_ASSUME_TAC (GSYM (SPEC `edge_walkup (shift(shift(H:(A)hypermap))) (x:A)` shift_lemma))
  THEN ASM_REWRITE_TAC[]);;


let lemmaFKSNTKR = prove(`!(H:(A)hypermap) (x:A). simple_hypermap H /\ x IN dart H /\ ~((edge_map H) x = x) /\ (dart_nondegenerate H x)
   /\ dart_nondegenerate H ((edge_map H) x) ==> ((edge_map H) ((edge_map H) x) = x ==> is_face_merge H x) /\ is_node_merge H x`,
  REPEAT GEN_TAC
  THEN REWRITE_TAC[simple_hypermap; dart_nondegenerate; is_face_merge; is_node_merge; node; face; o_THM]
  THEN STRIP_TAC
  THEN ASM_REWRITE_TAC[]
  THEN label_hypermap_TAC `H:(A)hypermap`
  THEN ABBREV_TAC `D = dart (H:(A)hypermap)` 
  THEN ABBREV_TAC `e = edge_map (H:(A)hypermap)` 
  THEN ABBREV_TAC `n = node_map (H:(A)hypermap)` 
  THEN ABBREV_TAC `f = face_map (H:(A)hypermap)`
  THEN FIRST_X_ASSUM (MP_TAC o SPEC `(f:A->A) (x:A)` o check (is_forall o concl))
  THEN USE_THEN "H4" (MP_TAC o SYM o  SPEC `x:A` o MATCH_MP PERMUTES_IN_IMAGE)
  THEN ASM_REWRITE_TAC[]
  THEN DISCH_THEN (fun th -> REWRITE_TAC[th])
  THEN DISCH_THEN (LABEL_TAC "FF")
  THEN STRIP_TAC
  THENL[USE_THEN "H2" (fun th2 -> (DISCH_THEN (fun th3 -> (MP_TAC(MATCH_MP inverse_function (CONJ th2 th3))))))
	  THEN MP_TAC(CONJUNCT1(SPEC `H:(A)hypermap` inverse_hypermap_maps))
	  THEN ASM_REWRITE_TAC[] 
	  THEN DISCH_THEN SUBST1_TAC
	  THEN REWRITE_TAC[o_THM]
	  THEN DISCH_TAC
	  THEN MP_TAC(SPECL[`n:A->A`; `1`;`(f:A->A) (x:A)`; `(e:A->A) (x:A)`] in_orbit_lemma)
	  THEN POP_ASSUM (fun th -> ((ASSUME_TAC (SYM th)) THEN GEN_REWRITE_TAC (LAND_CONV o LAND_CONV o DEPTH_CONV) [POWER_1; th]))
	  THEN SIMP_TAC[]
	  THEN DISCH_THEN (LABEL_TAC "F2")
	  THEN UNDISCH_TAC `~((n:A->A) ((e:A->A) (x:A)) = e x)`
	  THEN REWRITE_TAC[CONTRAPOS_THM]
	  THEN DISCH_THEN (LABEL_TAC "F3")
	  THEN MP_TAC(SPECL[`f:A->A`; `1`;`(x:A)`; `(f:A->A) (x:A)`] in_orbit_lemma)
	  THEN REWRITE_TAC[POWER_1]
	  THEN DISCH_THEN (fun th3 -> (USE_THEN "H1" (fun th1 -> (USE_THEN "H4" (fun th2 -> (MP_TAC (MATCH_MP lemma_orbit_identity (CONJ th1 (CONJ th2 th3)))))))))
	  THEN DISCH_THEN SUBST_ALL_TAC
	  THEN REMOVE_THEN "F2" (fun th1 -> (REMOVE_THEN "F3" (fun th2 -> MP_TAC (CONJ th1 th2))))
	  THEN REWRITE_TAC[GSYM IN_INTER]
	  THEN USE_THEN "FF"  SUBST1_TAC
	  THEN REWRITE_TAC[IN_SING]
	  THEN DISCH_THEN (MP_TAC o AP_TERM `n:A->A`)
	  THEN POP_ASSUM (fun th -> REWRITE_TAC[th]); ALL_TAC]
   THEN UNDISCH_TAC `~((f:A->A) (x:A) = x)`
   THEN REWRITE_TAC[CONTRAPOS_THM]
   THEN DISCH_TAC
   THEN USE_THEN "H1" (fun th1 -> (USE_THEN "H3" (fun th2 -> (MP_TAC (SPECL[`(f:A->A) (x:A)`; `x:A`] (MATCH_MP orbit_sym (CONJ th1 th2)))))))
   THEN POP_ASSUM (fun th -> REWRITE_TAC[th])
   THEN DISCH_THEN (LABEL_TAC "F8")
   THEN MP_TAC(SPECL[`f:A->A`; `1`; `x:A`;`(f:A->A) (x:A)`] in_orbit_lemma)
   THEN REWRITE_TAC[POWER_1]
   THEN DISCH_TAC
   THEN USE_THEN "H1" (fun th1 -> (USE_THEN "H4" (fun th2 -> (MP_TAC (SPECL[`(f:A->A) (x:A)`; `x:A`] (MATCH_MP orbit_sym (CONJ th1 th2)))))))
   THEN POP_ASSUM (fun th -> REWRITE_TAC[th])
   THEN DISCH_THEN (LABEL_TAC "F9")
   THEN REMOVE_THEN "F8" (fun th1 -> (REMOVE_THEN "F9" (fun th2 -> MP_TAC (CONJ th1 th2))))
   THEN REWRITE_TAC[GSYM IN_INTER]
   THEN POP_ASSUM SUBST1_TAC
   THEN REWRITE_TAC[IN_SING]
   THEN DISCH_THEN (fun th -> REWRITE_TAC[SYM th]));;


(* PLANARITY *)

let planar_ind = new_definition `planar_ind (H:(A)hypermap) = &(number_of_edges H) + &(number_of_nodes H) + &(number_of_faces H) - &(CARD (dart H)) - ((&2) * (&(number_of_components (H))))`;;


(* some trivial lemmas *)

let lemma_planar_hypermap = prove(`!(H:(A)hypermap). planar_hypermap H <=> planar_ind H = &0`,
  REWRITE_TAC[planar_hypermap; planar_ind;GSYM REAL_INJ; GSYM REAL_ADD'; GSYM REAL_MUL']
  THEN REAL_ARITH_TAC);;

let lemma_null_hypermap_planar_index = prove(`!(H:(A)hypermap). CARD (dart H) = 0 ==> planar_ind H = &0`,
GEN_TAC THEN label_hypermap_TAC `H:(A)hypermap`
  THEN USE_THEN "H1"(fun th -> REWRITE_TAC[MATCH_MP CARD_EQ_0 th])
  THEN REWRITE_TAC[planar_ind; number_of_edges; number_of_nodes; number_of_faces; number_of_components]
  THEN REWRITE_TAC[edge_set; node_set; face_set; set_of_components; set_part_components]
  THEN DISCH_THEN (LABEL_TAC "F1")
  THEN REMOVE_THEN "F1" (fun th -> SUBST_ALL_TAC th THEN ASSUME_TAC th)
  THEN SUBGOAL_THEN `!(p:A->A). set_of_orbits {} p = {}` (fun th ->  REWRITE_TAC[th]) THENL[REWRITE_TAC[set_of_orbits] THEN SET_TAC[]; ALL_TAC]
  THEN SUBGOAL_THEN `{comb_component (H:(A)hypermap) (x:A)| x IN {}} = {}` SUBST1_TAC THENL[SET_TAC[]; ALL_TAC]
  THEN REWRITE_TAC[CARD_CLAUSES] THEN REAL_ARITH_TAC);;

let lemma_shift_component_invariant = prove(`!(H:(A)hypermap). set_of_components H = set_of_components (shift H)`,
GEN_TAC THEN REWRITE_TAC[set_of_components]
  THEN REWRITE_TAC[GSYM shift_lemma]
  THEN ABBREV_TAC `D = dart (H:(A)hypermap)`
  THEN REWRITE_TAC[set_part_components]
  THEN REWRITE_TAC[EXTENSION]
  THEN GEN_TAC THEN EQ_TAC
  THENL[REWRITE_TAC[IN_ELIM_THM]
       THEN STRIP_TAC THEN EXISTS_TAC `x':A`
       THEN ASM_REWRITE_TAC[]
       THEN REWRITE_TAC[comb_component; EXTENSION]
       THEN GEN_TAC THEN EQ_TAC
       THENL[REWRITE_TAC[IN_ELIM_THM]
	       THEN REWRITE_TAC[is_in_component]
	       THEN STRIP_TAC THEN EXISTS_TAC `p:num -> A`
	       THEN EXISTS_TAC `n:num`
	       THEN ASM_REWRITE_TAC[]
	       THEN POP_ASSUM MP_TAC
	       THEN REWRITE_TAC[is_path; lemma_def_path]
	       THEN DISCH_THEN (LABEL_TAC "F1")
	       THEN REPEAT STRIP_TAC
	       THEN REMOVE_THEN "F1" (MP_TAC o SPEC `i:num`)
	       THEN ASM_REWRITE_TAC[]
	       THEN REWRITE_TAC[go_one_step] THEN DISCH_TAC
	       THEN REWRITE_TAC [GSYM shift_lemma]
	       THEN POP_ASSUM MP_TAC THEN MESON_TAC[]; ALL_TAC]
       THEN REWRITE_TAC[IN_ELIM_THM]
       THEN REWRITE_TAC[is_in_component]
       THEN STRIP_TAC THEN EXISTS_TAC `p:num -> A`
       THEN EXISTS_TAC `n:num` THEN ASM_REWRITE_TAC[]
       THEN POP_ASSUM MP_TAC THEN REWRITE_TAC[is_path; lemma_def_path]
       THEN DISCH_THEN (LABEL_TAC "F1") THEN REPEAT STRIP_TAC
       THEN REMOVE_THEN "F1" (MP_TAC o SPEC `i:num`)
       THEN ASM_REWRITE_TAC[] THEN REWRITE_TAC[go_one_step]
       THEN DISCH_TAC THEN ONCE_REWRITE_TAC [shift_lemma]
       THEN POP_ASSUM MP_TAC THEN MESON_TAC[]; ALL_TAC]
  THEN REWRITE_TAC[IN_ELIM_THM] THEN STRIP_TAC
  THEN EXISTS_TAC `x':A` THEN ASM_REWRITE_TAC[]
  THEN REWRITE_TAC[EXTENSION; IN_ELIM_THM] THEN GEN_TAC THEN EQ_TAC
  THENL[REWRITE_TAC[comb_component; IN_ELIM_THM; is_in_component]
       THEN STRIP_TAC THEN EXISTS_TAC `p:num -> A` THEN EXISTS_TAC `n:num`
       THEN ASM_REWRITE_TAC[] THEN POP_ASSUM MP_TAC
       THEN REWRITE_TAC[is_path; lemma_def_path]
       THEN DISCH_THEN (LABEL_TAC "F2")
       THEN REPEAT STRIP_TAC THEN REMOVE_THEN "F2" (MP_TAC o SPEC `i:num`)
       THEN ASM_REWRITE_TAC[] THEN REWRITE_TAC[go_one_step]
       THEN DISCH_TAC THEN ONCE_REWRITE_TAC [shift_lemma]
       THEN POP_ASSUM MP_TAC THEN MESON_TAC[]; ALL_TAC]
  THEN REWRITE_TAC[IN_ELIM_THM]
  THEN REWRITE_TAC[comb_component; is_in_component; IN_ELIM_THM]
  THEN STRIP_TAC THEN EXISTS_TAC `p:num -> A`
  THEN EXISTS_TAC `n:num` THEN ASM_REWRITE_TAC[]
  THEN POP_ASSUM MP_TAC
  THEN REWRITE_TAC[is_path; lemma_def_path]
  THEN DISCH_THEN (LABEL_TAC "F2")
  THEN REPEAT STRIP_TAC THEN REMOVE_THEN "F2" (MP_TAC o SPEC `i:num`)
  THEN ASM_REWRITE_TAC[] THEN REWRITE_TAC[go_one_step]
  THEN DISCH_TAC THEN REWRITE_TAC[GSYM shift_lemma]
  THEN POP_ASSUM MP_TAC THEN MESON_TAC[]);;


let lemma_planar_invariant_shift = prove(`!(H:(A)hypermap). planar_ind H = planar_ind (shift H)`,
    GEN_TAC THEN REWRITE_TAC[planar_ind; number_of_edges; number_of_nodes; number_of_faces; number_of_components]
    THEN ONCE_REWRITE_TAC[GSYM lemma_shift_component_invariant]
    THEN REWRITE_TAC[edge_set; node_set; face_set]
    THEN ONCE_REWRITE_TAC[GSYM shift_lemma]
    THEN REAL_ARITH_TAC);;

let in_orbit_map1 = prove(`!p:A->A x:A. p x IN orbit_map p x`,
   REPEAT GEN_TAC THEN MP_TAC (SPECL[`p:A->A`; `1`; `x:A`; `(p:A->A) (x:A)`] in_orbit_lemma)
   THEN REWRITE_TAC[POWER_1]);;


let lemma_orbit_eq = prove(`!p:A->A q:A->A x:A. (!n:num. (p POWER n) x = (q POWER n) x) ==> orbit_map p x = orbit_map q x`,
REPEAT STRIP_TAC THEN REWRITE_TAC[orbit_map; EXTENSION; IN_ELIM_THM]
  THEN STRIP_TAC THEN EQ_TAC
  THENL[STRIP_TAC THEN EXISTS_TAC `n:num`
	  THEN REWRITE_TAC[ARITH_RULE `n:num >= 0`]
	  THEN FIRST_X_ASSUM (MP_TAC o SPEC `n:num` o check (is_forall o concl))
	  THEN ASM_REWRITE_TAC[]; ALL_TAC]
  THEN STRIP_TAC THEN EXISTS_TAC `n:num`
  THEN REWRITE_TAC[ARITH_RULE `n:num >= 0`]
  THEN FIRST_X_ASSUM (MP_TAC o SYM o SPEC `n:num` o check (is_forall o concl))
  THEN ASM_REWRITE_TAC[]);;

let lemma_not_in_orbit_powers = prove(`!s:A->bool p:A->A x:A y:A n:num m:num. FINITE s /\ p permutes s /\ ~(y IN orbit_map p x) ==> ~((p POWER n) y = (p POWER m) x)`,
REPEAT STRIP_TAC THEN FIRST_X_ASSUM (MP_TAC o check (is_neg o concl))
  THEN REWRITE_TAC[]
  THEN MP_TAC(SPECL[`p:A->A`; `m:num`; `x:A`; `((p:A->A) POWER (m:num)) (x:A)`] in_orbit_lemma)
  THEN SIMP_TAC[] THEN POP_ASSUM (SUBST1_TAC o SYM)
  THEN DISCH_TAC THEN MP_TAC(SPECL[`p:A->A`; `y:A`] orbit_reflect)
  THEN MP_TAC(SPECL[`s:A->bool`; `p:A->A`; `y:A`; `n:num`] lemma_orbit_power)
  THEN ASM_REWRITE_TAC[] THEN DISCH_THEN SUBST1_TAC THEN STRIP_TAC
  THEN MP_TAC(SPECL[`p:A->A`; `y:A`; `((p:A->A) POWER (n:num)) (y:A)`; `x:A` ] orbit_trans)
  THEN ASM_REWRITE_TAC[]);;


let lemma_walkup_nodes = prove(`!(H:(A)hypermap) x:A. x IN dart H ==> (node_set H) DELETE (node H x) = (node_set (edge_walkup H x)) DELETE (node (edge_walkup H x) (inverse(node_map H) x))`,
   REPEAT GEN_TAC
   THEN label_hypermap_TAC `H:(A)hypermap`
   THEN ABBREV_TAC `D = dart (H:(A)hypermap)` 
   THEN ABBREV_TAC `e = edge_map (H:(A)hypermap)` 
   THEN ABBREV_TAC `n = node_map (H:(A)hypermap)` 
   THEN ABBREV_TAC `f = face_map (H:(A)hypermap)`
   THEN MP_TAC (CONJUNCT1 (SPECL[`H:(A)hypermap`; `x:A`] lemma_edge_walkup))
   THEN ASM_REWRITE_TAC[]
   THEN STRIP_TAC
   THEN ABBREV_TAC `D' = dart (edge_walkup (H:(A)hypermap) (x:A))`
   THEN ABBREV_TAC `n' = node_map (edge_walkup (H:(A)hypermap) (x:A))`
   THEN LABEL_TAC "F1" (SPECL[`n:A->A`; `x:A`] orbit_reflect)
   THEN DISCH_THEN (LABEL_TAC "F2")
   THEN USE_THEN "H1" (fun th1 -> (USE_THEN "H3" (fun th2 -> MP_TAC(SPEC `x:A` (MATCH_MP INVERSE_EVALUATION (CONJ th1 th2))))))
   THEN DISCH_THEN (X_CHOOSE_THEN `j:num` (LABEL_TAC "F3"))
   THEN USE_THEN "F3" ((LABEL_TAC "F4") o MATCH_MP in_orbit_lemma)
   THEN ASM_REWRITE_TAC[node_set; node]
   THEN REPEAT STRIP_TAC
   THEN REWRITE_TAC[set_of_orbits]
   THEN REWRITE_TAC[EXTENSION]
   THEN STRIP_TAC
   THEN REWRITE_TAC[IN_DELETE]
   THEN EQ_TAC
   THENL[REWRITE_TAC[IN_ELIM_THM]
  THEN DISCH_THEN (CONJUNCTS_THEN2 (X_CHOOSE_THEN `y:A` (CONJUNCTS_THEN2 (LABEL_TAC "F5") (LABEL_TAC "F6"))) (LABEL_TAC "F7"))
  THEN REMOVE_THEN "F6" SUBST_ALL_TAC
  THEN SUBGOAL_THEN `~(y:A IN orbit_map (n:A->A) (x:A))` (LABEL_TAC "F8")
  THENL[POP_ASSUM MP_TAC
	  THEN REWRITE_TAC[CONTRAPOS_THM]
	  THEN USE_THEN "H1" (fun th1 -> (USE_THEN "H3" (fun th2 -> (DISCH_THEN (fun th3 -> (MP_TAC (MATCH_MP lemma_orbit_identity (CONJ th1 (CONJ th2 th3)))))))))
	  THEN DISCH_THEN (fun th -> REWRITE_TAC[SYM th]); ALL_TAC]
  THEN SUBGOAL_THEN `!m:num. ((n:A->A) POWER (m:num)) (y:A) =  ((n':A->A) POWER (m:num)) (y:A)` (LABEL_TAC "F9")
  THENL[INDUCT_TAC THENL[REWRITE_TAC[POWER_0]; ALL_TAC]
	  THEN  POP_ASSUM (LABEL_TAC "F9" o SYM)
	  THEN  MP_TAC(SPECL[`D:A->bool`; `n:A->A`; `x:A`; `y:A`; `m:num`; `j:num`] lemma_not_in_orbit_powers)
	  THEN  ASM_REWRITE_TAC[]
	  THEN  STRIP_TAC
	  THEN  MP_TAC(SPECL[`D:A->bool`; `n:A->A`; `x:A`; `y:A`; `m:num`; `0`] lemma_not_in_orbit_powers)
	  THEN  ASM_REWRITE_TAC[POWER_0; I_THM]
	  THEN  STRIP_TAC
	  THEN  REWRITE_TAC[GSYM iterate_map_valuation]
	  THEN  REMOVE_THEN "F9" SUBST1_TAC
	  THEN  MP_TAC (CONJUNCT2(CONJUNCT2(SPECL[`H:(A)hypermap`; `x:A`; `((n:A->A) POWER (m:num)) (y:A)`] node_map_walkup)))
	  THEN  ASM_REWRITE_TAC[]
	  THEN  DISCH_THEN (fun th -> REWRITE_TAC[SYM th]); ALL_TAC]
  THEN SUBGOAL_THEN `~(((n:A->A) POWER (j:num)) (x:A) IN orbit_map n (y:A))` (LABEL_TAC "F10")
  THENL[ REMOVE_THEN "F8" MP_TAC
	   THEN  REWRITE_TAC[CONTRAPOS_THM]
	   THEN  USE_THEN "H1" (fun th1 -> (USE_THEN "H3" (fun th2 -> (DISCH_THEN (fun th3 -> (MP_TAC (MATCH_MP lemma_orbit_identity (CONJ th1 (CONJ th2 th3)))))))))
	   THEN  MP_TAC(SPECL[`D:A->bool`; `n:A->A`; `x:A`; `j:num`] lemma_orbit_power)
	   THEN  ASM_REWRITE_TAC[]
	   THEN  DISCH_THEN (fun th -> REWRITE_TAC[SYM th])
	   THEN  DISCH_THEN (fun th -> REWRITE_TAC[SYM th])
           THEN REWRITE_TAC[orbit_reflect]; ALL_TAC]
  THEN REMOVE_THEN "F9" (MP_TAC o MATCH_MP lemma_orbit_eq)
  THEN DISCH_THEN SUBST_ALL_TAC
  THEN STRIP_TAC
  THENL[EXISTS_TAC `y:A`
	  THEN MP_TAC(SPECL[`D:A->bool`; `n:A->A`; `x:A`; `y:A`; `0`; `0`] lemma_not_in_orbit_powers)
	  THEN ASM_REWRITE_TAC[POWER_0; I_THM]; ALL_TAC]
  THEN POP_ASSUM MP_TAC
  THEN REWRITE_TAC[CONTRAPOS_THM]
  THEN DISCH_THEN SUBST1_TAC
  THEN REWRITE_TAC[orbit_reflect]; ALL_TAC]
  THEN REWRITE_TAC[IN_ELIM_THM]
  THEN DISCH_THEN (CONJUNCTS_THEN2 (X_CHOOSE_THEN `y:A` (CONJUNCTS_THEN2 (CONJUNCTS_THEN2 (LABEL_TAC "F5") (LABEL_TAC "FF")) (LABEL_TAC "F6"))) (LABEL_TAC "F7"))
  THEN REMOVE_THEN "F6" SUBST_ALL_TAC
     THEN SUBGOAL_THEN `y:A IN (D:A->bool) DELETE (x:A)` (LABEL_TAC "F8")
     THENL[FIND_ASSUM SUBST1_TAC `D':A->bool = (D:A->bool) DELETE x:A`
	THEN  SET_TAC[IN_DELETE]; ALL_TAC]
     THEN SUBGOAL_THEN `!k:num. ~(((n':A->A) POWER k) (y:A) = x:A)` (LABEL_TAC "FG")
     THENL[GEN_TAC
	     THEN MP_TAC (MESON[hypermap_lemma] `node_map (edge_walkup (H:(A)hypermap) (x:A)) permutes dart(edge_walkup H x)`)
	     THEN ASM_REWRITE_TAC[]
	     THEN DISCH_THEN (MP_TAC o SPECL[`k:num`; `y:A`] o MATCH_MP iterate_orbit)
	     THEN USE_THEN "F8" (fun th -> REWRITE_TAC[th])
	     THEN REWRITE_TAC[IN_DELETE]
	     THEN SIMP_TAC[]; ALL_TAC]
     THEN MP_TAC(SPEC `edge_walkup (H:(A)hypermap) (x:A)` hypermap_lemma)
     THEN ASM_REWRITE_TAC[]
     THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "G1") (LABEL_TAC "G2" o CONJUNCT1 o CONJUNCT2))
     THEN SUBGOAL_THEN `~(((n:A->A) POWER (j:num)) (x:A) IN orbit_map (n':A->A) (y:A))` (LABEL_TAC "FH")
     THENL[ USE_THEN "F7" MP_TAC
	THEN  REWRITE_TAC[CONTRAPOS_THM]
        THEN USE_THEN "G1" (fun th1 -> (USE_THEN "G2" (fun th2 -> (DISCH_THEN (fun th3 -> (MP_TAC (MATCH_MP lemma_orbit_identity (CONJ th1 (CONJ th2 th3)))))))))
        THEN REWRITE_TAC[]; ALL_TAC]
     THEN SUBGOAL_THEN `!m:num. ((n:A->A) POWER (m:num)) (y:A) =  ((n':A->A) POWER (m:num)) (y:A)` (LABEL_TAC "F9")
     THENL[INDUCT_TAC THENL[REWRITE_TAC[POWER_0]; ALL_TAC]
	     THEN POP_ASSUM (LABEL_TAC "F9" o SYM)
	     THEN REMOVE_THEN "FG" (LABEL_TAC "F10" o SPEC `m:num`)
	     THEN MP_TAC(SPECL[`D':A->bool`; `n':A->A`; `y:A`; `((n:A->A) POWER (j:num)) (x:A)`; `0`; `m:num`] lemma_not_in_orbit_powers)
	     THEN ASM_REWRITE_TAC[POWER_0; I_THM]
	     THEN DISCH_THEN (LABEL_TAC "F11" o GSYM)
	     THEN REWRITE_TAC[GSYM iterate_map_valuation]
	     THEN MP_TAC (CONJUNCT2(CONJUNCT2(SPECL[`H:(A)hypermap`; `x:A`; `((n:A->A) POWER (m:num)) (y:A)`] node_map_walkup)))
	     THEN ASM_REWRITE_TAC[]
	     THEN USE_THEN "F9" (fun th -> GEN_REWRITE_TAC (LAND_CONV o LAND_CONV o DEPTH_CONV) [SYM th])
	     THEN ASM_REWRITE_TAC[]
	     THEN DISCH_THEN (fun th -> REWRITE_TAC[SYM th]); ALL_TAC]
     THEN REMOVE_THEN "F9" (MP_TAC o MATCH_MP lemma_orbit_eq)
     THEN DISCH_THEN (SUBST_ALL_TAC o SYM)
     THEN STRIP_TAC
     THENL[EXISTS_TAC `y:A` THEN ASM_REWRITE_TAC[]; ALL_TAC]
     THEN POP_ASSUM MP_TAC
     THEN REWRITE_TAC[CONTRAPOS_THM]
     THEN DISCH_THEN SUBST1_TAC
     THEN REWRITE_TAC[orbit_map; IN_ELIM_THM]
     THEN EXISTS_TAC `j:num` THEN ARITH_TAC);;


let lemma_walkup_faces  = prove(`!(H:(A)hypermap) x:A. x IN dart H ==> (face_set H) DELETE (face H x) = (face_set (edge_walkup H x)) DELETE (face (edge_walkup H x) (inverse(face_map H) x))`,
   REPEAT GEN_TAC
   THEN label_hypermap_TAC `H:(A)hypermap`
   THEN ABBREV_TAC `D = dart (H:(A)hypermap)` 
   THEN ABBREV_TAC `e = edge_map (H:(A)hypermap)` 
   THEN ABBREV_TAC `n = node_map (H:(A)hypermap)` 
   THEN ABBREV_TAC `f = face_map (H:(A)hypermap)`
   THEN MP_TAC (CONJUNCT1 (SPECL[`H:(A)hypermap`; `x:A`] lemma_edge_walkup))
   THEN ASM_REWRITE_TAC[]
   THEN STRIP_TAC
   THEN ABBREV_TAC `D' = dart (edge_walkup (H:(A)hypermap) (x:A))`
   THEN ABBREV_TAC `f' = face_map (edge_walkup (H:(A)hypermap) (x:A))`
   THEN LABEL_TAC "F1" (SPECL[`f:A->A`; `x:A`] orbit_reflect)
   THEN DISCH_THEN (LABEL_TAC "F2")
   THEN USE_THEN "H1" (fun th1 -> (USE_THEN "H4" (fun th2 -> MP_TAC(SPEC `x:A` (MATCH_MP INVERSE_EVALUATION (CONJ th1 th2))))))
   THEN DISCH_THEN (X_CHOOSE_THEN `j:num` (LABEL_TAC "F3"))
   THEN USE_THEN "F3" ((LABEL_TAC "F4") o MATCH_MP in_orbit_lemma)
   THEN ASM_REWRITE_TAC[face_set; face]
   THEN REPEAT STRIP_TAC
   THEN REWRITE_TAC[set_of_orbits]
   THEN REWRITE_TAC[EXTENSION]
   THEN STRIP_TAC
   THEN REWRITE_TAC[IN_DELETE]
   THEN EQ_TAC
   THENL[REWRITE_TAC[IN_ELIM_THM]
  THEN DISCH_THEN (CONJUNCTS_THEN2 (X_CHOOSE_THEN `y:A` (CONJUNCTS_THEN2 (LABEL_TAC "F5") (LABEL_TAC "F6"))) (LABEL_TAC "F7"))
  THEN REMOVE_THEN "F6" SUBST_ALL_TAC
  THEN SUBGOAL_THEN `~(y:A IN orbit_map (f:A->A) (x:A))` (LABEL_TAC "F8")
  THENL[POP_ASSUM MP_TAC
	  THEN REWRITE_TAC[CONTRAPOS_THM]
	  THEN USE_THEN "H1" (fun th1 -> (USE_THEN "H4" (fun th2 -> (DISCH_THEN (fun th3 -> (MP_TAC (MATCH_MP lemma_orbit_identity (CONJ th1 (CONJ th2 th3)))))))))
	  THEN DISCH_THEN (fun th -> REWRITE_TAC[SYM th]); ALL_TAC]
  THEN SUBGOAL_THEN `!m:num. ((f:A->A) POWER (m:num)) (y:A) =  ((f':A->A) POWER (m:num)) (y:A)` (LABEL_TAC "F9")
  THENL[INDUCT_TAC THENL[REWRITE_TAC[POWER_0]; ALL_TAC]
	  THEN  POP_ASSUM (LABEL_TAC "F9" o SYM)
	  THEN  MP_TAC(SPECL[`D:A->bool`; `f:A->A`; `x:A`; `y:A`; `m:num`; `j:num`] lemma_not_in_orbit_powers)
	  THEN  ASM_REWRITE_TAC[]
	  THEN  STRIP_TAC
	  THEN  MP_TAC(SPECL[`D:A->bool`; `f:A->A`; `x:A`; `y:A`; `m:num`; `0`] lemma_not_in_orbit_powers)
	  THEN  ASM_REWRITE_TAC[POWER_0; I_THM]
	  THEN  STRIP_TAC
	  THEN  REWRITE_TAC[GSYM iterate_map_valuation]
	  THEN  REMOVE_THEN "F9" SUBST1_TAC
	  THEN  MP_TAC (CONJUNCT2(CONJUNCT2(SPECL[`H:(A)hypermap`; `x:A`; `((f:A->A) POWER (m:num)) (y:A)`] face_map_walkup)))
	  THEN  ASM_REWRITE_TAC[]
	  THEN  DISCH_THEN (fun th -> REWRITE_TAC[SYM th]); ALL_TAC]
  THEN SUBGOAL_THEN `~(((f:A->A) POWER (j:num)) (x:A) IN orbit_map f (y:A))` (LABEL_TAC "F10")
  THENL[ REMOVE_THEN "F8" MP_TAC
	   THEN  REWRITE_TAC[CONTRAPOS_THM]
	   THEN  USE_THEN "H1" (fun th1 -> (USE_THEN "H4" (fun th2 -> (DISCH_THEN (fun th3 -> (MP_TAC (MATCH_MP lemma_orbit_identity (CONJ th1 (CONJ th2 th3)))))))))
	   THEN  MP_TAC(SPECL[`D:A->bool`; `f:A->A`; `x:A`; `j:num`] lemma_orbit_power)
	   THEN  ASM_REWRITE_TAC[]
	   THEN  DISCH_THEN (fun th -> REWRITE_TAC[SYM th])
	   THEN  DISCH_THEN (fun th -> REWRITE_TAC[SYM th])
           THEN REWRITE_TAC[orbit_reflect]; ALL_TAC]
  THEN REMOVE_THEN "F9" (MP_TAC o MATCH_MP lemma_orbit_eq)
  THEN DISCH_THEN SUBST_ALL_TAC
  THEN STRIP_TAC
  THENL[EXISTS_TAC `y:A`
	  THEN MP_TAC(SPECL[`D:A->bool`; `f:A->A`; `x:A`; `y:A`; `0`; `0`] lemma_not_in_orbit_powers)
	  THEN ASM_REWRITE_TAC[POWER_0; I_THM]; ALL_TAC]
  THEN POP_ASSUM MP_TAC
  THEN REWRITE_TAC[CONTRAPOS_THM]
  THEN DISCH_THEN SUBST1_TAC
  THEN REWRITE_TAC[orbit_reflect]; ALL_TAC]
  THEN REWRITE_TAC[IN_ELIM_THM]
  THEN DISCH_THEN (CONJUNCTS_THEN2 (X_CHOOSE_THEN `y:A` (CONJUNCTS_THEN2 (CONJUNCTS_THEN2 (LABEL_TAC "F5") (LABEL_TAC "FF")) (LABEL_TAC "F6"))) (LABEL_TAC "F7"))
  THEN REMOVE_THEN "F6" SUBST_ALL_TAC
     THEN SUBGOAL_THEN `y:A IN (D:A->bool) DELETE (x:A)` (LABEL_TAC "F8")
     THENL[FIND_ASSUM SUBST1_TAC `D':A->bool = (D:A->bool) DELETE x:A`
	THEN  SET_TAC[IN_DELETE]; ALL_TAC]
     THEN SUBGOAL_THEN `!k:num. ~(((f':A->A) POWER k) (y:A) = x:A)` (LABEL_TAC "FG")
     THENL[GEN_TAC
	     THEN MP_TAC (MESON[hypermap_lemma] `face_map (edge_walkup (H:(A)hypermap) (x:A)) permutes dart(edge_walkup H x)`)
	     THEN ASM_REWRITE_TAC[]
	     THEN DISCH_THEN (MP_TAC o SPECL[`k:num`; `y:A`] o MATCH_MP iterate_orbit)
	     THEN USE_THEN "F8" (fun th -> REWRITE_TAC[th])
	     THEN REWRITE_TAC[IN_DELETE]
	     THEN SIMP_TAC[]; ALL_TAC]
     THEN MP_TAC(SPEC `edge_walkup (H:(A)hypermap) (x:A)` hypermap_lemma)
     THEN ASM_REWRITE_TAC[]
     THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "G1") (LABEL_TAC "G2" o CONJUNCT1 o  CONJUNCT2 o CONJUNCT2))
     THEN SUBGOAL_THEN `~(((f:A->A) POWER (j:num)) (x:A) IN orbit_map (f':A->A) (y:A))` (LABEL_TAC "FH")
     THENL[ USE_THEN "F7" MP_TAC
	THEN  REWRITE_TAC[CONTRAPOS_THM]
        THEN USE_THEN "G1" (fun th1 -> (USE_THEN "G2" (fun th2 -> (DISCH_THEN (fun th3 -> (MP_TAC (MATCH_MP lemma_orbit_identity (CONJ th1 (CONJ th2 th3)))))))))
        THEN REWRITE_TAC[]; ALL_TAC]
     THEN SUBGOAL_THEN `!m:num. ((f:A->A) POWER (m:num)) (y:A) =  ((f':A->A) POWER (m:num)) (y:A)` (LABEL_TAC "F9")
     THENL[INDUCT_TAC THENL[REWRITE_TAC[POWER_0]; ALL_TAC]
	     THEN POP_ASSUM (LABEL_TAC "F9" o SYM)
	     THEN REMOVE_THEN "FG" (LABEL_TAC "F10" o SPEC `m:num`)
	     THEN MP_TAC(SPECL[`D':A->bool`; `f':A->A`; `y:A`; `((f:A->A) POWER (j:num)) (x:A)`; `0`; `m:num`] lemma_not_in_orbit_powers)
	     THEN ASM_REWRITE_TAC[POWER_0; I_THM]
	     THEN DISCH_THEN (LABEL_TAC "F11" o GSYM)
	     THEN REWRITE_TAC[GSYM iterate_map_valuation]
	     THEN MP_TAC (CONJUNCT2(CONJUNCT2(SPECL[`H:(A)hypermap`; `x:A`; `((f:A->A) POWER (m:num)) (y:A)`] face_map_walkup)))
	     THEN ASM_REWRITE_TAC[]
	     THEN USE_THEN "F9" (fun th -> GEN_REWRITE_TAC (LAND_CONV o LAND_CONV o DEPTH_CONV) [SYM th])
	     THEN ASM_REWRITE_TAC[]
	     THEN DISCH_THEN (fun th -> REWRITE_TAC[SYM th]); ALL_TAC]
     THEN REMOVE_THEN "F9" (MP_TAC o MATCH_MP lemma_orbit_eq)
     THEN DISCH_THEN (SUBST_ALL_TAC o SYM)
     THEN STRIP_TAC
     THENL[EXISTS_TAC `y:A` THEN ASM_REWRITE_TAC[]; ALL_TAC]
     THEN POP_ASSUM MP_TAC
     THEN REWRITE_TAC[CONTRAPOS_THM]
     THEN DISCH_THEN SUBST1_TAC
     THEN REWRITE_TAC[orbit_map; IN_ELIM_THM]
     THEN EXISTS_TAC `j:num` THEN ARITH_TAC);;


let lemma_walkup_first_edge_eq = prove(`!(H:(A)hypermap) (x:A) (y:A).x IN dart H /\ ~(x IN edge H y) /\  ~(node_map H x IN edge H y) ==> edge H y = edge (edge_walkup H x) y /\ ~(inverse (edge_map H) x IN edge H y)`,
   REPEAT GEN_TAC
   THEN label_hypermap_TAC `H:(A)hypermap`
   THEN ABBREV_TAC `D = dart (H:(A)hypermap)` 
   THEN ABBREV_TAC `e = edge_map (H:(A)hypermap)` 
   THEN ABBREV_TAC `n = node_map (H:(A)hypermap)` 
   THEN ABBREV_TAC `f = face_map (H:(A)hypermap)`
   THEN ABBREV_TAC `D' = dart (edge_walkup (H:(A)hypermap) (x:A))`
   THEN ABBREV_TAC `e' = edge_map (edge_walkup (H:(A)hypermap) (x:A))`
   THEN REWRITE_TAC[edge]
   THEN ASM_REWRITE_TAC[]
   THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F1") (CONJUNCTS_THEN2 (LABEL_TAC "F2") (LABEL_TAC "F4")))
   THEN SUBGOAL_THEN `!m:num. ((e:A->A) POWER m) (y:A) = ((e':A->A) POWER m) (y:A)` ASSUME_TAC
   THENL[INDUCT_TAC THENL[REWRITE_TAC[POWER_0]; ALL_TAC]
     THEN REWRITE_TAC[GSYM iterate_map_valuation]
     THEN POP_ASSUM (SUBST1_TAC o SYM)
     THEN SUBGOAL_THEN `~(((e:A->A) POWER (m:num)) (y:A) = x:A)` (LABEL_TAC "F5")
     THENL[USE_THEN "F2" MP_TAC
	    THEN REWRITE_TAC[CONTRAPOS_THM]
	    THEN CONV_TAC (ONCE_DEPTH_CONV SYM_CONV)
	    THEN REWRITE_TAC[in_orbit_lemma]; ALL_TAC]
     THEN SUBGOAL_THEN `~(((e:A->A) POWER (m:num)) (y:A) = (inverse e) (x:A))` (LABEL_TAC "F6")
     THENL[USE_THEN "F2" MP_TAC
	    THEN REWRITE_TAC[CONTRAPOS_THM]
	    THEN CONV_TAC (ONCE_DEPTH_CONV SYM_CONV)
	    THEN DISCH_THEN (MP_TAC o AP_TERM `e:A->A`)
	    THEN GEN_REWRITE_TAC (LAND_CONV o LAND_CONV o DEPTH_CONV)[GSYM o_THM]
	    THEN USE_THEN "H2" (fun th -> REWRITE_TAC[MATCH_MP PERMUTES_INVERSES_o th; I_THM; iterate_map_valuation])
	    THEN REWRITE_TAC[in_orbit_lemma]; ALL_TAC]
     THEN SUBGOAL_THEN `~(((e:A->A) POWER (m:num)) (y:A) = (n:A->A) (x:A))` (LABEL_TAC "F7")
     THENL[USE_THEN "F4" MP_TAC
	    THEN REWRITE_TAC[CONTRAPOS_THM]
	    THEN CONV_TAC (ONCE_DEPTH_CONV SYM_CONV)
	    THEN REWRITE_TAC[in_orbit_lemma]; ALL_TAC]
     THEN MP_TAC (CONJUNCT2(CONJUNCT2(CONJUNCT2(SPECL[`H:(A)hypermap`; `x:A`; `((e:A->A) POWER (m:num)) (y:A)`] edge_map_walkup))))
     THEN ASM_REWRITE_TAC[]
     THEN DISCH_THEN (fun th -> REWRITE_TAC[SYM th]); ALL_TAC]
   THEN STRIP_TAC
   THENL[POP_ASSUM (MP_TAC o MATCH_MP lemma_orbit_eq)
	   THEN POP_ASSUM (fun th -> REWRITE_TAC[th])
	   THEN SIMP_TAC[]; ALL_TAC]
   THEN REMOVE_THEN "F2" MP_TAC
   THEN REWRITE_TAC[CONTRAPOS_THM]
   THEN USE_THEN "H1" (fun th1 -> (USE_THEN "H2" (fun th2 -> (DISCH_THEN (fun th3 -> (ASSUME_TAC (MATCH_MP lemma_orbit_identity (CONJ th1 (CONJ th2 th3)))))))))
   THEN POP_ASSUM SUBST1_TAC
   THEN USE_THEN "H1" (fun th1 -> (USE_THEN "H2" (fun th2 -> MP_TAC (SPEC `x:A` (MATCH_MP lemma_inverse_in_orbit (CONJ th1 th2))))))
   THEN MATCH_MP_TAC orbit_sym
   THEN EXISTS_TAC `D:A->bool`
   THEN ASM_REWRITE_TAC[]);;


let lemma_walkup_second_edge_eq = prove(`!(H:(A)hypermap) (x:A) (y:A).x IN dart H /\ y IN dart H /\ ~(y = x) /\  ~(node_map H x IN edge (edge_walkup H x) y) /\  ~((inverse (edge_map H)) x IN edge (edge_walkup H x) y)  ==> edge H y = edge (edge_walkup H x) y /\ ~(x IN edge H y) /\ ~ (node_map H x IN edge H y)`,
   REPEAT GEN_TAC
   THEN label_hypermap_TAC `H:(A)hypermap`
   THEN ABBREV_TAC `D = dart (H:(A)hypermap)` 
   THEN ABBREV_TAC `e = edge_map (H:(A)hypermap)` 
   THEN ABBREV_TAC `n = node_map (H:(A)hypermap)` 
   THEN ABBREV_TAC `f = face_map (H:(A)hypermap)`
   THEN ABBREV_TAC `D' = dart (edge_walkup (H:(A)hypermap) (x:A))`
   THEN ABBREV_TAC `e' = edge_map (edge_walkup (H:(A)hypermap) (x:A))`
   THEN REWRITE_TAC[edge]
   THEN ASM_REWRITE_TAC[]
   THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F1") (CONJUNCTS_THEN2 (LABEL_TAC "F2") (CONJUNCTS_THEN2 (LABEL_TAC "F3") (CONJUNCTS_THEN2 (LABEL_TAC "F4") (LABEL_TAC "F5")))))
   THEN SUBGOAL_THEN `!m:num. ((e:A->A) POWER m) (y:A) = ((e':A->A) POWER m) (y:A)` ASSUME_TAC
   THENL[INDUCT_TAC THENL[REWRITE_TAC[POWER_0]; ALL_TAC]
	THEN REWRITE_TAC[GSYM iterate_map_valuation]
	THEN POP_ASSUM (SUBST1_TAC)
	THEN MP_TAC (SPEC `edge_walkup (H:(A)hypermap) (x:A)` hypermap_lemma)
	THEN ASM_REWRITE_TAC[]
	THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "G1") (LABEL_TAC "G2" o CONJUNCT1))
	THEN MP_TAC (CONJUNCT1 (SPECL[`H:(A)hypermap`; `x:A`] lemma_edge_walkup))
	THEN ASM_REWRITE_TAC[]
	THEN DISCH_THEN ASSUME_TAC
	THEN SUBGOAL_THEN `y:A IN D':A->bool` ASSUME_TAC
        THENL[POP_ASSUM SUBST1_TAC THEN SET_TAC[IN_DELETE]; ALL_TAC]
       THEN USE_THEN "G2" (MP_TAC o MATCH_MP iterate_orbit)
       THEN DISCH_THEN (MP_TAC o SPECL[`m:num`; `y:A`])
       THEN ASM_REWRITE_TAC[]
       THEN ASM_REWRITE_TAC[IN_DELETE]
       THEN DISCH_THEN (ASSUME_TAC o CONJUNCT2)
       THEN SUBGOAL_THEN `~(((e':A->A) POWER (m:num)) (y:A) = (inverse e) (x:A))` ASSUME_TAC
       THENL[USE_THEN "F5" MP_TAC THEN REWRITE_TAC[CONTRAPOS_THM]
	       THEN CONV_TAC (ONCE_DEPTH_CONV SYM_CONV)
	       THEN REWRITE_TAC[in_orbit_lemma]; ALL_TAC]
       THEN SUBGOAL_THEN `~(((e':A->A) POWER (m:num)) (y:A) = (n:A->A) (x:A))` ASSUME_TAC
       THENL[USE_THEN "F4" MP_TAC
	    THEN REWRITE_TAC[CONTRAPOS_THM]
	    THEN CONV_TAC (ONCE_DEPTH_CONV SYM_CONV)
	    THEN REWRITE_TAC[in_orbit_lemma]; ALL_TAC]
       THEN MP_TAC (CONJUNCT2(CONJUNCT2(CONJUNCT2(SPECL[`H:(A)hypermap`; `x:A`; `((e':A->A) POWER (m:num)) (y:A)`] edge_map_walkup))))
       THEN ASM_REWRITE_TAC[]
       THEN DISCH_THEN (fun th -> REWRITE_TAC[SYM th]); ALL_TAC]
   THEN POP_ASSUM (LABEL_TAC "FF" o MATCH_MP lemma_orbit_eq)
   THEN USE_THEN "FF" (fun th -> REWRITE_TAC[th])
   THEN POP_ASSUM (SUBST_ALL_TAC o SYM)
   THEN STRIP_TAC
   THENL[POP_ASSUM MP_TAC THEN REWRITE_TAC[CONTRAPOS_THM]
	   THEN USE_THEN "H1" (fun th1 -> (USE_THEN "H2" (fun th2 -> (DISCH_THEN (fun th3 -> (ASSUME_TAC (MATCH_MP lemma_orbit_identity (CONJ th1 (CONJ th2 th3)))))))))
	   THEN POP_ASSUM SUBST1_TAC
	   THEN MATCH_MP_TAC lemma_inverse_in_orbit
	   THEN EXISTS_TAC `D:A->bool`
	   THEN ASM_REWRITE_TAC[]; ALL_TAC]
   THEN USE_THEN "F4"(fun th -> REWRITE_TAC[th]));;


let lemma_walkup_edges = prove(`!(H:(A)hypermap) x:A. x IN dart H ==> (edge_set H) DIFF {edge H x, edge H (node_map H x)} = (edge_set (edge_walkup H x)) DIFF {edge (edge_walkup H x) (node_map H x), edge (edge_walkup H x) (inverse (edge_map H) x)}`,
   REPEAT GEN_TAC THEN DISCH_THEN (LABEL_TAC "F1")
   THEN REWRITE_TAC[edge_set; edge] THEN ABBREV_TAC `D = dart (H:(A)hypermap)`
   THEN ABBREV_TAC `D' = dart (edge_walkup (H:(A)hypermap) (x:A))`
   THEN REWRITE_TAC[set_of_orbits; SET_RULE `s DIFF {a, b} = (s DELETE a) DELETE b`]
   THEN REWRITE_TAC[EXTENSION] THEN GEN_TAC
   THEN ABBREV_TAC `e = edge_map (H:(A)hypermap)`
   THEN ABBREV_TAC `e' = edge_map (edge_walkup (H:(A)hypermap) (x:A))`
   THEN MP_TAC (SPEC `H:(A)hypermap` hypermap_lemma)
   THEN ASM_REWRITE_TAC[]
   THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "H1") (LABEL_TAC "H2" o CONJUNCT1))
   THEN MP_TAC (CONJUNCT1(SPECL[`H:(A)hypermap`; `x:A`] lemma_edge_walkup))
   THEN ASM_REWRITE_TAC[]
   THEN DISCH_THEN (LABEL_TAC "G1")
   THEN EQ_TAC THENL[REWRITE_TAC[IN_ELIM_THM; IN_DELETE]
      THEN DISCH_THEN (CONJUNCTS_THEN2 (CONJUNCTS_THEN2 (X_CHOOSE_THEN `y:A` (CONJUNCTS_THEN2 (LABEL_TAC "F2") (LABEL_TAC "F3")) ) (LABEL_TAC "F4")) (LABEL_TAC "F5"))
      THEN REMOVE_THEN "F3" SUBST_ALL_TAC
      THEN SUBGOAL_THEN `~(x:A IN orbit_map (e:A->A) (y:A))` (LABEL_TAC "F6")
      THENL[USE_THEN "F4" MP_TAC
         THEN REWRITE_TAC[CONTRAPOS_THM]
         THEN DISCH_TAC THEN MATCH_MP_TAC lemma_orbit_identity
         THEN EXISTS_TAC `D:A->bool`
         THEN ASM_REWRITE_TAC[]; ALL_TAC]
      THEN SUBGOAL_THEN `~(node_map (H:(A)hypermap) x:A IN orbit_map (e:A->A) (y:A))` (LABEL_TAC "F6")
      THENL[USE_THEN "F5" MP_TAC
         THEN REWRITE_TAC[CONTRAPOS_THM]
         THEN DISCH_TAC THEN MATCH_MP_TAC lemma_orbit_identity
	 THEN EXISTS_TAC `D:A->bool`
	 THEN ASM_REWRITE_TAC[]; ALL_TAC]
      THEN MP_TAC (SPECL[`H:(A)hypermap`; `x:A`; `y:A`] lemma_walkup_first_edge_eq)
      THEN ASM_REWRITE_TAC[edge]
      THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F7") (LABEL_TAC "F8"))
      THEN STRIP_TAC
      THENL[STRIP_TAC
         THENL[EXISTS_TAC `y:A`
	      THEN USE_THEN "F7" (fun th -> REWRITE_TAC[th])
	      THEN SUBGOAL_THEN `~(y:A = x:A)` MP_TAC
	      THENL[USE_THEN "F4" MP_TAC
	         THEN REWRITE_TAC[CONTRAPOS_THM]
	         THEN DISCH_THEN SUBST1_TAC
	         THEN SIMP_TAC[]; ALL_TAC] 
	      THEN USE_THEN "F2" MP_TAC
	      THEN REWRITE_TAC[IMP_IMP]
	      THEN SET_TAC[IN_DELETE]; ALL_TAC]
	 THEN USE_THEN "F6" MP_TAC
         THEN REWRITE_TAC[CONTRAPOS_THM]
         THEN DISCH_THEN SUBST1_TAC
         THEN REWRITE_TAC[orbit_reflect]; ALL_TAC]
      THEN USE_THEN "F8" MP_TAC
      THEN REWRITE_TAC[CONTRAPOS_THM]
      THEN DISCH_THEN SUBST1_TAC
      THEN REWRITE_TAC[orbit_reflect]; ALL_TAC]
   THEN REWRITE_TAC[IN_ELIM_THM; IN_DELETE]
   THEN DISCH_THEN (CONJUNCTS_THEN2 (CONJUNCTS_THEN2 (X_CHOOSE_THEN `y:A` (CONJUNCTS_THEN2 (LABEL_TAC "F2") (LABEL_TAC "F3")) ) (LABEL_TAC "F4")) (LABEL_TAC "F5"))
   THEN REMOVE_THEN "F3" SUBST_ALL_TAC
   THEN ABBREV_TAC `G = edge_walkup (H:(A)hypermap) (x:A)`
   THEN MP_TAC (SPEC `G:(A)hypermap` hypermap_lemma)
   THEN ASM_REWRITE_TAC[]
   THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "GA") (LABEL_TAC "GB" o CONJUNCT1))
   THEN SUBGOAL_THEN `(y:A IN D:A->bool) /\ ~(y:A = x:A)` ASSUME_TAC
   THENL[USE_THEN "F2" MP_TAC
      THEN USE_THEN "G1" SUBST1_TAC
      THEN REWRITE_TAC[IN_DELETE]; ALL_TAC]
   THEN SUBGOAL_THEN `~(node_map (H:(A)hypermap) (x:A) IN orbit_map (e':A->A) (y:A))` (LABEL_TAC "F6")
   THENL[ USE_THEN "F4" MP_TAC
      THEN REWRITE_TAC[CONTRAPOS_THM]
      THEN DISCH_TAC
      THEN MATCH_MP_TAC lemma_orbit_identity
      THEN EXISTS_TAC `D':A->bool`
      THEN ASM_REWRITE_TAC[]; ALL_TAC]
   THEN SUBGOAL_THEN `~((inverse(e:A->A)) (x:A) IN orbit_map (e':A->A) (y:A))` (LABEL_TAC "F7")
   THENL[USE_THEN "F5" MP_TAC
       THEN REWRITE_TAC[CONTRAPOS_THM]
       THEN DISCH_TAC
       THEN MATCH_MP_TAC lemma_orbit_identity
       THEN EXISTS_TAC `D':A->bool`
       THEN ASM_REWRITE_TAC[]; ALL_TAC]
   THEN MP_TAC (SPECL[`H:(A)hypermap`; `x:A`; `y:A`] lemma_walkup_second_edge_eq)
   THEN ASM_REWRITE_TAC[edge]
   THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F8") (CONJUNCTS_THEN2 (LABEL_TAC "F9") (LABEL_TAC "F10")))
   THEN STRIP_TAC
   THENL[STRIP_TAC
      THENL[EXISTS_TAC `y:A`
	      THEN ASM_REWRITE_TAC[]; ALL_TAC]
      THEN USE_THEN "F7" MP_TAC
      THEN REWRITE_TAC[CONTRAPOS_THM]
      THEN DISCH_THEN SUBST1_TAC
      THEN MATCH_MP_TAC lemma_inverse_in_orbit
      THEN EXISTS_TAC `D:A->bool`
      THEN ASM_REWRITE_TAC[]; ALL_TAC]
    THEN USE_THEN "F8" (SUBST_ALL_TAC o SYM)
    THEN POP_ASSUM MP_TAC
    THEN REWRITE_TAC[CONTRAPOS_THM]
    THEN DISCH_THEN SUBST1_TAC
    THEN REWRITE_TAC[orbit_reflect]);;


(* A SOME FACTS ON COMPONETS *)

let lemma_powers_in_component = prove(`!(H:(A)hypermap) (x:A) (j:num). (((edge_map H) POWER j) x IN comb_component H x) /\ (((node_map H) POWER j) x IN comb_component H x) /\ (((face_map H) POWER j) x IN comb_component H x)`, 
   REWRITE_TAC[comb_component; is_in_component; IN_ELIM_THM]
   THEN REPEAT GEN_TAC
   THEN STRIP_TAC
   THENL[EXISTS_TAC `edge_path (H:(A)hypermap) (x:A)` 
       THEN EXISTS_TAC `j:num`
       THEN REWRITE_TAC[edge_path; lemma_edge_path; POWER_0; I_THM]; ALL_TAC]
   THEN STRIP_TAC
   THENL[EXISTS_TAC `node_path (H:(A)hypermap) (x:A)`
       THEN EXISTS_TAC `j:num`
       THEN REWRITE_TAC[node_path; lemma_node_path; POWER_0; I_THM]; ALL_TAC]
   THEN EXISTS_TAC `face_path (H:(A)hypermap) (x:A)`
   THEN EXISTS_TAC `j:num`
   THEN REWRITE_TAC[face_path; lemma_face_path; POWER_0; I_THM]);;

let lemma_inverses_in_component = prove(`!(H:(A)hypermap) (x:A) (j:num). (inverse(edge_map H) x IN comb_component H x) /\ (inverse(node_map H) x IN comb_component H x) /\ (inverse(face_map H) x IN comb_component H x)`,
REPEAT GEN_TAC
  THEN label_hypermap_TAC `H:(A)hypermap`
  THEN REPEAT STRIP_TAC
  THENL[USE_THEN "H1" (fun th1 -> (USE_THEN "H2" (fun th2 -> (MP_TAC (SPEC `x:A` (MATCH_MP INVERSE_EVALUATION (CONJ th1 th2)))))))
	  THEN DISCH_THEN (X_CHOOSE_THEN `j:num` SUBST1_TAC)
	  THEN REWRITE_TAC[ lemma_powers_in_component];
          USE_THEN "H1" (fun th1 -> (USE_THEN "H3" (fun th2 -> (MP_TAC (SPEC `x:A` (MATCH_MP INVERSE_EVALUATION (CONJ th1 th2)))))))
	  THEN DISCH_THEN (X_CHOOSE_THEN `j:num` SUBST1_TAC)
	  THEN REWRITE_TAC[ lemma_powers_in_component];
          USE_THEN "H1" (fun th1 -> (USE_THEN "H4" (fun th2 -> (MP_TAC (SPEC `x:A` (MATCH_MP INVERSE_EVALUATION (CONJ th1 th2)))))))
	  THEN DISCH_THEN (X_CHOOSE_THEN `j:num` SUBST1_TAC)
	  THEN REWRITE_TAC[ lemma_powers_in_component]]);;

let lemma_edge_subset_component = prove(`!(H:(A)hypermap) (x:A). edge H x SUBSET comb_component H x`,
    REPEAT GEN_TAC
    THEN REWRITE_TAC[SUBSET; edge; orbit_map; IN_ELIM_THM]
    THEN REPEAT STRIP_TAC
    THEN POP_ASSUM SUBST1_TAC
    THEN REWRITE_TAC[lemma_powers_in_component]);;



let lemma_node_subset_component = prove(`!(H:(A)hypermap) (x:A). node H x SUBSET comb_component H x`,
    REPEAT GEN_TAC
    THEN REWRITE_TAC[SUBSET; node; orbit_map; IN_ELIM_THM]
    THEN REPEAT STRIP_TAC
    THEN POP_ASSUM SUBST1_TAC
    THEN REWRITE_TAC[lemma_powers_in_component]);;

let lemma_face_subset_component = prove(`!(H:(A)hypermap) (x:A). face H x SUBSET comb_component H x`,
    REPEAT GEN_TAC
    THEN REWRITE_TAC[SUBSET; face; orbit_map; IN_ELIM_THM]
    THEN REPEAT STRIP_TAC
    THEN POP_ASSUM SUBST1_TAC
    THEN REWRITE_TAC[lemma_powers_in_component]);;

let lemma_edge_identity = prove(`!(H:(A)hypermap) x:A y:A. y IN edge H x ==>  edge H x =  edge H y`,
     REPEAT GEN_TAC THEN REWRITE_TAC[edge] THEN MESON_TAC[lemma_orbit_identity; hypermap_lemma]);;

let lemma_node_identity = prove(`!(H:(A)hypermap) x:A y:A. y IN node H x ==>  node H x =  node H y`,
     REPEAT GEN_TAC THEN REWRITE_TAC[node] THEN MESON_TAC[lemma_orbit_identity; hypermap_lemma]);;

let lemma_face_identity = prove(`!(H:(A)hypermap) x:A y:A. y IN face H x ==>  face H x =  face H y`,
     REPEAT GEN_TAC THEN REWRITE_TAC[face] THEN MESON_TAC[lemma_orbit_identity; hypermap_lemma]);;

let lemma_component_identity = prove(`!(H:(A)hypermap) x:A y:A. y IN comb_component H x ==>  comb_component H x =  comb_component H y`,
     REPEAT STRIP_TAC
     THEN MP_TAC (SPECL[`H:(A)hypermap`; `x:A`; `y:A`] partition_components)
     THEN SUBGOAL_THEN `?z:A. z IN comb_component (H:(A)hypermap) (x:A) INTER  comb_component (H:(A)hypermap) (y:A)` MP_TAC
     THENL[ASSUME_TAC (SPECL[`H:(A)hypermap`; `y:A`] lemma_component_reflect)
	     THEN  EXISTS_TAC `y:A`
	     THEN  ASM_REWRITE_TAC[IN_INTER]; ALL_TAC]
     THEN  REWRITE_TAC[MEMBER_NOT_EMPTY]
     THEN DISCH_THEN (fun th -> REWRITE_TAC[th]));;


let lemma_walkup_first_component_eq = prove(`!(H:(A)hypermap) (x:A) (y:A).x IN dart H /\ ~(x IN comb_component H y)  ==> comb_component H y = comb_component (edge_walkup H x) y /\ ~(node_map H x IN comb_component H y) /\ ~((inverse (edge_map H)) x IN comb_component H y)`,
   REPEAT GEN_TAC
   THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F1") (LABEL_TAC "F2"))
   THEN label_hypermap_TAC `H:(A)hypermap`
   THEN ABBREV_TAC `D = dart (H:(A)hypermap)` 
   THEN ABBREV_TAC `e = edge_map (H:(A)hypermap)` 
   THEN ABBREV_TAC `n = node_map (H:(A)hypermap)` 
   THEN ABBREV_TAC `f = face_map (H:(A)hypermap)`
   THEN ABBREV_TAC `D' = dart (edge_walkup (H:(A)hypermap) (x:A))`
   THEN ABBREV_TAC `e' = edge_map (edge_walkup (H:(A)hypermap) (x:A))`
   THEN ABBREV_TAC `n' = node_map (edge_walkup (H:(A)hypermap) (x:A))`
   THEN ABBREV_TAC `f' = face_map (edge_walkup (H:(A)hypermap) (x:A))`
   THEN SUBGOAL_THEN `!z:A. z IN comb_component (H:(A)hypermap) (y:A) ==> ~(z = (x:A))` (LABEL_TAC "F3")
   THENL[ GEN_TAC THEN STRIP_TAC
     THEN REMOVE_THEN "F2" MP_TAC
     THEN REWRITE_TAC[CONTRAPOS_THM]
     THEN DISCH_THEN SUBST_ALL_TAC
     THEN ASM_REWRITE_TAC[]; ALL_TAC]
   THEN SUBGOAL_THEN `!z:A. z IN comb_component (H:(A)hypermap) (y:A) ==> ~(z = (e:A->A) (x:A))` (LABEL_TAC "F4")
   THENL[ GEN_TAC THEN (DISCH_THEN (LABEL_TAC "G1"))
        THEN REMOVE_THEN "F2" MP_TAC
        THEN REWRITE_TAC[CONTRAPOS_THM]
        THEN STRIP_TAC
        THEN MP_TAC (CONJUNCT1(SPECL[`H:(A)hypermap`; `x:A`; `1`]  lemma_powers_in_component))
        THEN ASM_REWRITE_TAC[POWER_1]
        THEN POP_ASSUM (SUBST1_TAC o SYM)
        THEN DISCH_THEN (MP_TAC o MATCH_MP lemma_component_symmetry)
        THEN POP_ASSUM MP_TAC
        THEN MESON_TAC[lemma_component_trans]; ALL_TAC]
   THEN SUBGOAL_THEN `!z:A. z IN comb_component (H:(A)hypermap) (y:A) ==> ~(z = (n:A->A) (x:A))` (LABEL_TAC "F5")
   THENL[ GEN_TAC THEN (DISCH_THEN (LABEL_TAC "G1"))
        THEN REMOVE_THEN "F2" MP_TAC
        THEN REWRITE_TAC[CONTRAPOS_THM]
        THEN STRIP_TAC
        THEN MP_TAC (CONJUNCT1(CONJUNCT2((SPECL[`H:(A)hypermap`; `x:A`; `1`]  lemma_powers_in_component))))
        THEN ASM_REWRITE_TAC[POWER_1]
        THEN POP_ASSUM (SUBST1_TAC o SYM)
        THEN DISCH_THEN (MP_TAC o MATCH_MP lemma_component_symmetry)
        THEN POP_ASSUM MP_TAC
        THEN ASM_MESON_TAC[lemma_component_trans]; ALL_TAC]
   THEN SUBGOAL_THEN `!z:A. z IN comb_component (H:(A)hypermap) (y:A) ==> ~(z = (f:A->A) (x:A))` (LABEL_TAC "F6")
   THENL[ GEN_TAC THEN (DISCH_THEN (LABEL_TAC "G1"))
        THEN REMOVE_THEN "F2" MP_TAC
        THEN REWRITE_TAC[CONTRAPOS_THM]
        THEN STRIP_TAC
        THEN MP_TAC (CONJUNCT2(CONJUNCT2(SPECL[`H:(A)hypermap`; `x:A`; `1`]  lemma_powers_in_component)))
        THEN ASM_REWRITE_TAC[POWER_1]
        THEN POP_ASSUM (SUBST1_TAC o SYM)
        THEN DISCH_THEN (MP_TAC o MATCH_MP lemma_component_symmetry)
        THEN POP_ASSUM MP_TAC
        THEN ASM_MESON_TAC[lemma_component_trans]; ALL_TAC]
   THEN SUBGOAL_THEN `!z:A. z IN comb_component (H:(A)hypermap) (y:A) ==> ~(z = (inverse(e:A->A)) (x:A))` (LABEL_TAC "F7")
   THENL[GEN_TAC THEN (DISCH_THEN (LABEL_TAC "G1"))
        THEN REMOVE_THEN "F2" MP_TAC
        THEN REWRITE_TAC[CONTRAPOS_THM]
        THEN USE_THEN "H1" (fun th1 -> (USE_THEN "H2" (fun th2 -> (MP_TAC (SPEC`x:A` (MATCH_MP INVERSE_EVALUATION (CONJ th1 th2)))))))
        THEN ASM_REWRITE_TAC[]    
        THEN DISCH_THEN (X_CHOOSE_THEN `j:num` SUBST1_TAC)
        THEN STRIP_TAC
        THEN MP_TAC (CONJUNCT1(SPECL[`H:(A)hypermap`; `x:A`; `j:num`]  lemma_powers_in_component))
        THEN ASM_REWRITE_TAC[]
        THEN POP_ASSUM (SUBST1_TAC o SYM)
        THEN DISCH_THEN (MP_TAC o MATCH_MP lemma_component_symmetry)
        THEN POP_ASSUM MP_TAC
        THEN MESON_TAC[lemma_component_trans]; ALL_TAC]
   THEN SUBGOAL_THEN `!z:A. z IN comb_component (H:(A)hypermap) (y:A) ==> ~(z = (inverse(n:A->A)) (x:A))` (LABEL_TAC "F8")
   THENL[GEN_TAC THEN (DISCH_THEN (LABEL_TAC "G1"))
        THEN REMOVE_THEN "F2" MP_TAC
        THEN REWRITE_TAC[CONTRAPOS_THM]
        THEN USE_THEN "H1" (fun th1 -> (USE_THEN "H3" (fun th2 -> (MP_TAC (SPEC`x:A` (MATCH_MP INVERSE_EVALUATION (CONJ th1 th2)))))))
        THEN ASM_REWRITE_TAC[]    
        THEN DISCH_THEN (X_CHOOSE_THEN `j:num` SUBST1_TAC)
        THEN STRIP_TAC
        THEN MP_TAC (CONJUNCT1(CONJUNCT2(SPECL[`H:(A)hypermap`; `x:A`; `j:num`]  lemma_powers_in_component)))
        THEN ASM_REWRITE_TAC[]
        THEN POP_ASSUM (SUBST1_TAC o SYM)
        THEN DISCH_THEN (MP_TAC o MATCH_MP lemma_component_symmetry)
        THEN POP_ASSUM MP_TAC
        THEN MESON_TAC[lemma_component_trans]; ALL_TAC]
   THEN SUBGOAL_THEN `!z:A. z IN comb_component (H:(A)hypermap) (y:A) ==> ~(z = (inverse(f:A->A)) (x:A))` (LABEL_TAC "F8f")
   THENL[GEN_TAC THEN (DISCH_THEN (LABEL_TAC "G1"))
        THEN REMOVE_THEN "F2" MP_TAC
        THEN REWRITE_TAC[CONTRAPOS_THM]
        THEN USE_THEN "H1" (fun th1 -> (USE_THEN "H4" (fun th2 -> (MP_TAC (SPEC`x:A` (MATCH_MP INVERSE_EVALUATION (CONJ th1 th2)))))))
        THEN ASM_REWRITE_TAC[]    
        THEN DISCH_THEN (X_CHOOSE_THEN `j:num` SUBST1_TAC)
        THEN STRIP_TAC
        THEN MP_TAC (CONJUNCT2(CONJUNCT2(SPECL[`H:(A)hypermap`; `x:A`; `j:num`]  lemma_powers_in_component)))
        THEN ASM_REWRITE_TAC[]
        THEN POP_ASSUM (SUBST1_TAC o SYM)
        THEN DISCH_THEN (MP_TAC o MATCH_MP lemma_component_symmetry)
        THEN POP_ASSUM MP_TAC
        THEN MESON_TAC[lemma_component_trans]; ALL_TAC]
   THEN SUBGOAL_THEN `~((n:A->A) (x:A) IN comb_component (H:(A)hypermap) (y:A))` ASSUME_TAC
   THENL[USE_THEN "F2" MP_TAC
	THEN REWRITE_TAC[CONTRAPOS_THM]
	THEN STRIP_TAC
	THEN USE_THEN "F5" (MP_TAC o SPEC `(n:A->A) (x:A)`)
	THEN POP_ASSUM(fun th -> REWRITE_TAC[th]); ALL_TAC]
   THEN POP_ASSUM(fun th -> REWRITE_TAC[th])
   THEN SUBGOAL_THEN `~((inverse(e:A->A)) (x:A) IN comb_component (H:(A)hypermap) (y:A))` ASSUME_TAC
   THENL[USE_THEN "F2" MP_TAC
	THEN REWRITE_TAC[CONTRAPOS_THM]
	THEN STRIP_TAC
	THEN USE_THEN "F7" (MP_TAC o SPEC `(inverse(e:A->A)) (x:A)`)
	THEN POP_ASSUM(fun th -> REWRITE_TAC[th]); ALL_TAC]
   THEN POP_ASSUM (fun th -> REWRITE_TAC[th])
   THEN REWRITE_TAC[comb_component; is_in_component; EXTENSION; IN_ELIM_THM]
   THEN GEN_TAC
   THEN EQ_TAC
   THENL[DISCH_THEN (X_CHOOSE_THEN `p:num->A` (X_CHOOSE_THEN `m:num` (CONJUNCTS_THEN2 (LABEL_TAC "F9") (CONJUNCTS_THEN2 (LABEL_TAC "F10") (LABEL_TAC "F11")))))
         THEN EXISTS_TAC `p:num->A`
	 THEN EXISTS_TAC `m:num`
	 THEN ASM_REWRITE_TAC[]
	 THEN REWRITE_TAC[lemma_def_path]
	 THEN GEN_TAC
	 THEN DISCH_THEN (LABEL_TAC "F12")
	 THEN USE_THEN "F11" MP_TAC
	 THEN REWRITE_TAC[lemma_def_path]
	 THEN DISCH_THEN (MP_TAC o SPEC `i:num`)
	 THEN USE_THEN "F12" (fun th -> REWRITE_TAC[th])
	 THEN USE_THEN "F11" (MP_TAC o SPEC `i:num` o MATCH_MP lemma_subpath)
	 THEN USE_THEN "F12" (fun th -> (REWRITE_TAC[MATCH_MP LT_IMP_LE th]))
	 THEN DISCH_TAC
	 THEN SUBGOAL_THEN `(p:num->A) (i:num) IN comb_component (H:(A)hypermap) (y:A)` (LABEL_TAC "F14")
	 THENL[REWRITE_TAC[comb_component; IN_ELIM_THM]
		 THEN REWRITE_TAC[is_in_component]
		 THEN EXISTS_TAC `p:num->A`
		THEN EXISTS_TAC `i:num`
		THEN ASM_SIMP_TAC[]; ALL_TAC]
	 THEN REPLICATE_TAC 7 (FIRST_X_ASSUM(MP_TAC o (SPEC `(p:num->A) (i:num)`) o check(is_forall o concl)))
	 THEN ASM_REWRITE_TAC[]
	 THEN REPLICATE_TAC 7 STRIP_TAC
	 THEN REWRITE_TAC[go_one_step]
	 THEN MP_TAC (CONJUNCT2(CONJUNCT2(CONJUNCT2(SPECL[`H:(A)hypermap`; `x:A`; `(p:num->A) (i:num)`] edge_map_walkup))))
	 THEN ASM_REWRITE_TAC[]
	 THEN DISCH_THEN SUBST1_TAC
	 THEN MP_TAC (CONJUNCT2(CONJUNCT2(SPECL[`H:(A)hypermap`; `x:A`; `(p:num->A) (i:num)`] node_map_walkup)))
	 THEN ASM_REWRITE_TAC[]
	 THEN DISCH_THEN SUBST1_TAC
	 THEN MP_TAC (CONJUNCT2(CONJUNCT2(SPECL[`H:(A)hypermap`; `x:A`; `(p:num->A) (i:num)`] face_map_walkup)))
	 THEN ASM_REWRITE_TAC[]
	 THEN DISCH_THEN SUBST1_TAC THEN SIMP_TAC[]; ALL_TAC]
   THEN DISCH_THEN (X_CHOOSE_THEN `p:num->A` (X_CHOOSE_THEN `m:num` (CONJUNCTS_THEN2 (LABEL_TAC "F9") (CONJUNCTS_THEN2 (LABEL_TAC "F10") (LABEL_TAC "F11")))))
   THEN EXISTS_TAC `p:num->A` THEN EXISTS_TAC `m:num`
   THEN ASM_REWRITE_TAC[]
   THEN SUBGOAL_THEN `!k:num. k <= m ==> is_path (H:(A)hypermap) (p:num->A) k` ASSUME_TAC
   THENL[INDUCT_TAC THENL[REWRITE_TAC[is_path]; ALL_TAC]
	   THEN POP_ASSUM (LABEL_TAC "F12")
	   THEN DISCH_THEN (LABEL_TAC "F14")
	   THEN REMOVE_THEN "F12" MP_TAC
	   THEN USE_THEN "F14" (fun th-> (REWRITE_TAC[MP (ARITH_RULE `SUC (k:num) <= m:num ==> k <= m`) th]))
	   THEN REWRITE_TAC[is_path]
	   THEN DISCH_THEN (LABEL_TAC "F15")
	   THEN REWRITE_TAC[is_path]
	   THEN USE_THEN "F15" (fun th -> REWRITE_TAC[th])
	   THEN USE_THEN "F11" (MP_TAC o SPEC `SUC (k:num)` o MATCH_MP lemma_subpath)
	   THEN USE_THEN "F14" (fun th -> (REWRITE_TAC[th]))
	   THEN REWRITE_TAC[is_path]
	   THEN DISCH_THEN (MP_TAC o CONJUNCT2)
	   THEN SUBGOAL_THEN `(p:num->A) (k:num) IN comb_component (H:(A)hypermap) (y:A)` (LABEL_TAC "F16")
	   THENL[REWRITE_TAC[comb_component; IN_ELIM_THM]
		  THEN REWRITE_TAC[is_in_component]
		  THEN EXISTS_TAC `p:num->A`
		  THEN EXISTS_TAC `k:num`
		  THEN ASM_SIMP_TAC[]; ALL_TAC]
	   THEN REPLICATE_TAC 7 (FIRST_X_ASSUM(MP_TAC o (SPEC `(p:num->A) (k:num)`) o check(is_forall o concl)))
	   THEN POP_ASSUM (fun th -> REWRITE_TAC[th])
	   THEN REPLICATE_TAC 7 STRIP_TAC
	   THEN REWRITE_TAC[go_one_step]
	   THEN MP_TAC (CONJUNCT2(CONJUNCT2(CONJUNCT2(SPECL[`H:(A)hypermap`; `x:A`; `(p:num->A) (k:num)`] edge_map_walkup))))
	   THEN ASM_REWRITE_TAC[]
	   THEN DISCH_THEN SUBST1_TAC
	   THEN MP_TAC (CONJUNCT2(CONJUNCT2(SPECL[`H:(A)hypermap`; `x:A`; `(p:num->A) (k:num)`] node_map_walkup)))
	   THEN ASM_REWRITE_TAC[]
	   THEN DISCH_THEN SUBST1_TAC
	   THEN MP_TAC (CONJUNCT2(CONJUNCT2(SPECL[`H:(A)hypermap`; `x:A`; `(p:num->A) (k:num)`] face_map_walkup)))
	   THEN ASM_REWRITE_TAC[]
	   THEN DISCH_THEN SUBST1_TAC
	   THEN SIMP_TAC[]; ALL_TAC]
   THEN POP_ASSUM (MP_TAC o SPEC `m:num`) THEN REWRITE_TAC[LE_REFL]);;

let lemma_walkup_second_component_eq = prove(`!(H:(A)hypermap) (x:A) (y:A).x IN dart H /\ y IN dart H /\ ~(y = x) /\ ~((inverse (edge_map H)) x IN comb_component (edge_walkup H x) y) /\  ~(node_map H x IN comb_component (edge_walkup H x) y) ==> comb_component H y = comb_component (edge_walkup H x) y /\ ~(y IN comb_component H x)`,
   REPEAT GEN_TAC
   THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F1") (CONJUNCTS_THEN2 (LABEL_TAC "F2") (CONJUNCTS_THEN2 (LABEL_TAC "F3") (CONJUNCTS_THEN2 (LABEL_TAC "F4") (LABEL_TAC "F5")))))
   THEN label_hypermap_TAC `H:(A)hypermap`
   THEN ABBREV_TAC `D = dart (H:(A)hypermap)` 
   THEN ABBREV_TAC `e = edge_map (H:(A)hypermap)` 
   THEN ABBREV_TAC `n = node_map (H:(A)hypermap)` 
   THEN ABBREV_TAC `f = face_map (H:(A)hypermap)`
   THEN ABBREV_TAC `D' = dart (edge_walkup (H:(A)hypermap) (x:A))`
   THEN ABBREV_TAC `e' = edge_map (edge_walkup (H:(A)hypermap) (x:A))`
   THEN ABBREV_TAC `n' = node_map (edge_walkup (H:(A)hypermap) (x:A))`
   THEN ABBREV_TAC `f' = face_map (edge_walkup (H:(A)hypermap) (x:A))`
   THEN ABBREV_TAC `G = edge_walkup (H:(A)hypermap) (x:A)`
   THEN MP_TAC (CONJUNCT1(SPECL[`H:(A)hypermap`; `x:A`] lemma_edge_walkup))
   THEN ASM_REWRITE_TAC[]
   THEN DISCH_THEN (LABEL_TAC "F6")
   THEN MP_TAC (SPEC `edge_walkup (H:(A)hypermap) (x:A)` hypermap_lemma)
   THEN ASM_REWRITE_TAC[]
   THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "W1") (CONJUNCTS_THEN2 (LABEL_TAC "W2") (CONJUNCTS_THEN2 (LABEL_TAC "W3") (LABEL_TAC "W4" o CONJUNCT1))))
   THEN SUBGOAL_THEN `(y:A) IN ((D:A->bool) DELETE (x:A))` (LABEL_TAC "F7")
   THENL[SET_TAC[]; ALL_TAC]
   THEN SUBGOAL_THEN `!z:A. z IN comb_component (G:(A)hypermap) (y:A) ==> ~(z = (x:A))` (LABEL_TAC "F8")
   THENL[GEN_TAC THEN STRIP_TAC
	   THEN  MP_TAC (SPECL[`G:(A)hypermap`; `y:A`] lemma_component_subset)
	   THEN  ASM_REWRITE_TAC[] 
	   THEN REWRITE_TAC[SUBSET]
	   THEN DISCH_THEN (MP_TAC o SPEC `z:A`)
	   THEN POP_ASSUM (fun th -> REWRITE_TAC[th; IN_DELETE])
	   THEN SIMP_TAC[]; ALL_TAC]
   THEN SUBGOAL_THEN `!z:A. z IN comb_component (G:(A)hypermap) (y:A) ==> ~(z = (n:A->A) (x:A))` (LABEL_TAC "F9")
   THENL[GEN_TAC THEN (DISCH_THEN (LABEL_TAC "G1"))
	   THEN REMOVE_THEN "F5" MP_TAC THEN REWRITE_TAC[CONTRAPOS_THM]
	   THEN DISCH_THEN (SUBST1_TAC o SYM)
	   THEN POP_ASSUM (fun th -> REWRITE_TAC[th]); ALL_TAC]
   THEN SUBGOAL_THEN `!z:A. z IN comb_component (G:(A)hypermap) (y:A) ==> ~(z = (inverse(e:A->A)) (x:A))` (LABEL_TAC "F10")
   THENL[GEN_TAC THEN (DISCH_THEN (LABEL_TAC "G1"))
	   THEN REMOVE_THEN "F4" MP_TAC THEN REWRITE_TAC[CONTRAPOS_THM]
	   THEN DISCH_THEN (SUBST1_TAC o SYM)
	   THEN POP_ASSUM (fun th -> REWRITE_TAC[th]); ALL_TAC]
   THEN SUBGOAL_THEN `!z:A. z IN comb_component (G:(A)hypermap) (y:A) ==> ~(z = (inverse(n:A->A)) (x:A))` (LABEL_TAC "F11")
   THENL[ GEN_TAC THEN (DISCH_THEN (LABEL_TAC "G1"))
	     THEN  REMOVE_THEN "F5" MP_TAC THEN REWRITE_TAC[CONTRAPOS_THM]
	     THEN  DISCH_THEN (MP_TAC o AP_TERM `node_map (edge_walkup (H:(A)hypermap) (x:A))`)
	     THEN  EXPAND_TAC "n"
	     THEN  REWRITE_TAC[node_map_walkup]
	     THEN  ASM_REWRITE_TAC[]
	     THEN  DISCH_TAC
	     THEN  MP_TAC (CONJUNCT1(CONJUNCT2(SPECL[`G:(A)hypermap`; `z:A`; `1`]  lemma_powers_in_component)))
	     THEN  ASM_REWRITE_TAC[POWER_1]
	     THEN  POP_ASSUM (SUBST1_TAC o SYM)
	     THEN  POP_ASSUM (fun th -> REWRITE_TAC[MATCH_MP lemma_component_identity th]); ALL_TAC]
   THEN SUBGOAL_THEN `!z:A. z IN comb_component (G:(A)hypermap) (y:A) ==> ~(z = (inverse(f:A->A)) (x:A))` (LABEL_TAC "F12")
   THENL[GEN_TAC THEN (DISCH_THEN (LABEL_TAC "G1"))
	    THEN REMOVE_THEN "F4" MP_TAC THEN REWRITE_TAC[CONTRAPOS_THM]
	    THEN ASM_CASES_TAC `(inverse(f:A->A)) (x:A) = x`
            THENL[POP_ASSUM SUBST1_TAC
		    THEN USE_THEN "F8" (MP_TAC o SPEC `z:A`)
		    THEN POP_ASSUM (fun th -> REWRITE_TAC[th])
		    THEN SIMP_TAC[]; ALL_TAC]
	    THEN ASM_CASES_TAC `inverse(e:A->A) (x:A) = x`
            THENL[USE_THEN "H2" (MP_TAC o SPEC `x:A` o  MATCH_MP fixed_point_lemma)
		    THEN POP_ASSUM (fun th ->  REWRITE_TAC[th])
		    THEN EXPAND_TAC "e"
		    THEN REWRITE_TAC[lemma_edge_degenarate]
		    THEN ASM_REWRITE_TAC[]
		    THEN DISCH_THEN ASSUME_TAC
		    THEN DISCH_THEN (MP_TAC o AP_TERM `f':A->A`)
		    THEN MP_TAC (CONJUNCT1(CONJUNCT2(SPECL[`H:(A)hypermap`; `x:A`; `x:A`]  face_map_walkup)))
		    THEN ASM_REWRITE_TAC[]
		    THEN DISCH_THEN SUBST1_TAC
		    THEN DISCH_TAC
		    THEN MP_TAC(CONJUNCT2(CONJUNCT2(SPECL[`G:(A)hypermap`; `z:A`; `1`] lemma_powers_in_component)))
		    THEN ASM_REWRITE_TAC[POWER_1]
		    THEN USE_THEN "G1" (fun th1 -> (DISCH_THEN (fun th2 -> (MP_TAC (MATCH_MP lemma_component_trans (CONJ th1 th2))))))
		    THEN DISCH_TAC
		    THEN USE_THEN "F11" (MP_TAC o SPEC `(inverse (n:A->A)) (x:A)`)
		    THEN POP_ASSUM (fun th -> REWRITE_TAC[th]); ALL_TAC]
	    THEN MP_TAC (CONJUNCT1(CONJUNCT2(CONJUNCT2(SPECL[`H:(A)hypermap`; `x:A`; `x:A`]  edge_map_walkup))))
	    THEN ASM_REWRITE_TAC[]
	    THEN DISCH_THEN (SUBST1_TAC o SYM)
	    THEN DISCH_THEN (fun th1 -> (USE_THEN "W2" (fun th2 -> (MP_TAC (MATCH_MP inverse_function (CONJ th2 (SYM th1)))))))
	    THEN DISCH_THEN SUBST1_TAC
	    THEN MP_TAC(CONJUNCT1(SPECL[`G:(A)hypermap`; `z:A`; `1`] lemma_inverses_in_component))
	    THEN ASM_REWRITE_TAC[]
	    THEN USE_THEN "G1" MP_TAC
	    THEN MESON_TAC[lemma_component_trans]; ALL_TAC]
  THEN SUBGOAL_THEN `comb_component (H:(A)hypermap) (y:A) = comb_component (G:(A)hypermap) (y:A)` (LABEL_TAC "FF")
  THENL[REWRITE_TAC[comb_component; is_in_component; EXTENSION; IN_ELIM_THM]
   THEN GEN_TAC THEN EQ_TAC
   THENL[DISCH_THEN (X_CHOOSE_THEN `p:num->A` (X_CHOOSE_THEN `m:num` (CONJUNCTS_THEN2 (LABEL_TAC "F14") (CONJUNCTS_THEN2 (LABEL_TAC "F15") (LABEL_TAC "F16")))))
	  THEN EXISTS_TAC `p:num->A` THEN EXISTS_TAC `m:num`
	  THEN ASM_REWRITE_TAC[]
	  THEN SUBGOAL_THEN `!k:num. k <= m:num ==> is_path (G:(A)hypermap) (p:num->A) k` ASSUME_TAC
	  THENL[INDUCT_TAC THENL[REWRITE_TAC[is_path]; ALL_TAC]
		  THEN POP_ASSUM (LABEL_TAC "G4")
		  THEN DISCH_THEN (LABEL_TAC "G5")
		  THEN REMOVE_THEN "G4" MP_TAC
		  THEN USE_THEN "G5" (fun th -> (REWRITE_TAC[MATCH_MP (ARITH_RULE `SUC (k:num) <= m ==> k <= m`) th]))
		  THEN DISCH_THEN (LABEL_TAC "G6")
		  THEN USE_THEN "F16" (MP_TAC o SPEC `SUC (k:num)` o MATCH_MP lemma_subpath)
		  THEN ASM_REWRITE_TAC[is_path]
		  THEN DISCH_THEN (MP_TAC o CONJUNCT2)
		  THEN ABBREV_TAC `z:A = (p:num->A) (k:num)`
	          THEN SUBGOAL_THEN `(z:A) IN comb_component (G:(A)hypermap) (y:A)` (LABEL_TAC "G7")
	          THENL[REWRITE_TAC[comb_component;IN_ELIM_THM] (*NOTE*)
			  THEN REWRITE_TAC[is_in_component]
			  THEN EXISTS_TAC `p:num->A`
			 THEN EXISTS_TAC `k:num`
			 THEN ASM_REWRITE_TAC[]; ALL_TAC]
		  THEN REPLICATE_TAC 5 (FIRST_X_ASSUM(MP_TAC o (SPEC `(p:num->A) (k:num)`) o check(is_forall o concl)))
		  THEN ASM_REWRITE_TAC[] THEN REPLICATE_TAC 5 STRIP_TAC
		  THEN REWRITE_TAC[go_one_step]
		  THEN MP_TAC (CONJUNCT2(CONJUNCT2(CONJUNCT2(SPECL[`H:(A)hypermap`; `x:A`; `(p:num->A) (k:num)`] edge_map_walkup))))
		  THEN ASM_REWRITE_TAC[]
		  THEN DISCH_THEN SUBST1_TAC
		  THEN  MP_TAC (CONJUNCT2(CONJUNCT2(SPECL[`H:(A)hypermap`; `x:A`; `(p:num->A) (k:num)`] node_map_walkup)))
		  THEN  ASM_REWRITE_TAC[]
		  THEN  DISCH_THEN SUBST1_TAC
		  THEN  MP_TAC (CONJUNCT2(CONJUNCT2(SPECL[`H:(A)hypermap`; `x:A`; `(p:num->A) (k:num)`] face_map_walkup)))
		  THEN  ASM_REWRITE_TAC[]
		  THEN DISCH_THEN SUBST1_TAC THEN SIMP_TAC[]; ALL_TAC]
	  THEN POP_ASSUM (MP_TAC o SPEC `m:num`)
	  THEN SIMP_TAC[LE_REFL]; ALL_TAC]
   THEN DISCH_THEN (X_CHOOSE_THEN `p:num->A` (X_CHOOSE_THEN `m:num` (CONJUNCTS_THEN2 (LABEL_TAC "F14") (CONJUNCTS_THEN2 (LABEL_TAC "F15") (LABEL_TAC "F16")))))
   THEN EXISTS_TAC `p:num->A` THEN EXISTS_TAC `m:num`
   THEN ASM_REWRITE_TAC[]
   THEN SUBGOAL_THEN `!k:num. k <= m ==> is_path (H:(A)hypermap) (p:num->A) k` ASSUME_TAC
   THENL[INDUCT_TAC THENL[REWRITE_TAC[is_path]; ALL_TAC]
	    THEN POP_ASSUM (LABEL_TAC "F17")
	    THEN DISCH_THEN (LABEL_TAC "F18")
	    THEN REMOVE_THEN "F17" MP_TAC
	    THEN USE_THEN "F18" (fun th-> (REWRITE_TAC[MP (ARITH_RULE `SUC (k:num) <= m:num ==> k <= m`) th]))
	    THEN REWRITE_TAC[is_path]
	    THEN DISCH_THEN (LABEL_TAC "F19")
	    THEN USE_THEN "F19" (fun th-> REWRITE_TAC[th])
	    THEN USE_THEN "F16" (MP_TAC o SPEC `SUC (k:num)` o MATCH_MP lemma_subpath)
	    THEN ASM_REWRITE_TAC[is_path]
	    THEN DISCH_THEN (fun th -> (LABEL_TAC "F20" (CONJUNCT1 th) THEN (MP_TAC(CONJUNCT2 th))))
	    THEN SUBGOAL_THEN `(p:num->A) (k:num) IN comb_component (G:(A)hypermap) (y:A)` (LABEL_TAC "F21")
	    THENL[REWRITE_TAC[comb_component; IN_ELIM_THM]
		    THEN REWRITE_TAC[is_in_component]
		    THEN EXISTS_TAC `p:num->A` THEN EXISTS_TAC `k:num` THEN ASM_SIMP_TAC[]; ALL_TAC]
	    THEN REPLICATE_TAC 5 (FIRST_X_ASSUM(MP_TAC o (SPEC `(p:num->A) (k:num)`) o check(is_forall o concl)))
	    THEN POP_ASSUM (fun th -> REWRITE_TAC[th])
	    THEN REPLICATE_TAC 5 STRIP_TAC
	    THEN REWRITE_TAC[go_one_step]
	    THEN MP_TAC (CONJUNCT2(CONJUNCT2(CONJUNCT2(SPECL[`H:(A)hypermap`; `x:A`; `(p:num->A) (k:num)`] edge_map_walkup))))
	    THEN ASM_REWRITE_TAC[]
	    THEN DISCH_THEN SUBST1_TAC
	    THEN MP_TAC (CONJUNCT2(CONJUNCT2(SPECL[`H:(A)hypermap`; `x:A`; `(p:num->A) (k:num)`] node_map_walkup)))
	    THEN ASM_REWRITE_TAC[]
	    THEN DISCH_THEN SUBST1_TAC
	    THEN MP_TAC (CONJUNCT2(CONJUNCT2(SPECL[`H:(A)hypermap`; `x:A`; `(p:num->A) (k:num)`] face_map_walkup)))
	    THEN ASM_REWRITE_TAC[]
	    THEN DISCH_THEN SUBST1_TAC THEN SIMP_TAC[]; ALL_TAC]
  THEN POP_ASSUM (MP_TAC o SPEC `m:num`) THEN REWRITE_TAC[LE_REFL]; ALL_TAC]
  THEN USE_THEN "FF" (fun th -> REWRITE_TAC[th])
  THEN ONCE_REWRITE_TAC[TAUT `~pp <=> (pp ==> F)`]
  THEN DISCH_THEN (ASSUME_TAC o MATCH_MP lemma_component_symmetry)
  THEN USE_THEN "F8" (MP_TAC o SPEC `x:A`)
  THEN USE_THEN "FF" (SUBST1_TAC o SYM)
  THEN POP_ASSUM (fun th -> REWRITE_TAC[th]));;


let lemma_walkup_components = prove(`!(H:(A)hypermap) (x:A). x IN dart H ==> set_of_components H DELETE comb_component H x = set_of_components (edge_walkup H x) DIFF {comb_component (edge_walkup H x) (node_map H x),  comb_component (edge_walkup H x) ((inverse (edge_map H)) x)}`,
   REPEAT GEN_TAC
   THEN REWRITE_TAC[set_of_components]
   THEN ABBREV_TAC `D = dart (H:(A)hypermap)`
   THEN ABBREV_TAC `D' = dart (edge_walkup (H:(A)hypermap) (x:A))`
   THEN REWRITE_TAC[set_part_components]
   THEN DISCH_THEN (LABEL_TAC "F1")
   THEN REWRITE_TAC[SET_RULE `s DIFF {a, b} = (s DELETE a) DELETE b`]
   THEN REWRITE_TAC[EXTENSION]
   THEN GEN_TAC
   THEN EQ_TAC
   THENL[REWRITE_TAC[IN_DELETE; IN_ELIM_THM]
      THEN DISCH_THEN (CONJUNCTS_THEN2 (X_CHOOSE_THEN `y:A` (CONJUNCTS_THEN2 (LABEL_TAC "F2") (LABEL_TAC "F3"))) (LABEL_TAC "F4"))
      THEN REMOVE_THEN "F3" SUBST_ALL_TAC
      THEN SUBGOAL_THEN `~(x:A IN comb_component (H:(A)hypermap) (y:A))` (LABEL_TAC "F5")
      THENL[POP_ASSUM MP_TAC
	   THEN REWRITE_TAC[CONTRAPOS_THM]
	   THEN MESON_TAC[lemma_component_identity]; ALL_TAC]
      THEN MP_TAC(SPECL[`H:(A)hypermap`; `x:A`; `y:A`] lemma_walkup_first_component_eq)
      THEN ASM_REWRITE_TAC[]
      THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F6") (CONJUNCTS_THEN2 (LABEL_TAC "F7") (LABEL_TAC "F8")))
      THEN SUBGOAL_THEN `~(comb_component (H:(A)hypermap) (y:A) = comb_component (edge_walkup H (x:A)) (inverse (edge_map H) x))` ASSUME_TAC
      THENL[POP_ASSUM MP_TAC
	   THEN REWRITE_TAC[CONTRAPOS_THM]
	   THEN DISCH_TAC
	   THEN MP_TAC(SPECL[`edge_walkup (H:(A)hypermap) (x:A)`; `(inverse (edge_map (H:(A)hypermap))) (x:A)`] lemma_component_reflect)
	   THEN POP_ASSUM (SUBST1_TAC o SYM)
	   THEN ASM_REWRITE_TAC[]; ALL_TAC]
      THEN POP_ASSUM (fun th -> REWRITE_TAC[th])
      THEN STRIP_TAC
      THENL[EXISTS_TAC `y:A`
	   THEN MP_TAC (CONJUNCT1(SPECL[`H:(A)hypermap`; `x:A`] lemma_edge_walkup))
	   THEN ASM_REWRITE_TAC[]
	   THEN DISCH_THEN SUBST1_TAC
	   THEN SET_TAC[]; ALL_TAC]
      THEN USE_THEN "F7" MP_TAC
      THEN REWRITE_TAC[CONTRAPOS_THM]
      THEN DISCH_TAC
      THEN MP_TAC(SPECL[`edge_walkup (H:(A)hypermap) (x:A)`; `node_map (H:(A)hypermap) (x:A)`] lemma_component_reflect)
      THEN POP_ASSUM (SUBST1_TAC o SYM)
      THEN ASM_REWRITE_TAC[]; ALL_TAC]
   THEN REWRITE_TAC[IN_DELETE; IN_ELIM_THM]
   THEN DISCH_THEN (CONJUNCTS_THEN2 (CONJUNCTS_THEN2 (X_CHOOSE_THEN `y:A` (CONJUNCTS_THEN2 (LABEL_TAC "F2") (LABEL_TAC "F3"))) (LABEL_TAC "F4")) (LABEL_TAC "F5"))
   THEN REMOVE_THEN "F3" SUBST_ALL_TAC
   THEN SUBGOAL_THEN `~((node_map (H:(A)hypermap)) (x:A) IN comb_component (edge_walkup (H:(A)hypermap) (x:A)) (y:A))` (LABEL_TAC "F6")
   THENL[USE_THEN "F4" MP_TAC
	   THEN REWRITE_TAC[CONTRAPOS_THM]
	   THEN MESON_TAC[lemma_component_identity]; ALL_TAC]
   THEN SUBGOAL_THEN `~((inverse (edge_map (H:(A)hypermap))) (x:A) IN comb_component (edge_walkup (H:(A)hypermap) (x:A)) (y:A))` (LABEL_TAC "F7")
   THENL[USE_THEN "F5" MP_TAC
	   THEN REWRITE_TAC[CONTRAPOS_THM]
	   THEN MESON_TAC[lemma_component_identity]; ALL_TAC]
   THEN MP_TAC (CONJUNCT1(SPECL[`H:(A)hypermap`; `x:A`] lemma_edge_walkup))
   THEN ASM_REWRITE_TAC[]
   THEN DISCH_THEN SUBST_ALL_TAC
   THEN USE_THEN "F2" MP_TAC
   THEN REWRITE_TAC[IN_DELETE]
   THEN STRIP_TAC
   THEN MP_TAC(SPECL[`H:(A)hypermap`; `x:A`; `y:A`] lemma_walkup_second_component_eq)
   THEN ASM_REWRITE_TAC[]
   THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F8") (LABEL_TAC "F9"))
   THEN STRIP_TAC
   THENL[EXISTS_TAC `y:A`
	   THEN USE_THEN "F8" (SUBST1_TAC o SYM)
	   THEN ASM_REWRITE_TAC[]; ALL_TAC]
   THEN USE_THEN "F8" (SUBST1_TAC o SYM)
   THEN POP_ASSUM MP_TAC
   THEN REWRITE_TAC[CONTRAPOS_THM]
   THEN DISCH_THEN (SUBST1_TAC o SYM)
   THEN REWRITE_TAC[lemma_component_reflect]);;


(* walkup at an edge-degenerate point *)

let edge_degenerate_walkup_edge_map = prove(`!(H:(A)hypermap) x:A y:A. x IN dart H /\ edge_map H x = x ==> edge_map (edge_walkup H x) y = edge_map H y`,
   REPEAT GEN_TAC
   THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F1") (LABEL_TAC "F2"))   
   THEN ASM_CASES_TAC `y:A = x:A`
   THENL[ASM_REWRITE_TAC[edge_map_walkup]; ALL_TAC]
   THEN label_hypermap4_TAC `edge_walkup (H:(A)hypermap) (x:A)`
   THEN ASM_CASES_TAC `y:A = (node_map (H:(A)hypermap)) (x:A)`
   THENL[POP_ASSUM SUBST1_TAC
	   THEN REWRITE_TAC[CONJUNCT1(SPEC `edge_walkup (H:(A)hypermap) (x:A)` inverse2_hypermap_maps); o_THM]
	   THEN GEN_REWRITE_TAC (RAND_CONV  o DEPTH_CONV) [GSYM o_THM]
	   THEN REWRITE_TAC[GSYM inverse_hypermap_maps]
	   THEN USE_THEN "H3" (fun th1 -> (USE_THEN "H4" (fun th2 -> (MP_TAC (SPECL[`node_map (H:(A)hypermap) (x:A)`; `(inverse(face_map (H:(A)hypermap))) (x:A)`] (MATCH_MP aux_permutes_conversion (CONJ th2 th1)))))))
	   THEN DISCH_THEN (fun th-> REWRITE_TAC[th])
	   THEN REWRITE_TAC[face_map_walkup]
	   THEN USE_THEN "F2" MP_TAC
	   THEN REWRITE_TAC[lemma_edge_degenarate]
	   THEN DISCH_THEN SUBST1_TAC
	   THEN REWRITE_TAC[node_map_walkup]; ALL_TAC]
   THEN MP_TAC (SPECL[`dart (H:(A)hypermap)`; `edge_map (H:(A)hypermap)`]  fixed_point_lemma)
   THEN REWRITE_TAC[SPEC `H:(A)hypermap` hypermap_lemma]
   THEN DISCH_THEN (MP_TAC o SPEC `x:A`)
   THEN USE_THEN "F2" (fun th -> REWRITE_TAC[th])
   THEN DISCH_TAC
   THEN MP_TAC(CONJUNCT2(CONJUNCT2(CONJUNCT2(SPECL[`H:(A)hypermap`; `x:A`; `y:A`] edge_map_walkup))))
   THEN ASM_REWRITE_TAC[]);;

(* walkup at a node-degenerate point *)

let node_degenerate_walkup_node_map = prove(`!(H:(A)hypermap) x:A y:A. x IN dart H /\ node_map H x = x ==> node_map (edge_walkup H x) y = node_map H y`,
   REPEAT GEN_TAC
   THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F1") (LABEL_TAC "F2"))
   THEN ASM_CASES_TAC `y:A = x:A`
   THENL[ASM_REWRITE_TAC[node_map_walkup]; ALL_TAC]
   THEN MP_TAC (SPECL[`dart (H:(A)hypermap)`; `node_map (H:(A)hypermap)`]  fixed_point_lemma)
   THEN REWRITE_TAC[SPEC `H:(A)hypermap` hypermap_lemma]
   THEN DISCH_THEN (MP_TAC o SPEC `x:A`)   
   THEN USE_THEN "F2" (fun th -> REWRITE_TAC[th])
   THEN DISCH_TAC
   THEN MP_TAC(CONJUNCT2(CONJUNCT2(SPECL[`H:(A)hypermap`; `x:A`; `y:A`] node_map_walkup)))
   THEN ASM_REWRITE_TAC[]);;

let node_degenerate_walkup_edge_map = prove(`!(H:(A)hypermap) x:A. x IN dart H /\ node_map H x = x ==> (edge_map (edge_walkup H x) x = x) /\ (edge_map (edge_walkup H x) ((inverse (edge_map H)) x) = edge_map H x) /\ (!y:A. ~(y = x) /\ ~(y = (inverse (edge_map H)) x) ==> edge_map (edge_walkup H x) y = edge_map H y)`,
   REPEAT GEN_TAC
   THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F1") (LABEL_TAC "F2"))
   THEN REWRITE_TAC[edge_map_walkup]
   THEN STRIP_TAC
   THENL[label_hypermap4_TAC `edge_walkup (H:(A)hypermap) (x:A)`
      THEN USE_THEN "F2" MP_TAC
      THEN REWRITE_TAC[lemma_node_degenarate]
      THEN DISCH_THEN SUBST1_TAC
      THEN REWRITE_TAC[CONJUNCT1(SPEC `edge_walkup (H:(A)hypermap) (x:A)` inverse2_hypermap_maps); o_THM]
      THEN USE_THEN "H3" (fun th1 -> (USE_THEN "H4" (fun th2 -> (MP_TAC (SPECL[`inverse(edge_map (H:(A)hypermap)) (x:A)`; `(inverse(face_map (H:(A)hypermap))) (x:A)`] (MATCH_MP aux_permutes_conversion (CONJ th2 th1)))))))  
      THEN DISCH_THEN (fun th-> REWRITE_TAC[th])
      THEN REWRITE_TAC[face_map_walkup]
      THEN ASM_CASES_TAC `face_map (H:(A)hypermap) (x:A) = x`
      THENL[MP_TAC(CONJUNCT1(SPEC `H:(A)hypermap` inverse_hypermap_maps))
	   THEN DISCH_THEN (fun th -> (MP_TAC (AP_THM th `x:A`)))
	   THEN ASM_REWRITE_TAC[o_THM]
	   THEN DISCH_THEN SUBST1_TAC
	   THEN REWRITE_TAC[node_map_walkup]; ALL_TAC]
      THEN MP_TAC (SPECL[`dart (H:(A)hypermap)`; `node_map (H:(A)hypermap)`]  fixed_point_lemma)
      THEN REWRITE_TAC[SPEC `H:(A)hypermap` hypermap_lemma]
      THEN DISCH_THEN (MP_TAC o SPEC `x:A`)
      THEN USE_THEN "F2" (fun th -> REWRITE_TAC[th])
      THEN DISCH_TAC
      THEN MP_TAC(CONJUNCT2(CONJUNCT2(SPECL[`H:(A)hypermap`; `x:A`; `face_map (H:(A)hypermap) (x:A)`] node_map_walkup)))
      THEN ASM_REWRITE_TAC[]
      THEN DISCH_THEN SUBST1_TAC
      THEN GEN_REWRITE_TAC(LAND_CONV o ONCE_DEPTH_CONV) [GSYM o_THM]
      THEN REWRITE_TAC[inverse_hypermap_maps]; ALL_TAC]
   THEN REPEAT STRIP_TAC
   THEN MP_TAC(CONJUNCT2(CONJUNCT2(CONJUNCT2(SPECL[`H:(A)hypermap`; `x:A`; `y:A`] edge_map_walkup))))
   THEN ASM_REWRITE_TAC[]);;

(* walkup at a node-degenerate point *)

let face_degenerate_walkup_face_map = prove(`!(H:(A)hypermap) x:A y:A. x IN dart H /\ face_map H x = x ==> face_map (edge_walkup H x) y = face_map H y`,
   REPEAT GEN_TAC
   THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F1") (LABEL_TAC "F2"))
   THEN ASM_CASES_TAC `y:A = x:A`
   THENL[ASM_REWRITE_TAC[face_map_walkup]; ALL_TAC]
   THEN MP_TAC (SPECL[`dart (H:(A)hypermap)`; `face_map (H:(A)hypermap)`]  fixed_point_lemma)
   THEN REWRITE_TAC[SPEC `H:(A)hypermap` hypermap_lemma]
   THEN DISCH_THEN (MP_TAC o SPEC `x:A`)   
   THEN USE_THEN "F2" (fun th -> REWRITE_TAC[th])
   THEN DISCH_TAC
   THEN MP_TAC(CONJUNCT2(CONJUNCT2(SPECL[`H:(A)hypermap`; `x:A`; `y:A`] face_map_walkup)))
   THEN ASM_REWRITE_TAC[]);;


let face_degenerate_walkup_edge_map = prove(`!(H:(A)hypermap) x:A. x IN dart H /\ face_map H x = x ==> (edge_map (edge_walkup H x) x = x) /\ (edge_map (edge_walkup H x) ((inverse (edge_map H)) x) = edge_map H x) /\ (!y:A. ~(y = x) /\ ~(y = (inverse (edge_map H)) x) ==> edge_map (edge_walkup H x) y = edge_map H y)`,
   REPEAT GEN_TAC
   THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F1") (LABEL_TAC "F2"))
   THEN REWRITE_TAC[edge_map_walkup]
   THEN USE_THEN "F2" MP_TAC
   THEN REWRITE_TAC[lemma_face_degenarate]
   THEN DISCH_THEN (LABEL_TAC "FG")   
   THEN STRIP_TAC
   THENL[label_hypermap4_TAC `edge_walkup (H:(A)hypermap) (x:A)`
      THEN USE_THEN "FG" (SUBST1_TAC o SYM)
      THEN USE_THEN "F2" MP_TAC
      THEN MP_TAC (SPECL[`dart (H:(A)hypermap)`; `face_map (H:(A)hypermap)`]  fixed_point_lemma)
      THEN REWRITE_TAC[SPEC `H:(A)hypermap` hypermap_lemma]
      THEN DISCH_THEN (MP_TAC o SPEC `x:A`)
      THEN USE_THEN "F2" (fun th -> REWRITE_TAC[th])
      THEN DISCH_THEN (LABEL_TAC "F3")
      THEN ASM_CASES_TAC `node_map (H:(A)hypermap) (x:A) = x`
      THENL[USE_THEN "FG" (MP_TAC o SYM)
	   THEN POP_ASSUM (fun th -> REWRITE_TAC[th])
	   THEN DISCH_TAC
	   THEN MP_TAC (SPECL[`dart (H:(A)hypermap)`; `edge_map (H:(A)hypermap)`]  fixed_point_lemma)
	   THEN REWRITE_TAC[SPEC `H:(A)hypermap` hypermap_lemma]
	   THEN DISCH_THEN (MP_TAC o SPEC `x:A`)
	   THEN POP_ASSUM (fun th -> REWRITE_TAC[th])
           THEN DISCH_THEN SUBST1_TAC
	   THEN REWRITE_TAC[edge_map_walkup]; ALL_TAC]   
      THEN REWRITE_TAC[CONJUNCT1(SPEC `edge_walkup (H:(A)hypermap) (x:A)` inverse2_hypermap_maps); o_THM]
      THEN USE_THEN "H3" (fun th1 -> (USE_THEN "H4" (fun th2 -> (MP_TAC (SPECL[`node_map (H:(A)hypermap) (x:A)`; `(edge_map (H:(A)hypermap)) (x:A)`] (MATCH_MP aux_permutes_conversion (CONJ th2 th1)))))))
      THEN DISCH_THEN (fun th-> REWRITE_TAC[th])
      THEN SUBGOAL_THEN `~(edge_map (H:(A)hypermap) (x:A) = x)` ASSUME_TAC
      THENL[POP_ASSUM MP_TAC
	  THEN REWRITE_TAC[CONTRAPOS_THM]
	  THEN DISCH_THEN ASSUME_TAC
	  THEN MP_TAC (SPECL[`dart (H:(A)hypermap)`; `edge_map (H:(A)hypermap)`]  fixed_point_lemma)
	  THEN REWRITE_TAC[SPEC `H:(A)hypermap` hypermap_lemma]
	  THEN DISCH_THEN (MP_TAC o SPEC `x:A`)
	  THEN POP_ASSUM (fun th -> REWRITE_TAC[th])
	  THEN USE_THEN "FG" (fun th -> REWRITE_TAC[SYM th])
	  THEN POP_ASSUM (fun th -> REWRITE_TAC[th]); ALL_TAC]
      THEN MP_TAC (CONJUNCT2(CONJUNCT2(SPECL[`H:(A)hypermap`; `x:A`; `edge_map (H:(A)hypermap) (x:A)`] face_map_walkup)))
      THEN ASM_REWRITE_TAC[]
      THEN DISCH_THEN  SUBST1_TAC
      THEN GEN_REWRITE_TAC (LAND_CONV o RAND_CONV o DEPTH_CONV) [GSYM o_THM]
      THEN REWRITE_TAC[GSYM inverse_hypermap_maps]
      THEN ASM_REWRITE_TAC[node_map_walkup]; ALL_TAC]
   THEN REPEAT STRIP_TAC
   THEN MP_TAC(CONJUNCT2(CONJUNCT2(CONJUNCT2(SPECL[`H:(A)hypermap`; `x:A`; `y:A`] edge_map_walkup))))
   THEN ASM_REWRITE_TAC[]);;


(* WALKUP AT A DEGENERATE DART: THREE WALKUPS ARE EQUAL *)


let edge_degenerate_walkup_first_eq =  prove(`!(H:(A)hypermap) x:A.x IN dart H /\  edge_map H x = x  ==> node_walkup H x = edge_walkup H x`,
     REPEAT GEN_TAC
     THEN label_4Gs_TAC (SPEC `H:(A)hypermap` shift_lemma)
     THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F1") (LABEL_TAC "F2"))
     THEN USE_THEN "F1" MP_TAC
     THEN USE_THEN "G1" SUBST1_TAC
     THEN DISCH_THEN (LABEL_TAC "F3")
     THEN USE_THEN "F2" MP_TAC
     THEN USE_THEN "G2" SUBST1_TAC
     THEN DISCH_THEN (LABEL_TAC "F4")
     THEN ONCE_REWRITE_TAC[lemma_hypermap_eq]
     THEN REWRITE_TAC[node_walkup]
     THEN ONCE_REWRITE_TAC[GSYM double_shift_lemma]
     THEN STRIP_TAC 
     THENL[REWRITE_TAC[lemma_edge_walkup]
        THEN USE_THEN "G1" (fun th -> REWRITE_TAC[th]); ALL_TAC]
     THEN STRIP_TAC
     THENL[ REWRITE_TAC[FUN_EQ_THM]
        THEN STRIP_TAC
        THEN MP_TAC (SPECL[`H:(A)hypermap`; `x:A`; `x':A`] edge_degenerate_walkup_edge_map)
        THEN ASM_REWRITE_TAC[]
        THEN DISCH_THEN SUBST1_TAC
        THEN MP_TAC (SPECL[`shift (H:(A)hypermap)`; `x:A`; `x':A`] face_degenerate_walkup_face_map)
        THEN ASM_REWRITE_TAC[]; ALL_TAC]
     THEN STRIP_TAC
     THENL[REWRITE_TAC[FUN_EQ_THM]
       THEN STRIP_TAC
       THEN ASM_CASES_TAC `x':A = (inverse (node_map (H:(A)hypermap))) (x:A)`
       THENL[ POP_ASSUM (LABEL_TAC "G1")
         THEN USE_THEN "G1" (fun th -> (GEN_REWRITE_TAC (RAND_CONV o ONCE_DEPTH_CONV) [th]))
         THEN REWRITE_TAC[node_map_walkup]
         THEN POP_ASSUM MP_TAC
         THEN USE_THEN "G3"  SUBST1_TAC
         THEN DISCH_THEN SUBST1_TAC
         THEN USE_THEN "F3" (fun th1 -> (USE_THEN "F4" (fun th2 -> (MP_TAC ( CONJUNCT1(CONJUNCT2(MATCH_MP face_degenerate_walkup_edge_map (CONJ th1 th2))))))))
	 THEN DISCH_THEN SUBST1_TAC
	 THEN SIMP_TAC[]; ALL_TAC]
       THEN ASM_CASES_TAC `x':A = x:A`
       THENL[ POP_ASSUM SUBST1_TAC
         THEN REWRITE_TAC[edge_map_walkup; node_map_walkup]; ALL_TAC]
       THEN MP_TAC (CONJUNCT2(CONJUNCT2(SPECL[`H:(A)hypermap`; `x:A`; `x':A`] node_map_walkup)))
       THEN ASM_REWRITE_TAC[]
       THEN DISCH_THEN SUBST1_TAC
       THEN USE_THEN "F3" (fun th1 -> (USE_THEN "F4" (fun th2 -> (MP_TAC ( CONJUNCT2(CONJUNCT2(MATCH_MP face_degenerate_walkup_edge_map (CONJ th1 th2))))))))
       THEN DISCH_THEN (MP_TAC o SPEC `x':A`)
       THEN USE_THEN "G3" (SUBST1_TAC o SYM)
       THEN ASM_REWRITE_TAC[]; ALL_TAC]
   THEN REWRITE_TAC[FUN_EQ_THM]
   THEN STRIP_TAC
   THEN ASM_CASES_TAC `x':A = (inverse (face_map (H:(A)hypermap))) (x:A)`
   THENL[POP_ASSUM (LABEL_TAC "G1")
	   THEN USE_THEN "G1" (fun th -> (GEN_REWRITE_TAC (RAND_CONV o ONCE_DEPTH_CONV) [th]))
	   THEN REWRITE_TAC[face_map_walkup]
	   THEN POP_ASSUM MP_TAC
	   THEN USE_THEN "G4"  SUBST1_TAC
	   THEN DISCH_THEN SUBST1_TAC
	   THEN REWRITE_TAC[node_map_walkup]; ALL_TAC]
   THEN ASM_CASES_TAC `x':A = x:A`
   THENL[POP_ASSUM SUBST1_TAC
	   THEN REWRITE_TAC[face_map_walkup; node_map_walkup]; ALL_TAC]
   THEN MP_TAC (CONJUNCT2(CONJUNCT2(SPECL[`H:(A)hypermap`; `x:A`; `x':A`] face_map_walkup)))
   THEN ASM_REWRITE_TAC[]
   THEN DISCH_THEN SUBST1_TAC
   THEN MP_TAC (CONJUNCT2(CONJUNCT2(SPECL[`shift (H:(A)hypermap)`; `x:A`; `x':A`] node_map_walkup)))
   THEN USE_THEN "G4" (fun th -> REWRITE_TAC[SYM th])
   THEN ASM_REWRITE_TAC[]);;


let edge_degenerate_walkup_second_eq =  prove(`!(H:(A)hypermap) x:A.x IN dart H /\  edge_map H x = x  ==> face_walkup H x = edge_walkup H x`,
   REPEAT GEN_TAC
   THEN label_4Gs_TAC (SPEC `H:(A)hypermap` double_shift_lemma)
   THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F1") (LABEL_TAC "F2"))
   THEN USE_THEN "F1" MP_TAC
   THEN USE_THEN "G1" SUBST1_TAC
   THEN DISCH_THEN (LABEL_TAC "F3")
   THEN USE_THEN "F2" MP_TAC
   THEN USE_THEN "G2" SUBST1_TAC
   THEN DISCH_THEN (LABEL_TAC "F4")
   THEN ONCE_REWRITE_TAC[lemma_hypermap_eq]
   THEN REWRITE_TAC[face_walkup]
   THEN ONCE_REWRITE_TAC[GSYM shift_lemma]
   THEN STRIP_TAC
   THENL[REWRITE_TAC[lemma_edge_walkup]
	   THEN USE_THEN "G1" (fun th -> REWRITE_TAC[th]); ALL_TAC]
   THEN STRIP_TAC
   THENL[REWRITE_TAC[FUN_EQ_THM]
      THEN STRIP_TAC
      THEN MP_TAC (SPECL[`H:(A)hypermap`; `x:A`; `x':A`] edge_degenerate_walkup_edge_map)
      THEN ASM_REWRITE_TAC[]
      THEN DISCH_THEN SUBST1_TAC
      THEN MP_TAC (SPECL[`shift(shift (H:(A)hypermap))`; `x:A`; `x':A`] node_degenerate_walkup_node_map)
      THEN ASM_REWRITE_TAC[]; ALL_TAC]
   THEN STRIP_TAC
   THENL[REWRITE_TAC[FUN_EQ_THM]
      THEN STRIP_TAC
      THEN ASM_CASES_TAC `x':A = (inverse (node_map (H:(A)hypermap))) (x:A)`
      THENL[POP_ASSUM (LABEL_TAC "G1")
	      THEN USE_THEN "G1" (fun th -> (GEN_REWRITE_TAC (RAND_CONV o ONCE_DEPTH_CONV) [th]))
	      THEN REWRITE_TAC[node_map_walkup]
	      THEN POP_ASSUM MP_TAC
	      THEN USE_THEN "G3"  SUBST1_TAC
	      THEN DISCH_THEN SUBST1_TAC
	      THEN REWRITE_TAC[face_map_walkup]; ALL_TAC]
      THEN ASM_CASES_TAC `x':A = x:A`
      THENL[POP_ASSUM SUBST1_TAC
	      THEN REWRITE_TAC[face_map_walkup; node_map_walkup]; ALL_TAC]
      THEN MP_TAC (CONJUNCT2(CONJUNCT2(SPECL[`H:(A)hypermap`; `x:A`; `x':A`] node_map_walkup)))
      THEN ASM_REWRITE_TAC[]
      THEN DISCH_THEN SUBST1_TAC
      THEN MP_TAC (CONJUNCT2(CONJUNCT2(SPECL[`shift(shift(H:(A)hypermap))`; `x:A`; `x':A`] face_map_walkup)))
      THEN POP_ASSUM (fun th -> REWRITE_TAC[th])
      THEN REMOVE_THEN "G3" (SUBST1_TAC o SYM)
      THEN POP_ASSUM (fun th -> REWRITE_TAC[th]); ALL_TAC]
   THEN REWRITE_TAC[FUN_EQ_THM] THEN STRIP_TAC
   THEN ASM_CASES_TAC `x':A = x:A`
   THENL[POP_ASSUM SUBST1_TAC
	   THEN REWRITE_TAC[face_map_walkup; edge_map_walkup]; ALL_TAC]
   THEN ASM_CASES_TAC `x':A = (inverse (face_map (H:(A)hypermap))) (x:A)`
   THENL[POP_ASSUM (LABEL_TAC "G1")
      THEN USE_THEN "G1" (fun th -> (GEN_REWRITE_TAC (RAND_CONV o ONCE_DEPTH_CONV) [th]))
      THEN REWRITE_TAC[face_map_walkup]
      THEN POP_ASSUM MP_TAC
      THEN USE_THEN "G4"  SUBST1_TAC
      THEN DISCH_THEN SUBST1_TAC
      THEN USE_THEN "F3" (fun th1 -> (USE_THEN "F4" (fun th2 -> (MP_TAC (CONJUNCT1(CONJUNCT2(MATCH_MP node_degenerate_walkup_edge_map (CONJ th1 th2))))))))
      THEN SIMP_TAC[]; ALL_TAC]
   THEN POP_ASSUM MP_TAC
   THEN USE_THEN "G4" SUBST1_TAC
   THEN DISCH_TAC
   THEN USE_THEN "F3" (fun th1 -> (USE_THEN "F4" (fun th2 -> (MP_TAC (CONJUNCT2(CONJUNCT2(MATCH_MP node_degenerate_walkup_edge_map (CONJ th1 th2))))))))
   THEN DISCH_THEN (MP_TAC o SPEC `x':A`)
   THEN ASM_REWRITE_TAC[]
   THEN DISCH_THEN SUBST1_TAC
   THEN USE_THEN "G4" (SUBST1_TAC o SYM)
   THEN POP_ASSUM MP_TAC
   THEN USE_THEN "G4" (SUBST1_TAC o SYM)
   THEN DISCH_TAC
   THEN MP_TAC(CONJUNCT2(CONJUNCT2(SPECL[`H:(A)hypermap`; `x:A`; `x':A`] face_map_walkup)))
   THEN ASM_REWRITE_TAC[]
   THEN DISCH_THEN SUBST1_TAC
   THEN SIMP_TAC[]);;


let edge_degenerate_walkup_third_eq = prove(`!(H:(A)hypermap) x:A.x IN dart H /\  edge_map H x = x  ==> node_walkup H x = face_walkup H x`,
   REPEAT GEN_TAC
   THEN  DISCH_THEN (LABEL_TAC "F1")
   THEN USE_THEN "F1" (MP_TAC o MATCH_MP edge_degenerate_walkup_first_eq)
   THEN DISCH_THEN SUBST1_TAC
   THEN CONV_TAC SYM_CONV
   THEN MATCH_MP_TAC edge_degenerate_walkup_second_eq
   THEN ASM_REWRITE_TAC[]);;

let lemma_shift_cycle = prove(`!(H:(A)hypermap). shift (shift (shift H)) = H`,
   GEN_TAC
   THEN ONCE_REWRITE_TAC[lemma_hypermap_eq]
   THEN REWRITE_TAC[GSYM shift_lemma]);;

let lemma_eq_iff_shift_eq = prove(`!(H:(A)hypermap) (H':(A)hypermap). H = H' <=> shift H = shift H'`,
   REPEAT GEN_TAC
   THEN EQ_TAC
   THENL[DISCH_THEN SUBST1_TAC THEN SIMP_TAC[]; ALL_TAC]
   THEN REWRITE_TAC[lemma_hypermap_eq; GSYM shift_lemma]
   THEN MESON_TAC[]);;

let lemma_degenerate_walkup_first_eq = prove(`!(H:(A)hypermap) x:A. x IN dart H /\ dart_degenerate H x ==> node_walkup H x = edge_walkup H x`,
   REPEAT GEN_TAC
   THEN REWRITE_TAC[dart_degenerate]
   THEN STRIP_TAC
   THENL[MATCH_MP_TAC edge_degenerate_walkup_first_eq
      THEN ASM_REWRITE_TAC[]; 
      label_4Gs_TAC (SPEC `H:(A)hypermap` shift_lemma)
      THEN UNDISCH_TAC `x:A IN dart (H:(A)hypermap)`
      THEN UNDISCH_TAC `node_map (H:(A)hypermap) (x:A) = x`
      THEN ASM_REWRITE_TAC[]
      THEN DISCH_THEN (LABEL_TAC "F1")
      THEN DISCH_THEN (LABEL_TAC "F2")
      THEN REWRITE_TAC[node_walkup]
      THEN ONCE_REWRITE_TAC[lemma_eq_iff_shift_eq]
      THEN REWRITE_TAC[lemma_shift_cycle]
      THEN MP_TAC(SPECL[`shift (H:(A)hypermap)`; `x:A`] edge_degenerate_walkup_second_eq)
      THEN ASM_REWRITE_TAC[]
      THEN DISCH_THEN (SUBST1_TAC o SYM)
      THEN REWRITE_TAC[face_walkup]
      THEN REWRITE_TAC[lemma_shift_cycle]; ALL_TAC]
   THEN label_4Gs_TAC (SPEC `H:(A)hypermap` double_shift_lemma)
   THEN UNDISCH_TAC `x:A IN dart (H:(A)hypermap)`
   THEN UNDISCH_TAC `face_map (H:(A)hypermap) (x:A) = x`
   THEN ASM_REWRITE_TAC[]
   THEN DISCH_THEN (LABEL_TAC "F1")
   THEN DISCH_THEN (LABEL_TAC "F2")
   THEN MP_TAC(SPECL[`shift(shift (H:(A)hypermap))`; `x:A`] edge_degenerate_walkup_third_eq)
   THEN ASM_REWRITE_TAC[]
   THEN ASM_REWRITE_TAC[face_walkup; node_walkup]
   THEN REWRITE_TAC[lemma_shift_cycle]
   THEN DISCH_THEN (MP_TAC o SYM o AP_TERM `shift:((A)hypermap) -> ((A)hypermap)`)
   THEN REWRITE_TAC[lemma_shift_cycle]);;

let lemma_degenerate_walkup_second_eq = prove(`!(H:(A)hypermap) x:A. x IN dart H /\ dart_degenerate H x ==> face_walkup H x = edge_walkup H x`,
   REPEAT GEN_TAC
   THEN REWRITE_TAC[dart_degenerate]
   THEN STRIP_TAC
   THENL[MATCH_MP_TAC edge_degenerate_walkup_second_eq
	 THEN ASM_REWRITE_TAC[];
         label_4Gs_TAC (SPEC `H:(A)hypermap` shift_lemma)
         THEN UNDISCH_TAC `x:A IN dart (H:(A)hypermap)`
         THEN UNDISCH_TAC `node_map (H:(A)hypermap) (x:A) = x`
         THEN ASM_REWRITE_TAC[]
         THEN DISCH_THEN (LABEL_TAC "F1")
         THEN DISCH_THEN (LABEL_TAC "F2")
         THEN REWRITE_TAC[face_walkup]
         THEN MP_TAC(SPECL[`shift (H:(A)hypermap)`; `x:A`] edge_degenerate_walkup_third_eq)
         THEN ASM_REWRITE_TAC[]
         THEN REWRITE_TAC[node_walkup; face_walkup]
         THEN REWRITE_TAC[GSYM lemma_eq_iff_shift_eq; lemma_shift_cycle]; ALL_TAC]
   THEN label_4Gs_TAC (SPEC `H:(A)hypermap` double_shift_lemma)
   THEN UNDISCH_TAC `x:A IN dart (H:(A)hypermap)`
   THEN UNDISCH_TAC `face_map (H:(A)hypermap) (x:A) = x`
   THEN ASM_REWRITE_TAC[]
   THEN DISCH_THEN (LABEL_TAC "F1")
   THEN DISCH_THEN (LABEL_TAC "F2")
   THEN REWRITE_TAC[face_walkup]
   THEN MP_TAC(SPECL[`shift(shift (H:(A)hypermap))`; `x:A`] edge_degenerate_walkup_first_eq)
   THEN ASM_REWRITE_TAC[node_walkup; lemma_shift_cycle]
   THEN DISCH_THEN (MP_TAC o SYM o AP_TERM `shift:((A)hypermap) -> ((A)hypermap)`)
   THEN REWRITE_TAC[lemma_shift_cycle]);;

let lemma_degenerate_walkup_third_eq = prove(`!(H:(A)hypermap) x:A.x IN dart H /\ dart_degenerate H x ==> node_walkup H x = face_walkup H x`,
   REPEAT GEN_TAC
   THEN  DISCH_THEN (LABEL_TAC "F1")
   THEN USE_THEN "F1" (MP_TAC o MATCH_MP lemma_degenerate_walkup_first_eq)
   THEN DISCH_THEN SUBST1_TAC
   THEN CONV_TAC SYM_CONV
   THEN MATCH_MP_TAC lemma_degenerate_walkup_second_eq
   THEN ASM_REWRITE_TAC[]);;

(* I prove that walkup at a degenerate dart do not change the plannar indices *)


let component_at_isolated_dart = prove(`!(H:(A)hypermap) x:A. isolated_dart H x ==> comb_component H x = {x}`,
   REPEAT GEN_TAC
   THEN REWRITE_TAC[isolated_dart]
   THEN REPEAT STRIP_TAC
   THEN REWRITE_TAC[comb_component; EXTENSION; IN_ELIM_THM; IN_SING; is_in_component]
   THEN GEN_TAC
   THEN REWRITE_TAC[lemma_def_path]
   THEN EQ_TAC
   THENL[STRIP_TAC
	THEN SUBGOAL_THEN `!j:num. j <= n:num ==> (p:num->A) j = x:A` (LABEL_TAC "F1")
	THENL[INDUCT_TAC THENL[ASM_REWRITE_TAC[]; ALL_TAC]
           THEN DISCH_THEN (LABEL_TAC "F1")
	   THEN FIRST_ASSUM (MP_TAC o SPEC `j:num` o  check (is_forall o concl))
	   THEN USE_THEN "F1" (fun th -> REWRITE_TAC[MP (ARITH_RULE `SUC (j:num) <= n:num ==> j < n`) th])
	   THEN REWRITE_TAC[go_one_step]
	   THEN FIRST_ASSUM (MP_TAC o check (is_imp o concl))
	   THEN USE_THEN "F1" (fun th -> REWRITE_TAC[MP (ARITH_RULE `SUC (j:num) <= n:num ==> j <= n`) th])
	   THEN DISCH_THEN SUBST1_TAC
	   THEN ASM_REWRITE_TAC[]; ALL_TAC]
	THEN POP_ASSUM (MP_TAC o SPEC `n:num`)
	THEN REWRITE_TAC[LE_REFL]
	THEN FIRST_ASSUM SUBST1_TAC
	THEN DISCH_THEN SUBST1_TAC
	THEN SIMP_TAC[]; ALL_TAC]
   THEN STRIP_TAC
   THEN EXISTS_TAC `(\k:num. x:A)`
   THEN EXISTS_TAC `0`
   THEN ASM_REWRITE_TAC[]
   THEN ARITH_TAC);;

let LEMMA_CARD_DIFF = prove(`!(s:A->bool) (t:A->bool). FINITE s /\ t SUBSET s ==> CARD s = CARD (s DIFF t) + CARD t`,
   REPEAT STRIP_TAC
   THEN CONV_TAC SYM_CONV
   THEN MATCH_MP_TAC CARD_UNION_EQ
   THEN ASM_SIMP_TAC[] THEN SET_TAC[]);;

let CARD_MINUS_ONE = prove(`!(s:B -> bool) (x:B). FINITE s /\ x IN s ==> CARD s = CARD (s DELETE x) + 1`,
   REPEAT STRIP_TAC
   THEN ASSUME_TAC (ISPECL[`x:B`; `s:B->bool`] DELETE_SUBSET)
   THEN MP_TAC (ISPECL[`(s:B->bool) DELETE (x:B)`; `s:B->bool`] FINITE_SUBSET)
   THEN ASM_REWRITE_TAC[]
   THEN DISCH_TAC
   THEN MP_TAC(ISPECL[`x:B`; `(s:B->bool) DELETE (x:B)`] (CONJUNCT2 CARD_CLAUSES))
   THEN ASM_REWRITE_TAC[IN_DELETE]
   THEN MP_TAC(ISPECL[`x:B`; `s:B->bool`] INSERT_DELETE)
   THEN ASM_REWRITE_TAC[]
   THEN DISCH_THEN SUBST1_TAC
   THEN ARITH_TAC);;

let CARD_MINUS_DIFF_TWO_SET = prove(`!(s:B -> bool) (x:B) (y:B). FINITE s /\ x IN s /\ y IN s ==> CARD s = CARD (s DIFF {x, y}) + CARD {x,y}`,
   REPEAT STRIP_TAC
   THEN MATCH_MP_TAC LEMMA_CARD_DIFF
   THEN SET_TAC[]);;

let EDGE_FINITE = prove(`!(H:(A)hypermap) (x:A). FINITE (edge H x)`,
   REPEAT GEN_TAC
   THEN REWRITE_TAC[edge]
   THEN MATCH_MP_TAC lemma_orbit_finite
   THEN EXISTS_TAC `dart (H:(A)hypermap)`
   THEN REWRITE_TAC[hypermap_lemma]);;

let EDGE_NOT_EMPTY = prove(`!(H:(A)hypermap) (x:A). 1 <= CARD (edge H x)`,
   REPEAT GEN_TAC THEN MATCH_MP_TAC CARD_ATLEAST_1
   THEN EXISTS_TAC `x:A`
   THEN REWRITE_TAC[EDGE_FINITE; edge]
   THEN REWRITE_TAC[orbit_reflect]);;

let NODE_FINITE = prove(`!(H:(A)hypermap) (x:A). FINITE (node H x)`,
   REPEAT GEN_TAC
   THEN REWRITE_TAC[node]
   THEN MATCH_MP_TAC lemma_orbit_finite
   THEN EXISTS_TAC `dart (H:(A)hypermap)`
   THEN REWRITE_TAC[hypermap_lemma]);;

let NODE_NOT_EMPTY = prove(`!(H:(A)hypermap) (x:A). 1 <= CARD (node H x)`,
   REPEAT GEN_TAC THEN MATCH_MP_TAC CARD_ATLEAST_1
   THEN EXISTS_TAC `x:A`
   THEN REWRITE_TAC[NODE_FINITE; node]
   THEN REWRITE_TAC[orbit_reflect]);;

let FACE_FINITE = prove(`!(H:(A)hypermap) (x:A). FINITE (face H x)`,
   REPEAT GEN_TAC
   THEN REWRITE_TAC[face]
   THEN MATCH_MP_TAC lemma_orbit_finite
   THEN EXISTS_TAC `dart (H:(A)hypermap)`
   THEN REWRITE_TAC[hypermap_lemma]);;

let FACE_NOT_EMPTY = prove(`!(H:(A)hypermap) (x:A). 1 <= CARD (face H x)`,
   REPEAT GEN_TAC THEN MATCH_MP_TAC CARD_ATLEAST_1
   THEN EXISTS_TAC `x:A`
   THEN REWRITE_TAC[FACE_FINITE; face]
   THEN REWRITE_TAC[orbit_reflect]);;

let FINITE_HYPERMAP_ORBITS = prove(`!(H:(A)hypermap). FINITE (edge_set H) /\ FINITE (node_set H) /\ FINITE (face_set H)`,
   GEN_TAC THEN REWRITE_TAC[edge_set; node_set; face_set] THEN REPEAT STRIP_TAC
   THENL[MATCH_MP_TAC finite_orbits_lemma THEN REWRITE_TAC[hypermap_lemma];
     MATCH_MP_TAC finite_orbits_lemma THEN REWRITE_TAC[hypermap_lemma];
     MATCH_MP_TAC finite_orbits_lemma THEN REWRITE_TAC[hypermap_lemma]]);;

let FINITE_HYPERMAP_COMPONENTS = prove(`!H:(A)hypermap. FINITE (set_of_components H)`,
   GEN_TAC THEN REWRITE_TAC[set_of_components] THEN label_hypermap4_TAC `H:(A)hypermap`
   THEN ABBREV_TAC `D = dart (H:(A)hypermap)`  
   THEN ABBREV_TAC `e = edge_map (H:(A)hypermap)`  
   THEN ABBREV_TAC `n = node_map (H:(A)hypermap)` 
   THEN ABBREV_TAC `f = face_map (H:(A)hypermap)`
   THEN SUBGOAL_THEN `IMAGE (\x:A. comb_component (H:(A)hypermap) (x:A)) (D:A->bool) = set_part_components H D` ASSUME_TAC
   THENL[REWRITE_TAC[EXTENSION] THEN STRIP_TAC THEN EQ_TAC
       THENL[REWRITE_TAC[set_part_components;IMAGE;IN;IN_ELIM_THM]; 
           REWRITE_TAC[set_part_components;IMAGE;IN;IN_ELIM_THM]]; ALL_TAC]
   THEN POP_ASSUM (fun th -> REWRITE_TAC[SYM th])
   THEN MATCH_MP_TAC FINITE_IMAGE THEN ASM_SIMP_TAC[]);;

let WALKUP_EXCEPTION_COMPONENT = prove(`!(H:(A)hypermap) x:A. x IN dart H ==> comb_component (edge_walkup H x) x = {x}`,
   REPEAT STRIP_TAC
   THEN ASSUME_TAC (CONJUNCT1 (SPECL[`H:(A)hypermap`; `x:A`; `x:A`] edge_map_walkup))
   THEN ASSUME_TAC (CONJUNCT1 (SPECL[`H:(A)hypermap`; `x:A`; `x:A`] node_map_walkup))
   THEN ASSUME_TAC (CONJUNCT1 (SPECL[`H:(A)hypermap`; `x:A`; `x:A`] face_map_walkup))
   THEN ABBREV_TAC `G = edge_walkup (H:(A)hypermap) (x:A)`
   THEN MP_TAC(SPECL[`G:(A)hypermap`; `x:A`] isolated_dart)
   THEN ASM_REWRITE_TAC[]
   THEN DISCH_THEN (MP_TAC o MATCH_MP component_at_isolated_dart)
   THEN SIMP_TAC[]);;


(* SOME TRIVIAL LEMMAS ON INCIDENT RELATIONSHIPS *)

let lemma_dart_invariant = prove(`!(H:(A)hypermap) x:A. x IN dart H ==> edge_map H x IN dart H /\ node_map H x IN dart H /\ face_map H x IN dart H`,
   REPEAT GEN_TAC THEN label_hypermap4_TAC `H:(A)hypermap` THEN ASM_MESON_TAC[PERMUTES_IN_IMAGE]);;

let lemma_dart_inveriant_under_inverse_maps = prove(`!(H:(A)hypermap) x:A. x IN dart H ==> inverse(edge_map H) x IN dart H /\ inverse(node_map H) x IN dart H /\ inverse(face_map H) x IN dart H`,
     REPEAT GEN_TAC THEN label_hypermap4_TAC `H:(A)hypermap`
     THEN REMOVE_THEN "H2" (ASSUME_TAC o MATCH_MP PERMUTES_INVERSE)
     THEN REMOVE_THEN "H3" (ASSUME_TAC o MATCH_MP PERMUTES_INVERSE)
     THEN REMOVE_THEN "H4" (ASSUME_TAC o MATCH_MP PERMUTES_INVERSE)
     THEN ASM_MESON_TAC[PERMUTES_IN_IMAGE]);;

let in_set_of_orbits = prove(`!s:A->bool p:A->A. p permutes s ==> (!x:A. x IN s <=> orbit_map p x IN set_of_orbits s p)`,
   REPEAT STRIP_TAC THEN EQ_TAC
   THENL[STRIP_TAC
	   THEN REWRITE_TAC[set_of_orbits; IN_ELIM_THM]
	   THEN EXISTS_TAC `x:A`
	   THEN ASM_REWRITE_TAC[]; ALL_TAC]
   THEN REWRITE_TAC[set_of_orbits; IN_ELIM_THM]
   THEN STRIP_TAC
   THEN FIRST_ASSUM (MP_TAC o SPEC `x':A` o  MATCH_MP orbit_subset)
   THEN ASM_REWRITE_TAC[]
   THEN POP_ASSUM (SUBST1_TAC o SYM)
   THEN MESON_TAC[orbit_reflect; SUBSET]);;

let lemma_in_hypermap_orbits = prove(`!(H:(A)hypermap) x:A. (x IN dart H <=> edge H x IN  edge_set H) /\ (x IN dart H <=> node H x IN node_set H) /\ (x IN dart H <=> face H x IN face_set H)`,
   REPEAT GEN_TAC THEN label_hypermap4_TAC `H:(A)hypermap`
   THEN REWRITE_TAC[edge; node;face; edge_set;node_set;face_set]
   THEN ASM_MESON_TAC[in_set_of_orbits]);;

let lemma_in_edge_set = prove(`!(H:(A)hypermap) x:A. x IN dart H <=> edge H x IN edge_set H`, MESON_TAC[ lemma_in_hypermap_orbits]);;
let lemma_in_node_set = prove(`!(H:(A)hypermap) x:A. x IN dart H <=> node H x IN node_set H`, MESON_TAC[ lemma_in_hypermap_orbits]);;
let lemma_in_face_set = prove(`!(H:(A)hypermap) x:A. x IN dart H <=> face H x IN face_set H`, MESON_TAC[ lemma_in_hypermap_orbits]);;
   
let lemma_in_components = prove(`!(H:(A)hypermap) x:A. x IN dart H <=> comb_component H x IN set_of_components H`,
   REPEAT GEN_TAC THEN ABBREV_TAC `D = dart (H:(A)hypermap)`
   THEN ASM_REWRITE_TAC[set_of_components]
   THEN REWRITE_TAC[set_part_components]
   THEN EQ_TAC
   THENL[STRIP_TAC THEN REWRITE_TAC[IN_ELIM_THM]
	   THEN EXISTS_TAC `x:A` THEN ASM_REWRITE_TAC[]; ALL_TAC]
   THEN REWRITE_TAC[IN_ELIM_THM]
   THEN STRIP_TAC
   THEN MP_TAC (SPECL[`H:(A)hypermap`; `x':A`] lemma_component_subset)
   THEN ASM_REWRITE_TAC[]
   THEN POP_ASSUM (SUBST1_TAC o SYM)
   THEN MESON_TAC[lemma_component_reflect; SUBSET]);;  


let lemma_card_eq_reflect = prove(`!s t. s = t ==> CARD s = CARD t`,MESON_TAC[]);;

let lemma_in_walkup_dart = prove(`!(H:(A)hypermap) (x:A) (y:A). x IN dart H /\ y IN dart H /\ ~(y = x) ==> y IN dart (edge_walkup H x)`,
   REPEAT GEN_TAC THEN REWRITE_TAC[lemma_edge_walkup; IN_DELETE] THEN SIMP_TAC[]);;

let lemma_edge_map_walkup_in_dart = prove(`!H:(A)hypermap x:A. x IN dart H /\ ~(edge_map H x = x) ==> (edge_map H x IN dart (edge_walkup H x)) /\ (inverse (edge_map H) x IN dart (edge_walkup H x))`,
       REPEAT GEN_TAC
       THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F1") (LABEL_TAC "F2"))
       THEN REWRITE_TAC[lemma_edge_walkup]
       THEN USE_THEN "F1" (ASSUME_TAC o CONJUNCT1 o MATCH_MP lemma_dart_invariant)
       THEN USE_THEN "F1" (ASSUME_TAC o CONJUNCT1 o MATCH_MP lemma_dart_inveriant_under_inverse_maps)
       THEN MP_TAC (SPEC `x:A` (MATCH_MP non_fixed_point_lemma (CONJUNCT1(CONJUNCT2 (SPEC `H:(A)hypermap` hypermap_lemma)))))
       THEN ASM_REWRITE_TAC[IN_DELETE]);;

let lemma_node_map_walkup_in_dart = prove(`!H:(A)hypermap x:A. x IN dart H /\ ~(node_map H x = x) ==> (node_map H x IN dart (edge_walkup H x)) /\ (inverse (node_map H) x IN dart (edge_walkup H x))`,
       REPEAT GEN_TAC
       THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F1") (LABEL_TAC "F2"))
       THEN REWRITE_TAC[lemma_edge_walkup]
       THEN USE_THEN "F1" (ASSUME_TAC o CONJUNCT1 o CONJUNCT2 o MATCH_MP lemma_dart_invariant)
       THEN USE_THEN "F1" (ASSUME_TAC o CONJUNCT1 o CONJUNCT2 o MATCH_MP lemma_dart_inveriant_under_inverse_maps)
       THEN MP_TAC (SPEC `x:A` (MATCH_MP non_fixed_point_lemma (CONJUNCT1(CONJUNCT2(CONJUNCT2((SPEC `H:(A)hypermap` hypermap_lemma)))))))
       THEN ASM_REWRITE_TAC[IN_DELETE]);;

let lemma_face_map_walkup_in_dart = prove(`!H:(A)hypermap x:A. x IN dart H /\ ~(face_map H x = x) ==> (face_map H x IN dart (edge_walkup H x)) /\ (inverse (face_map H) x IN dart (edge_walkup H x))`,
       REPEAT GEN_TAC
       THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F1") (LABEL_TAC "F2"))
       THEN REWRITE_TAC[lemma_edge_walkup]
       THEN USE_THEN "F1" (ASSUME_TAC o CONJUNCT2 o CONJUNCT2 o MATCH_MP lemma_dart_invariant)
       THEN USE_THEN "F1" (ASSUME_TAC o CONJUNCT2 o CONJUNCT2 o MATCH_MP lemma_dart_inveriant_under_inverse_maps)
       THEN MP_TAC (SPEC `x:A` (MATCH_MP non_fixed_point_lemma (CONJUNCT1(CONJUNCT2(CONJUNCT2(CONJUNCT2(SPEC `H:(A)hypermap` hypermap_lemma)))))))
       THEN ASM_REWRITE_TAC[IN_DELETE]);;

let lemma_different_edges = prove(`!(H:(A)hypermap) (x:A) (y:A). ~(x IN edge H y) ==> ~(edge H x = edge H y)`,
   REPEAT GEN_TAC
     THEN REWRITE_TAC[edge]
     THEN ASSUME_TAC(CONJUNCT1(CONJUNCT2(SPEC `H:(A)hypermap` hypermap_lemma)))
     THEN ABBREV_TAC `D = dart (H:(A)hypermap)`
     THEN ABBREV_TAC `e = edge_map (H:(A)hypermap)`
     THEN REWRITE_TAC[CONTRAPOS_THM]
     THEN DISCH_THEN (SUBST1_TAC o SYM)
     THEN REWRITE_TAC[orbit_reflect]);;

let lemma_different_nodes = prove(`!(H:(A)hypermap) (x:A) (y:A). ~(x IN node H y) ==> ~(node H x = node H y)`,
   REPEAT GEN_TAC
     THEN REWRITE_TAC[node]
     THEN ASSUME_TAC(CONJUNCT1(CONJUNCT2(CONJUNCT2(SPEC `H:(A)hypermap` hypermap_lemma))))
     THEN ABBREV_TAC `D = dart (H:(A)hypermap)`
     THEN ABBREV_TAC `e = node_map (H:(A)hypermap)`
     THEN REWRITE_TAC[CONTRAPOS_THM]
     THEN DISCH_THEN (SUBST1_TAC o SYM)
     THEN REWRITE_TAC[orbit_reflect]);;

let lemma_different_faces = prove(`!(H:(A)hypermap) (x:A) (y:A). ~(x IN face H y) ==> ~(face H x = face H y)`,
   REPEAT GEN_TAC
     THEN REWRITE_TAC[face]
     THEN ASSUME_TAC(CONJUNCT1(CONJUNCT2(CONJUNCT2(CONJUNCT2(SPEC `H:(A)hypermap` hypermap_lemma)))))
     THEN ABBREV_TAC `D = dart (H:(A)hypermap)`
     THEN ABBREV_TAC `e = face_map (H:(A)hypermap)`
     THEN REWRITE_TAC[CONTRAPOS_THM]
     THEN DISCH_THEN (SUBST1_TAC o SYM)
     THEN REWRITE_TAC[orbit_reflect]);;


(* WALKUP AT AN ISOLATED DART *)


let lemma_planar_index_on_walkup_at_isolated_dart = prove(`!(H:(A)hypermap) x:A. x IN dart H /\ isolated_dart H x ==> planar_ind H = planar_ind (edge_walkup H x)`,
  REPEAT GEN_TAC
  THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F1") (LABEL_TAC "F2"))
  THEN USE_THEN "F2" MP_TAC THEN REWRITE_TAC[isolated_dart]
  THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F3") (CONJUNCTS_THEN2 (LABEL_TAC "F4") (LABEL_TAC "F5")))
  THEN LABEL_TAC "F6" (CONJUNCT1(SPECL[`H:(A)hypermap`; `x:A`] lemma_edge_walkup))
  THEN label_hypermap_TAC `H:(A)hypermap`
  THEN label_hypermapG_TAC `edge_walkup (H:(A)hypermap) (x:A)`
  THEN ABBREV_TAC `D = dart (H:(A)hypermap)` 
  THEN ABBREV_TAC `e = edge_map (H:(A)hypermap)`  
  THEN ABBREV_TAC `n = node_map (H:(A)hypermap)` 
  THEN ABBREV_TAC `f = face_map (H:(A)hypermap)`
  THEN ABBREV_TAC `D' = dart (edge_walkup (H:(A)hypermap) (x:A))` 
  THEN ABBREV_TAC `e' = edge_map (edge_walkup (H:(A)hypermap) (x:A))`  
  THEN ABBREV_TAC `n' = node_map (edge_walkup (H:(A)hypermap) (x:A))` 
  THEN ABBREV_TAC `f' = face_map (edge_walkup (H:(A)hypermap) (x:A))`
  THEN SUBGOAL_THEN `number_of_edges (H:(A)hypermap) = number_of_edges (edge_walkup H (x:A)) + 1` (LABEL_TAC "X1")
  THENL[REWRITE_TAC[number_of_edges] THEN MP_TAC (SPECL[`H:(A)hypermap`; `x:A`] lemma_walkup_edges)
   THEN REWRITE_TAC[edge] THEN ASM_REWRITE_TAC[]
   THEN USE_THEN "F3" MP_TAC
   THEN GEN_REWRITE_TAC(LAND_CONV) [SPECL[`e:A->A`; `x:A`] orbit_one_point]
   THEN DISCH_THEN (fun th -> REWRITE_TAC[th])
   THEN USE_THEN "H2" (MP_TAC o SPEC `x:A` o  MATCH_MP fixed_point_lemma)
   THEN USE_THEN "F3" (fun th -> REWRITE_TAC[th])
   THEN DISCH_THEN (fun th -> REWRITE_TAC[th])
   THEN MP_TAC (CONJUNCT1 (SPECL[`H:(A)hypermap`; `x:A`; `x:A`] edge_map_walkup))
   THEN ASM_REWRITE_TAC[]
   THEN GEN_REWRITE_TAC(LAND_CONV) [SPECL[`e':A->A`; `x:A`] orbit_one_point]
   THEN DISCH_THEN (fun th -> REWRITE_TAC[th])
   THEN REWRITE_TAC[SET_RULE `{x, x} = {x}`]
   THEN SUBGOAL_THEN `{x:A} IN edge_set (H:(A)hypermap)` ASSUME_TAC
   THENL[REWRITE_TAC[edge_set] THEN ASM_REWRITE_TAC[]
      THEN REWRITE_TAC[set_of_orbits; IN_ELIM_THM]
      THEN EXISTS_TAC `x:A`
      THEN USE_THEN "F3" MP_TAC
      THEN GEN_REWRITE_TAC (LAND_CONV) [orbit_one_point]
      THEN DISCH_THEN (fun th -> REWRITE_TAC[SYM th])
      THEN USE_THEN "F1" (fun th -> REWRITE_TAC[th]); ALL_TAC]
   THEN SUBGOAL_THEN `~({x:A} IN edge_set (edge_walkup (H:(A)hypermap) (x:A)))` ASSUME_TAC
   THENL[REWRITE_TAC[edge_set] THEN ASM_REWRITE_TAC[]
      THEN REWRITE_TAC[set_of_orbits; IN_ELIM_THM]
      THEN ONCE_REWRITE_TAC[GSYM FORALL_NOT_THM]
      THEN REWRITE_TAC[IN_DELETE]
      THEN REPEAT STRIP_TAC
      THEN FIRST_X_ASSUM(MP_TAC o check(is_neg o concl))
      THEN REWRITE_TAC[]
      THEN POP_ASSUM (fun th -> (ASSUME_TAC (SYM th)))
      THEN POP_ASSUM (MP_TAC o MATCH_MP orbit_single_lemma)
      THEN SIMP_TAC[]; ALL_TAC]
   THEN REWRITE_TAC[SET_RULE `((edge_set (H:(A)hypermap)):((A->bool)->bool)) DIFF {{x:A}} = (edge_set (H:(A)hypermap)) DELETE {x:A}`]
   THEN POP_ASSUM MP_TAC THEN REWRITE_TAC[DELETE_NON_ELEMENT]
   THEN DISCH_THEN (fun th-> REWRITE_TAC[th])
   THEN DISCH_THEN (fun th -> REWRITE_TAC[SYM th])
   THEN MP_TAC(ISPECL[`edge_set (H:(A)hypermap)`; `{x:A}`] CARD_MINUS_ONE)
   THEN POP_ASSUM (fun th -> REWRITE_TAC[th])
   THEN REWRITE_TAC[FINITE_HYPERMAP_ORBITS]; ALL_TAC]
  THEN SUBGOAL_THEN `number_of_nodes (H:(A)hypermap) = number_of_nodes (edge_walkup H (x:A)) + 1` (LABEL_TAC "X2")
   THENL[REWRITE_TAC[number_of_nodes] THEN MP_TAC (SPECL[`H:(A)hypermap`; `x:A`] lemma_walkup_nodes)
      THEN REWRITE_TAC[node] THEN ASM_REWRITE_TAC[]
      THEN USE_THEN "F4" MP_TAC THEN GEN_REWRITE_TAC(LAND_CONV) [SPECL[`n:A->A`; `x:A`] orbit_one_point]
      THEN DISCH_THEN (fun th -> REWRITE_TAC[th])
      THEN USE_THEN "H3" (MP_TAC o SPEC `x:A` o  MATCH_MP fixed_point_lemma)
      THEN USE_THEN "F4" (fun th -> REWRITE_TAC[th])
      THEN DISCH_THEN (fun th -> REWRITE_TAC[th])
      THEN MP_TAC (CONJUNCT1 (SPECL[`H:(A)hypermap`; `x:A`; `x:A`] node_map_walkup))
      THEN ASM_REWRITE_TAC[]
      THEN GEN_REWRITE_TAC(LAND_CONV) [SPECL[`n':A->A`; `x:A`] orbit_one_point]
      THEN DISCH_THEN (fun th -> REWRITE_TAC[th])
      THEN SUBGOAL_THEN `{x:A} IN node_set (H:(A)hypermap)` ASSUME_TAC
      THENL[REWRITE_TAC[node_set] THEN ASM_REWRITE_TAC[]
	THEN REWRITE_TAC[set_of_orbits; IN_ELIM_THM]
	THEN EXISTS_TAC `x:A` THEN USE_THEN "F4" MP_TAC
	THEN GEN_REWRITE_TAC (LAND_CONV) [orbit_one_point]
	THEN DISCH_THEN (fun th -> REWRITE_TAC[SYM th])
	THEN USE_THEN "F1" (fun th -> REWRITE_TAC[th]); ALL_TAC]
      THEN SUBGOAL_THEN `~({x:A} IN node_set (edge_walkup (H:(A)hypermap) (x:A)))` ASSUME_TAC
      THENL[REWRITE_TAC[node_set] THEN ASM_REWRITE_TAC[]
	THEN REWRITE_TAC[set_of_orbits; IN_ELIM_THM]
	THEN ONCE_REWRITE_TAC[GSYM FORALL_NOT_THM]
	THEN REWRITE_TAC[IN_DELETE] THEN REPEAT STRIP_TAC
	THEN FIRST_X_ASSUM(MP_TAC o check(is_neg o concl))
	THEN REWRITE_TAC[]
	THEN POP_ASSUM (fun th -> (ASSUME_TAC (SYM th)))
	THEN POP_ASSUM (MP_TAC o MATCH_MP orbit_single_lemma)
	THEN SIMP_TAC[]; ALL_TAC]
      THEN POP_ASSUM MP_TAC
      THEN REWRITE_TAC[DELETE_NON_ELEMENT]
      THEN DISCH_THEN (fun th-> REWRITE_TAC[th])
      THEN DISCH_THEN (fun th -> REWRITE_TAC[SYM th])
      THEN MP_TAC(ISPECL[`node_set (H:(A)hypermap)`; `{x:A}`] CARD_MINUS_ONE)
      THEN POP_ASSUM (fun th -> REWRITE_TAC[th])
      THEN REWRITE_TAC[FINITE_HYPERMAP_ORBITS]; ALL_TAC]
   THEN SUBGOAL_THEN `number_of_faces (H:(A)hypermap) = number_of_faces (edge_walkup H (x:A)) + 1` (LABEL_TAC "X3")
   THENL[REWRITE_TAC[number_of_faces] THEN MP_TAC (SPECL[`H:(A)hypermap`; `x:A`] lemma_walkup_faces)
      THEN REWRITE_TAC[face] THEN ASM_REWRITE_TAC[]
      THEN USE_THEN "F5" MP_TAC THEN GEN_REWRITE_TAC(LAND_CONV) [SPECL[`n:A->A`; `x:A`] orbit_one_point]
      THEN DISCH_THEN (fun th -> REWRITE_TAC[th])
      THEN USE_THEN "H4" (MP_TAC o SPEC `x:A` o  MATCH_MP fixed_point_lemma)
      THEN USE_THEN "F5" (fun th -> REWRITE_TAC[th])
      THEN DISCH_THEN (fun th -> REWRITE_TAC[th])
      THEN MP_TAC (CONJUNCT1 (SPECL[`H:(A)hypermap`; `x:A`; `x:A`] face_map_walkup))
      THEN ASM_REWRITE_TAC[]
      THEN GEN_REWRITE_TAC(LAND_CONV) [SPECL[`f':A->A`; `x:A`] orbit_one_point]
      THEN DISCH_THEN (fun th -> REWRITE_TAC[th])
      THEN SUBGOAL_THEN `{x:A} IN face_set (H:(A)hypermap)` ASSUME_TAC
      THENL[REWRITE_TAC[face_set] THEN ASM_REWRITE_TAC[]
	THEN REWRITE_TAC[set_of_orbits; IN_ELIM_THM]
	THEN EXISTS_TAC `x:A` THEN USE_THEN "F5" MP_TAC
	THEN GEN_REWRITE_TAC (LAND_CONV) [orbit_one_point]
	THEN DISCH_THEN (fun th -> REWRITE_TAC[SYM th])
	THEN USE_THEN "F1" (fun th -> REWRITE_TAC[th]); ALL_TAC]
      THEN SUBGOAL_THEN `~({x:A} IN face_set (edge_walkup (H:(A)hypermap) (x:A)))` ASSUME_TAC
      THENL[REWRITE_TAC[face_set] THEN ASM_REWRITE_TAC[]
	THEN REWRITE_TAC[set_of_orbits; IN_ELIM_THM]
	THEN ONCE_REWRITE_TAC[GSYM FORALL_NOT_THM]
	THEN REWRITE_TAC[IN_DELETE] THEN REPEAT STRIP_TAC
	THEN FIRST_X_ASSUM(MP_TAC o check(is_neg o concl))
	THEN REWRITE_TAC[]
	THEN POP_ASSUM (fun th -> (ASSUME_TAC (SYM th)))
	THEN POP_ASSUM (MP_TAC o MATCH_MP orbit_single_lemma)
	THEN SIMP_TAC[]; ALL_TAC]
      THEN POP_ASSUM MP_TAC
      THEN REWRITE_TAC[DELETE_NON_ELEMENT]
      THEN DISCH_THEN (fun th-> REWRITE_TAC[th])
      THEN DISCH_THEN (fun th -> REWRITE_TAC[SYM th])
      THEN MP_TAC(ISPECL[`face_set (H:(A)hypermap)`; `{x:A}`] CARD_MINUS_ONE)
      THEN POP_ASSUM (fun th -> REWRITE_TAC[th])
      THEN REWRITE_TAC[FINITE_HYPERMAP_ORBITS]; ALL_TAC]
   THEN SUBGOAL_THEN `number_of_components (H:(A)hypermap) = number_of_components (edge_walkup H (x:A)) + 1` (LABEL_TAC "X4")
   THENL[REWRITE_TAC[number_of_components]
     THEN MP_TAC (SPECL[`H:(A)hypermap`; `x:A`] lemma_walkup_components)
     THEN ASM_REWRITE_TAC[]
     THEN USE_THEN "H2" (MP_TAC o SPEC `x:A` o  MATCH_MP fixed_point_lemma)
     THEN USE_THEN "F3" (fun th -> REWRITE_TAC[th])
     THEN DISCH_THEN (fun th -> REWRITE_TAC[th])
     THEN REWRITE_TAC[SET_RULE `{x, x} = {x}`]
     THEN REWRITE_TAC[SET_RULE `set_of_components (edge_walkup (H:(A)hypermap) (x:A)) DIFF {comb_component (edge_walkup H x) x} = set_of_components (edge_walkup (H:(A)hypermap) (x:A)) DELETE (comb_component (edge_walkup H x) x )`]
     THEN SUBGOAL_THEN `comb_component (H:(A)hypermap) (x:A) IN set_of_components H` ASSUME_TAC
     THENL[REWRITE_TAC[set_of_components]
	     THEN ASM_REWRITE_TAC[]
	     THEN REWRITE_TAC[set_part_components; IN_ELIM_THM]
	     THEN EXISTS_TAC `x:A`
	     THEN USE_THEN "F1" (fun th -> REWRITE_TAC[th]); ALL_TAC]
     THEN SUBGOAL_THEN `~(comb_component (edge_walkup (H:(A)hypermap) (x:A)) x IN set_of_components (edge_walkup H x))` ASSUME_TAC
     THENL[REWRITE_TAC[set_of_components]
	     THEN ASM_REWRITE_TAC[]
	     THEN REWRITE_TAC[set_part_components; IN_ELIM_THM; IN_DELETE]
	     THEN STRIP_TAC
	     THEN MP_TAC (SPECL[`H:(A)hypermap`; `x:A`] WALKUP_EXCEPTION_COMPONENT)
	     THEN ASM_REWRITE_TAC[]
	     THEN FIRST_X_ASSUM(MP_TAC o check(is_neg o concl))
	     THEN REWRITE_TAC[CONTRAPOS_THM]
	     THEN STRIP_TAC
	     THEN MP_TAC (SPECL[`edge_walkup (H:(A)hypermap) (x:A)`; `x':A`] lemma_component_reflect)
	     THEN POP_ASSUM SUBST1_TAC
	     THEN REWRITE_TAC[IN_SING]; ALL_TAC]
     THEN POP_ASSUM MP_TAC
     THEN REWRITE_TAC[DELETE_NON_ELEMENT]
     THEN DISCH_THEN (fun th-> REWRITE_TAC[th])
     THEN DISCH_THEN (fun th -> REWRITE_TAC[SYM th])
     THEN MP_TAC(ISPECL[`set_of_components (H:(A)hypermap)`; `comb_component (H:(A)hypermap) (x:A)`] CARD_MINUS_ONE)
     THEN POP_ASSUM (fun th -> REWRITE_TAC[th])
     THEN REWRITE_TAC[FINITE_HYPERMAP_COMPONENTS]; ALL_TAC]
   THEN SUBGOAL_THEN `CARD (dart (H:(A)hypermap)) = CARD(dart (edge_walkup H (x:A))) + 1` (LABEL_TAC "X5")
   THENL[MP_TAC(CONJUNCT1(SPECL[`H:(A)hypermap`; `x:A`] lemma_edge_walkup))
     THEN DISCH_THEN SUBST1_TAC
     THEN MATCH_MP_TAC CARD_MINUS_ONE
     THEN ASM_REWRITE_TAC[]; ALL_TAC]
   THEN REWRITE_TAC[planar_ind]
   THEN ASM_REWRITE_TAC[GSYM REAL_ADD']
   THEN REAL_ARITH_TAC);;


(* Walkup at an edge-degenerate dart *)

let lemma_planar_index_on_walkup_at_edge_degenerate_dart = prove(`!(H:(A)hypermap) x:A. x IN dart H /\ is_edge_degenerate H x ==> planar_ind H = planar_ind (edge_walkup H x)`,
  REPEAT GEN_TAC
  THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F1") (LABEL_TAC "F2"))
  THEN USE_THEN "F2" MP_TAC THEN REWRITE_TAC[is_edge_degenerate]
  THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F3") (CONJUNCTS_THEN2 (LABEL_TAC "F4") (LABEL_TAC "F5")))
  THEN LABEL_TAC "F6" (CONJUNCT1(SPECL[`H:(A)hypermap`; `x:A`] lemma_edge_walkup))
  THEN label_hypermap_TAC `H:(A)hypermap`
  THEN label_hypermapG_TAC `edge_walkup (H:(A)hypermap) (x:A)`
  THEN ABBREV_TAC `D = dart (H:(A)hypermap)` 
  THEN ABBREV_TAC `e = edge_map (H:(A)hypermap)`  
  THEN ABBREV_TAC `n = node_map (H:(A)hypermap)` 
  THEN ABBREV_TAC `f = face_map (H:(A)hypermap)`
  THEN ABBREV_TAC `D' = dart (edge_walkup (H:(A)hypermap) (x:A))` 
  THEN ABBREV_TAC `e' = edge_map (edge_walkup (H:(A)hypermap) (x:A))`  
  THEN ABBREV_TAC `n' = node_map (edge_walkup (H:(A)hypermap) (x:A))` 
  THEN ABBREV_TAC `f' = face_map (edge_walkup (H:(A)hypermap) (x:A))`
  THEN MP_TAC(SPECL[`H:(A)hypermap`; `x:A`] lemma_in_hypermap_orbits)
  THEN ASM_REWRITE_TAC[]
  THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F7") (CONJUNCTS_THEN2 (LABEL_TAC "F8") (LABEL_TAC "F9")))
  THEN SUBGOAL_THEN `number_of_edges (H:(A)hypermap) = number_of_edges (edge_walkup H (x:A)) + 1` (LABEL_TAC "X1")
  THENL[REWRITE_TAC[number_of_edges] THEN MP_TAC (SPECL[`H:(A)hypermap`; `x:A`] lemma_walkup_edges)
	  THEN ASM_REWRITE_TAC[]
	  THEN LABEL_TAC "F10" (CONJUNCT1(SPEC `H:(A)hypermap`  FINITE_HYPERMAP_ORBITS))
	  THEN MP_TAC (SPECL[`H:(A)hypermap`; `x:A`] lemma_dart_invariant)
	  THEN ASM_REWRITE_TAC[]
	  THEN DISCH_THEN (fun th -> (LABEL_TAC "F11" (CONJUNCT1 th)))
	  THEN MP_TAC(SPECL[`H:(A)hypermap`; `(n:A->A) (x:A)`] lemma_in_hypermap_orbits)
	  THEN ASM_REWRITE_TAC[]
	  THEN DISCH_THEN ((LABEL_TAC "F11") o CONJUNCT1)
	  THEN DISCH_THEN (ASSUME_TAC o MATCH_MP lemma_card_eq_reflect)
	  THEN MP_TAC (ISPECL[`edge_set (H:(A)hypermap)`; `edge (H:(A)hypermap) (x:A)`; `edge (H:(A)hypermap) ((n:A->A) (x:A))`] CARD_MINUS_DIFF_TWO_SET)
	  THEN POP_ASSUM SUBST1_TAC
	  THEN ASM_REWRITE_TAC[]
	  THEN DISCH_THEN SUBST1_TAC
	  THEN USE_THEN "H2" (MP_TAC o SPEC `x:A` o  MATCH_MP fixed_point_lemma)
	  THEN USE_THEN "F3" (fun th-> REWRITE_TAC[th])
	  THEN DISCH_THEN SUBST1_TAC
	  THEN ASSUME_TAC (CONJUNCT1(SPECL[`H:(A)hypermap`; `x:A`;`x:A`] edge_map_walkup))
	  THEN MP_TAC(SPECL[`edge_map (edge_walkup (H:(A)hypermap) (x:A))`; `x:A`] orbit_one_point)
	  THEN POP_ASSUM(fun th -> REWRITE_TAC[th])
	  THEN REWRITE_TAC[GSYM edge]
	  THEN DISCH_THEN SUBST1_TAC
	  THEN MP_TAC(SPECL[`e:A->A`; `x:A`] orbit_one_point)
	  THEN USE_THEN "F3"(fun th -> REWRITE_TAC[th])
	  THEN EXPAND_TAC "e"
	  THEN REWRITE_TAC[GSYM edge]
	  THEN DISCH_THEN SUBST1_TAC
	  THEN SUBGOAL_THEN `~({x:A} IN edge_set (edge_walkup (H:(A)hypermap) (x:A)))` ASSUME_TAC
          THENL[REWRITE_TAC[edge_set] THEN ASM_REWRITE_TAC[]
		  THEN REWRITE_TAC[set_of_orbits; IN_ELIM_THM]
                  THEN ONCE_REWRITE_TAC[GSYM FORALL_NOT_THM]
                  THEN REWRITE_TAC[IN_DELETE]
                  THEN REPEAT STRIP_TAC
                  THEN FIRST_X_ASSUM(MP_TAC o check(is_neg o concl))
                  THEN REWRITE_TAC[]
                  THEN POP_ASSUM (fun th -> (ASSUME_TAC (SYM th)))
                  THEN POP_ASSUM (MP_TAC o MATCH_MP orbit_single_lemma)
                  THEN SIMP_TAC[]; ALL_TAC]
	  THEN REWRITE_TAC[SET_RULE `s DIFF {a,b} = (s DELETE b) DELETE a`]
	  THEN POP_ASSUM MP_TAC THEN REWRITE_TAC[DELETE_NON_ELEMENT]
	  THEN DISCH_THEN (fun th-> REWRITE_TAC[th])
	  THEN SUBGOAL_THEN `(n:A->A) (x:A) IN dart (edge_walkup (H:(A)hypermap) (x:A))` MP_TAC
	  THENL[ASM_REWRITE_TAC[IN_DELETE]; ALL_TAC]
	  THEN REWRITE_TAC[CONJUNCT1(SPECL[`edge_walkup (H:(A)hypermap) (x:A)`; `(n:A->A) (x:A)`] lemma_in_hypermap_orbits)]
	  THEN DISCH_TAC
          THEN MP_TAC(ISPECL[`edge_set (edge_walkup (H:(A)hypermap) (x:A))`; `edge (edge_walkup (H:(A)hypermap) (x:A)) ((n:A->A) (x:A))`] CARD_MINUS_ONE)
	  THEN ASM_REWRITE_TAC[FINITE_HYPERMAP_ORBITS]
	  THEN DISCH_THEN SUBST1_TAC
	  THEN REWRITE_TAC[ARITH_RULE `((l:num) + 1) + 1 = l + 2`]
	  THEN REWRITE_TAC[ARITH_RULE `(k:num)+ a = k + b <=> a = b`]
	  THEN ASM_CASES_TAC `~({x:A} = edge (H:(A)hypermap) ((n:A->A) (x:A)))`
	  THENL[POP_ASSUM (MP_TAC o MATCH_MP CARD_TWO_ELEMENTS) THEN SIMP_TAC[]; ALL_TAC]
	  THEN POP_ASSUM MP_TAC
	  THEN REWRITE_TAC[TAUT `~ ~p = p`]
	  THEN REWRITE_TAC[edge]
	  THEN ASM_REWRITE_TAC[]
	  THEN DISCH_THEN (ASSUME_TAC o SYM)
	  THEN MP_TAC (SPECL[`e:A->A`; `(n:A->A) (x:A)`] orbit_reflect)
	  THEN POP_ASSUM SUBST1_TAC
	  THEN ASM_REWRITE_TAC[IN_SING]; ALL_TAC]
    THEN SUBGOAL_THEN `number_of_nodes (H:(A)hypermap) = number_of_nodes (edge_walkup H (x:A))` (LABEL_TAC "X2")
    THENL[REWRITE_TAC[number_of_nodes] THEN MP_TAC (SPECL[`H:(A)hypermap`; `x:A`] lemma_walkup_nodes)
	    THEN ASM_REWRITE_TAC[]
	    THEN MP_TAC (SPECL[`H:(A)hypermap`; `x:A`] lemma_dart_invariant)
	    THEN ASM_REWRITE_TAC[]
	    THEN DISCH_THEN (fun th -> (LABEL_TAC "G11" (CONJUNCT1 th)))
	    THEN MP_TAC (ISPECL[`node_set (H:(A)hypermap)`; `node (H:(A)hypermap) (x:A)`] CARD_MINUS_ONE)
	    THEN ASM_REWRITE_TAC[FINITE_HYPERMAP_ORBITS]
	    THEN DISCH_THEN SUBST1_TAC
	    THEN DISCH_THEN SUBST1_TAC
	    THEN CONV_TAC SYM_CONV
	    THEN SUBGOAL_THEN `(inverse (n:A->A)) (x:A) IN dart (edge_walkup (H:(A)hypermap) (x:A))` ASSUME_TAC
	    THENL[ASM_REWRITE_TAC[IN_DELETE]
	         THEN USE_THEN "H3" (MP_TAC o SPEC `x:A` o MATCH_MP non_fixed_point_lemma)
	         THEN USE_THEN "F4" (fun th -> REWRITE_TAC[th])
	         THEN DISCH_THEN (fun th -> REWRITE_TAC[th])
	         THEN USE_THEN "F1" MP_TAC
		 THEN EXPAND_TAC "D"
		 THEN DISCH_THEN (MP_TAC o CONJUNCT1 o CONJUNCT2 o MATCH_MP lemma_dart_inveriant_under_inverse_maps)
		 THEN ASM_REWRITE_TAC[]; ALL_TAC]
	    THEN MP_TAC (CONJUNCT1(CONJUNCT2(SPECL[`edge_walkup (H:(A)hypermap) (x:A)`; `inverse (n:A->A) (x:A)`]lemma_in_hypermap_orbits)))
	    THEN POP_ASSUM (fun th -> REWRITE_TAC[th])
	    THEN DISCH_TAC
	    THEN MP_TAC (ISPECL[`node_set (edge_walkup (H:(A)hypermap) (x:A))`; `node (edge_walkup (H:(A)hypermap) (x:A)) (inverse (n:A->A) (x:A))`] CARD_MINUS_ONE)
	    THEN ASM_REWRITE_TAC[FINITE_HYPERMAP_ORBITS]; ALL_TAC]
    THEN SUBGOAL_THEN `number_of_faces (H:(A)hypermap) = number_of_faces (edge_walkup H (x:A))` (LABEL_TAC "X4")
    THENL[REWRITE_TAC[number_of_faces] THEN MP_TAC (SPECL[`H:(A)hypermap`; `x:A`] lemma_walkup_faces)
	 THEN ASM_REWRITE_TAC[]
	 THEN MP_TAC (SPECL[`H:(A)hypermap`; `x:A`] lemma_dart_invariant)
	 THEN ASM_REWRITE_TAC[]
	 THEN DISCH_THEN (fun th -> (LABEL_TAC "J11" (CONJUNCT2 th)))
	 THEN MP_TAC (ISPECL[`face_set (H:(A)hypermap)`; `face (H:(A)hypermap) (x:A)`] CARD_MINUS_ONE)
	 THEN ASM_REWRITE_TAC[FINITE_HYPERMAP_ORBITS]
	 THEN DISCH_THEN SUBST1_TAC
	 THEN DISCH_THEN SUBST1_TAC
	 THEN CONV_TAC SYM_CONV
	 THEN SUBGOAL_THEN `(inverse (f:A->A)) (x:A) IN dart (edge_walkup (H:(A)hypermap) (x:A))` ASSUME_TAC
	 THENL[ASM_REWRITE_TAC[IN_DELETE]
		 THEN USE_THEN "H4" (MP_TAC o SPEC `x:A` o MATCH_MP non_fixed_point_lemma)
		 THEN USE_THEN "F5" (fun th -> REWRITE_TAC[th])
		 THEN DISCH_THEN (fun th -> REWRITE_TAC[th])
		 THEN USE_THEN "F1" MP_TAC
		 THEN EXPAND_TAC "D"
		 THEN DISCH_THEN (MP_TAC o CONJUNCT2 o CONJUNCT2 o MATCH_MP lemma_dart_inveriant_under_inverse_maps)
		 THEN ASM_REWRITE_TAC[]; ALL_TAC]
	 THEN MP_TAC (CONJUNCT2(CONJUNCT2(SPECL[`edge_walkup (H:(A)hypermap) (x:A)`; `inverse (f:A->A) (x:A)`]lemma_in_hypermap_orbits)))
	 THEN POP_ASSUM (fun th -> REWRITE_TAC[th])
	 THEN DISCH_TAC
	 THEN MP_TAC (ISPECL[`face_set (edge_walkup (H:(A)hypermap) (x:A))`; `face (edge_walkup (H:(A)hypermap) (x:A)) (inverse (f:A->A) (x:A))`] CARD_MINUS_ONE)
	 THEN ASM_REWRITE_TAC[FINITE_HYPERMAP_ORBITS]; ALL_TAC]
    THEN SUBGOAL_THEN `number_of_components (H:(A)hypermap) = number_of_components (edge_walkup H (x:A))` (LABEL_TAC "X5")
    THENL[REWRITE_TAC[number_of_components] THEN MP_TAC (SPECL[`H:(A)hypermap`; `x:A`] lemma_walkup_components)
        THEN ASM_REWRITE_TAC[] THEN USE_THEN "H2" (MP_TAC o SPEC `x:A` o  MATCH_MP fixed_point_lemma)
	THEN USE_THEN "F3" (fun th-> REWRITE_TAC[th])
	THEN DISCH_THEN SUBST1_TAC
	THEN ASM_CASES_TAC `(comb_component (edge_walkup (H:(A)hypermap) (x:A)) x) IN set_of_components (edge_walkup H x)`
	THENL[POP_ASSUM MP_TAC THEN REWRITE_TAC[GSYM lemma_in_components]
		THEN ASM_REWRITE_TAC[IN_DELETE]; ALL_TAC]
	THEN REWRITE_TAC[SET_RULE `s DIFF {a,b} = (s DELETE b) DELETE a`]
	THEN POP_ASSUM MP_TAC THEN REWRITE_TAC[DELETE_NON_ELEMENT]
	THEN DISCH_THEN SUBST1_TAC
	THEN USE_THEN "F1" MP_TAC
	THEN EXPAND_TAC "D"
	THEN REWRITE_TAC[lemma_in_components]
	THEN DISCH_TAC
	THEN MP_TAC (ISPECL[`set_of_components (H:(A)hypermap)`; `comb_component (H:(A)hypermap) (x:A)`] CARD_MINUS_ONE)
	THEN POP_ASSUM (fun th -> REWRITE_TAC[th; FINITE_HYPERMAP_COMPONENTS])
	THEN DISCH_THEN SUBST1_TAC
	THEN ASM_CASES_TAC `(n:A->A) (x:A) IN dart (edge_walkup (H:(A)hypermap) (x:A))`
	THENL[POP_ASSUM MP_TAC
		THEN REWRITE_TAC[lemma_in_components]
		THEN DISCH_TAC 
		THEN MP_TAC (ISPECL[`set_of_components (edge_walkup (H:(A)hypermap) (x:A))`; `comb_component (edge_walkup (H:(A)hypermap) (x:A)) ((n:A->A) (x:A))`] CARD_MINUS_ONE)
		THEN POP_ASSUM (fun th -> REWRITE_TAC[th; FINITE_HYPERMAP_COMPONENTS])
		THEN DISCH_THEN SUBST1_TAC
		THEN SIMP_TAC[]; ALL_TAC]
	THEN POP_ASSUM MP_TAC
	THEN ASM_REWRITE_TAC[IN_DELETE]
	THEN DISCH_TAC
	THEN MP_TAC(SPECL[`H:(A)hypermap`; `x:A`] lemma_dart_invariant)
	THEN ASM_REWRITE_TAC[]; ALL_TAC]
    THEN SUBGOAL_THEN `CARD (dart (H:(A)hypermap)) = CARD(dart (edge_walkup H (x:A))) + 1` (LABEL_TAC "X6")
    THENL[MP_TAC(CONJUNCT1(SPECL[`H:(A)hypermap`; `x:A`] lemma_edge_walkup))
        THEN DISCH_THEN SUBST1_TAC
        THEN MATCH_MP_TAC CARD_MINUS_ONE
        THEN ASM_REWRITE_TAC[]; ALL_TAC]
    THEN REWRITE_TAC[planar_ind]
    THEN ASM_REWRITE_TAC[GSYM REAL_ADD']
    THEN REAL_ARITH_TAC);;

let lemma_planar_index_on_walkup_at_degenerate_dart = prove(`!(H:(A)hypermap) (x:A). x IN dart H /\ dart_degenerate H x ==> planar_ind H = planar_ind (edge_walkup H x)`,
     REPEAT GEN_TAC
     THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F1") (LABEL_TAC "F2"))
     THEN USE_THEN "F2" MP_TAC
     THEN REWRITE_TAC[degenerate_lemma]
     THEN STRIP_TAC
     THENL[MP_TAC (SPECL[`H:(A)hypermap`; `x:A`] lemma_planar_index_on_walkup_at_isolated_dart)
	  THEN ASM_REWRITE_TAC[]; MP_TAC (SPECL[`H:(A)hypermap`; `x:A`] lemma_planar_index_on_walkup_at_edge_degenerate_dart)
	  THEN ASM_REWRITE_TAC[]; USE_THEN "F1" (fun th1 -> (USE_THEN "F2" (fun th2 -> (MP_TAC (MATCH_MP (lemma_degenerate_walkup_first_eq) (CONJ th1 th2)))))) THEN DISCH_THEN (SUBST1_TAC o SYM)
	  THEN REWRITE_TAC[node_walkup] THEN ONCE_REWRITE_TAC[lemma_planar_invariant_shift]
	  THEN REWRITE_TAC[lemma_shift_cycle]
	  THEN SUBGOAL_THEN `is_edge_degenerate (shift (H:(A)hypermap)) (x:A)` ASSUME_TAC
	  THENL[POP_ASSUM MP_TAC THEN REWRITE_TAC[is_edge_degenerate]
		  THEN REWRITE_TAC[GSYM shift_lemma; is_node_degenerate]
		  THEN SIMP_TAC[]; ALL_TAC]
	  THEN MP_TAC (SPECL[`shift(H:(A)hypermap)`; `x:A`] lemma_planar_index_on_walkup_at_edge_degenerate_dart)
	  THEN GEN_REWRITE_TAC (LAND_CONV o TOP_DEPTH_CONV ) [GSYM shift_lemma]
	  THEN ASM_REWRITE_TAC[]; USE_THEN "F1" (fun th1 -> (USE_THEN "F2" (fun th2 -> (MP_TAC (MATCH_MP (lemma_degenerate_walkup_second_eq) (CONJ th1 th2)))))) THEN DISCH_THEN (SUBST1_TAC o SYM)
	  THEN REWRITE_TAC[face_walkup]
	  THEN REPLICATE_TAC 2 (ONCE_REWRITE_TAC[lemma_planar_invariant_shift])
	  THEN REWRITE_TAC[lemma_shift_cycle]
	  THEN SUBGOAL_THEN `is_edge_degenerate (shift(shift (H:(A)hypermap))) (x:A)` ASSUME_TAC
	  THENL[POP_ASSUM MP_TAC
	      THEN REWRITE_TAC[is_edge_degenerate]
	      THEN REWRITE_TAC[GSYM shift_lemma; is_face_degenerate]
	      THEN SIMP_TAC[]; ALL_TAC]
	  THEN MP_TAC (SPECL[`shift(shift(H:(A)hypermap))`; `x:A`] lemma_planar_index_on_walkup_at_edge_degenerate_dart)
	  THEN GEN_REWRITE_TAC (LAND_CONV o TOP_DEPTH_CONV ) [GSYM double_shift_lemma]
	  THEN ASM_REWRITE_TAC[]]);;

(* COMPUTE the numbers on edge-walkup at a non-degerate dart *)

(* Trivial for darts *)

let lemma_card_walkup_dart = prove(`!(H:(A)hypermap) (x:A). x IN dart H ==> CARD(dart H) = CARD(dart(edge_walkup H x)) + 1`,
     REPEAT STRIP_TAC THEN MP_TAC(CONJUNCT1(SPECL[`H:(A)hypermap`; `x:A`] lemma_edge_walkup))
     THEN DISCH_THEN SUBST1_TAC THEN MATCH_MP_TAC CARD_MINUS_ONE
     THEN ASM_REWRITE_TAC[hypermap_lemma]);;


(* Compute number of edges acording to then splitting cas *)

let lemma_splitting_case_count_edges = prove(`!(H:(A)hypermap) (x:A). x IN dart H /\ is_edge_split H x ==> number_of_edges H + 1 = number_of_edges (edge_walkup H x)`,
     REPEAT GEN_TAC
     THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F1") (LABEL_TAC "F2"))
     THEN REWRITE_TAC[number_of_edges]
     THEN MP_TAC (SPECL[`H:(A)hypermap`; `x:A`] lemma_walkup_edges)
     THEN ASM_REWRITE_TAC[]
     THEN USE_THEN "F2" MP_TAC
     THEN REWRITE_TAC[is_edge_split]
     THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F3") (LABEL_TAC "F4"))
     THEN USE_THEN "F4" (MP_TAC o MATCH_MP lemma_edge_identity)
     THEN DISCH_THEN (SUBST1_TAC o SYM)
     THEN REWRITE_TAC[SET_RULE `s DIFF {a,a} = s DELETE a`]
     THEN MP_TAC (CONJUNCT1(SPECL[`H:(A)hypermap`; `x:A`] lemma_in_hypermap_orbits))
     THEN ASM_REWRITE_TAC[]
     THEN DISCH_THEN ASSUME_TAC
     THEN MP_TAC (ISPECL[`edge_set (H:(A)hypermap)`; `edge (H:(A)hypermap) (x:A)`] CARD_MINUS_ONE)
     THEN POP_ASSUM (fun th ->REWRITE_TAC[th; FINITE_HYPERMAP_ORBITS])
     THEN DISCH_THEN SUBST1_TAC
     THEN DISCH_THEN SUBST1_TAC
     THEN CONV_TAC SYM_CONV
     THEN REWRITE_TAC[ARITH_RULE `((k:num)+1)+1 = k + 2`]
     THEN MP_TAC (CONJUNCT1(CONJUNCT2(CONJUNCT2(SPECL[`H:(A)hypermap`; `x:A`; `x:A`] edge_map_walkup))))
     THEN USE_THEN "F3" (MP_TAC o MATCH_MP  lemma_inverse_maps_at_nondegenerate_dart)
     THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F5") (CONJUNCTS_THEN2 (LABEL_TAC "F6") (LABEL_TAC "F7")))
     THEN ASM_REWRITE_TAC[]
     THEN DISCH_TAC
     THEN MP_TAC (SPECL[`edge_map(edge_walkup (H:(A)hypermap) (x:A))`; `1`; `inverse(edge_map (H:(A)hypermap)) (x:A)`; `inverse(face_map (H:(A)hypermap)) (x:A)`] in_orbit_lemma)
     THEN REWRITE_TAC[POWER_1]
     THEN POP_ASSUM(fun th -> GEN_REWRITE_TAC (LAND_CONV o LAND_CONV o TOP_DEPTH_CONV)  [SYM th])
     THEN REWRITE_TAC[lemma_edge_identity; GSYM edge]
     THEN DISCH_THEN (MP_TAC o MATCH_MP lemma_edge_identity)
     THEN DISCH_THEN SUBST1_TAC
     THEN USE_THEN "F1" (fun th1 -> (USE_THEN "F2" (fun th2 -> (MP_TAC (CONJUNCT1(MATCH_MP lemma_edge_split (CONJ th1 th2)))))))
     THEN DISCH_THEN (MP_TAC o GSYM o MATCH_MP lemma_different_edges)
     THEN DISCH_THEN (MP_TAC o MATCH_MP CARD_TWO_ELEMENTS)
     THEN DISCH_THEN (fun th -> REWRITE_TAC[GSYM th])
     THEN MATCH_MP_TAC CARD_MINUS_DIFF_TWO_SET
     THEN REWRITE_TAC[FINITE_HYPERMAP_ORBITS]
     THEN USE_THEN "F1" (fun th1 -> (USE_THEN "F2" (fun th2 -> (MP_TAC (CONJUNCT1(MATCH_MP lemma_edge_split (CONJ th1 th2)))))))
     THEN USE_THEN "F3" MP_TAC
     THEN REWRITE_TAC[dart_nondegenerate]
     THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "G1") (CONJUNCTS_THEN2 (LABEL_TAC "F2") (LABEL_TAC "G3")))
     THEN USE_THEN "F1" (fun th1 -> (USE_THEN "F2" (fun th2 -> (MP_TAC (CONJUNCT1(MATCH_MP lemma_node_map_walkup_in_dart (CONJ th1 th2)))))))
     THEN REWRITE_TAC[lemma_in_edge_set]
     THEN DISCH_THEN (fun th-> REWRITE_TAC[th])
     THEN USE_THEN "F1" (fun th1 -> (USE_THEN "G3" (fun th2 -> (MP_TAC (CONJUNCT2(MATCH_MP lemma_face_map_walkup_in_dart (CONJ th1 th2)))))))
     THEN REWRITE_TAC[lemma_in_edge_set]
     THEN SIMP_TAC[]);;

(* Compute number of edges acording to then splitting cas *)

let lemma_merge_case_count_edges = prove(`!(H:(A)hypermap) (x:A). x IN dart H /\ is_edge_merge H x ==> number_of_edges H = number_of_edges (edge_walkup H x) + 1`,
     REPEAT GEN_TAC
     THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F1") (LABEL_TAC "F2"))
     THEN REWRITE_TAC[number_of_edges]
     THEN MP_TAC (SPECL[`H:(A)hypermap`; `x:A`] lemma_walkup_edges)
     THEN ASM_REWRITE_TAC[]
     THEN USE_THEN "F2" MP_TAC
     THEN REWRITE_TAC[is_edge_merge]
     THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F3") (LABEL_TAC "F4"))
     THEN USE_THEN "F3" MP_TAC
     THEN REWRITE_TAC[dart_nondegenerate]
     THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F5") (CONJUNCTS_THEN2 (LABEL_TAC "F6") (LABEL_TAC "F7")))
       THEN USE_THEN "F4" (ASSUME_TAC o GSYM o MATCH_MP lemma_different_edges)
       THEN MP_TAC(ISPECL[`edge_set (H:(A)hypermap)`; `edge (H:(A)hypermap) (x:A)`; `edge (H:(A)hypermap) (node_map H (x:A))`] CARD_MINUS_DIFF_TWO_SET)
       THEN REWRITE_TAC[FINITE_HYPERMAP_ORBITS]
       THEN USE_THEN "F1" MP_TAC
       THEN REWRITE_TAC[lemma_in_edge_set]
       THEN DISCH_THEN (fun th -> REWRITE_TAC[th])
       THEN USE_THEN "F1" (MP_TAC o CONJUNCT1 o CONJUNCT2 o MATCH_MP lemma_dart_invariant)
       THEN REWRITE_TAC[lemma_in_edge_set]
       THEN DISCH_THEN (fun th -> REWRITE_TAC[th])
       THEN POP_ASSUM (SUBST1_TAC o MATCH_MP CARD_TWO_ELEMENTS)
       THEN DISCH_THEN SUBST1_TAC
       THEN DISCH_THEN SUBST1_TAC
       THEN USE_THEN "F1" (fun th1 -> (USE_THEN "F2" (fun th2 -> (LABEL_TAC "F8" (SYM(MATCH_MP lemma_edge_merge (CONJ th1 th2)))))))
       THEN MP_TAC (SPECL[`dart (H:(A)hypermap)`; `edge_map (H:(A)hypermap)`; `x:A`] lemma_inverse_in_orbit)
       THEN GEN_REWRITE_TAC (LAND_CONV o DEPTH_CONV) [hypermap_lemma]
       THEN REWRITE_TAC[GSYM edge]
       THEN DISCH_TAC
       THEN MP_TAC (SET_RULE `(inverse (edge_map (H:(A)hypermap)) (x:A)) IN (edge H x) ==> (inverse (edge_map H) x)  IN ((edge H x)  UNION (edge H ((node_map H) x)))`)
       THEN POP_ASSUM (fun th-> REWRITE_TAC[th])
       THEN POP_ASSUM SUBST1_TAC
       THEN REWRITE_TAC[IN_UNION; IN_SING]
       THEN USE_THEN "F3" (fun th -> REWRITE_TAC[MATCH_MP lemma_inverse_maps_at_nondegenerate_dart th])
       THEN REWRITE_TAC[lemma_edge_identity]
       THEN DISCH_THEN (MP_TAC o MATCH_MP lemma_edge_identity)
       THEN DISCH_THEN (SUBST1_TAC o SYM)      
       THEN REWRITE_TAC[SET_RULE `s DIFF {a,a} = s DELETE a`]
       THEN USE_THEN "F1" (fun th1 -> (USE_THEN "F6" (fun th2 -> (MP_TAC (CONJUNCT1(MATCH_MP lemma_node_map_walkup_in_dart (CONJ th1 th2)))))))
       THEN REWRITE_TAC[lemma_in_edge_set]
       THEN DISCH_TAC
       THEN REWRITE_TAC[ARITH_RULE `(m:num) + 2 = (n:num) + 1 <=> m + 1 = n`]
       THEN CONV_TAC SYM_CONV
       THEN MATCH_MP_TAC CARD_MINUS_ONE
       THEN POP_ASSUM (fun th -> REWRITE_TAC[th])
       THEN REWRITE_TAC[FINITE_HYPERMAP_ORBITS]);;

(* NODES and FACES IN all cases are invariant*)

let lemma_walkup_count_nodes = prove(`!(H:(A)hypermap) (x:A). x IN dart H /\ dart_nondegenerate H x ==> number_of_nodes H = number_of_nodes (edge_walkup H x)`, 
     REPEAT GEN_TAC
     THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F1") (MP_TAC))
     THEN REWRITE_TAC[dart_nondegenerate]
     THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F2") (CONJUNCTS_THEN2 (LABEL_TAC "F3") (LABEL_TAC "F4")))
     THEN REWRITE_TAC[number_of_nodes]
     THEN MP_TAC (SPECL[`H:(A)hypermap`; `x:A`] lemma_walkup_nodes)
     THEN ASM_REWRITE_TAC[]
     THEN USE_THEN "F1" MP_TAC
     THEN REWRITE_TAC[lemma_in_node_set]
     THEN DISCH_TAC
     THEN MP_TAC (ISPECL[`node_set (H:(A)hypermap)`; `node (H:(A)hypermap) (x:A)`] CARD_MINUS_ONE)
     THEN POP_ASSUM (fun th ->REWRITE_TAC[th; FINITE_HYPERMAP_ORBITS])
     THEN REPLICATE_TAC 2 (DISCH_THEN SUBST1_TAC)
     THEN USE_THEN "F1" (fun th1 -> (USE_THEN "F3" (fun th2 -> (MP_TAC (CONJUNCT2(MATCH_MP lemma_node_map_walkup_in_dart (CONJ th1 th2)))))))
     THEN REWRITE_TAC[lemma_in_node_set]
     THEN DISCH_TAC
     THEN MP_TAC (ISPECL[`node_set (edge_walkup (H:(A)hypermap) (x:A))`; `node (edge_walkup (H:(A)hypermap) (x:A)) ((inverse (node_map H) (x:A)))`] CARD_MINUS_ONE)
     THEN POP_ASSUM (fun th ->REWRITE_TAC[th; FINITE_HYPERMAP_ORBITS])
     THEN DISCH_THEN SUBST1_TAC
     THEN SIMP_TAC[]);;

let lemma_walkup_count_faces = prove(`!(H:(A)hypermap) (x:A). x IN dart H /\ dart_nondegenerate H x ==> number_of_faces H = number_of_faces (edge_walkup H x)`,
       REPEAT GEN_TAC
       THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F1") (MP_TAC))
       THEN REWRITE_TAC[dart_nondegenerate]
       THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F2") (CONJUNCTS_THEN2 (LABEL_TAC "F3") (LABEL_TAC "F4")))
       THEN REWRITE_TAC[number_of_faces]
       THEN MP_TAC (SPECL[`H:(A)hypermap`; `x:A`] lemma_walkup_faces)
       THEN ASM_REWRITE_TAC[]
       THEN USE_THEN "F1" MP_TAC
       THEN REWRITE_TAC[lemma_in_face_set]
       THEN DISCH_TAC
       THEN MP_TAC (ISPECL[`face_set (H:(A)hypermap)`; `face (H:(A)hypermap) (x:A)`] CARD_MINUS_ONE)
       THEN POP_ASSUM (fun th ->REWRITE_TAC[th; FINITE_HYPERMAP_ORBITS])
       THEN REPLICATE_TAC 2 (DISCH_THEN SUBST1_TAC)
       THEN USE_THEN "F1" (fun th1 -> (USE_THEN "F4" (fun th2 -> (MP_TAC (CONJUNCT2(MATCH_MP lemma_face_map_walkup_in_dart (CONJ th1 th2)))))))
       THEN REWRITE_TAC[lemma_in_face_set]
       THEN DISCH_TAC
       THEN MP_TAC (ISPECL[`face_set (edge_walkup (H:(A)hypermap) (x:A))`; `face (edge_walkup (H:(A)hypermap) (x:A)) ((inverse (face_map H) (x:A)))`] CARD_MINUS_ONE)
       THEN POP_ASSUM (fun th ->REWRITE_TAC[th; FINITE_HYPERMAP_ORBITS])
       THEN DISCH_THEN SUBST1_TAC
       THEN SIMP_TAC[]);;

(* For components, we have two cases: component splitting and not splitting *)


let lemma_walkup_count_splitting_components = prove(`!(H:(A)hypermap) (x:A).x IN dart H /\ dart_nondegenerate H x /\ ~(comb_component (edge_walkup H x) (node_map H x) = comb_component (edge_walkup H x) (inverse (edge_map H) x)) ==> (number_of_components H) + 1 = number_of_components (edge_walkup H x)`,
REPEAT GEN_TAC
  THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F1") (CONJUNCTS_THEN2 (LABEL_TAC "F2") (LABEL_TAC "F3")))
  THEN REWRITE_TAC[number_of_components]
  THEN USE_THEN "F1" (MP_TAC o MATCH_MP lemma_walkup_components)
  THEN USE_THEN "F1" MP_TAC
  THEN REWRITE_TAC[lemma_in_components]
  THEN DISCH_TAC
  THEN POP_ASSUM (fun th -> (MP_TAC (MATCH_MP CARD_MINUS_ONE (CONJ (SPEC `H:(A)hypermap` FINITE_HYPERMAP_COMPONENTS) th))))
  THEN DISCH_THEN SUBST1_TAC
  THEN DISCH_THEN SUBST1_TAC
  THEN REWRITE_TAC[ARITH_RULE `((m:num) + 1) + 1 = m + 2`]
  THEN POP_ASSUM (MP_TAC o MATCH_MP CARD_TWO_ELEMENTS)
  THEN DISCH_THEN (SUBST1_TAC o SYM)
  THEN CONV_TAC SYM_CONV
  THEN MATCH_MP_TAC CARD_MINUS_DIFF_TWO_SET
  THEN REWRITE_TAC[FINITE_HYPERMAP_COMPONENTS]
  THEN POP_ASSUM MP_TAC
  THEN REWRITE_TAC[dart_nondegenerate]
  THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "G2") (LABEL_TAC "G3" o CONJUNCT1))
  THEN USE_THEN "F1" (fun th-> (USE_THEN "G3" (fun th1 -> (MP_TAC (CONJUNCT1(MATCH_MP lemma_node_map_walkup_in_dart (CONJ th th1)))))))
  THEN REWRITE_TAC[lemma_in_components]
  THEN DISCH_THEN (fun th -> REWRITE_TAC[th])
  THEN USE_THEN "F1" (fun th-> (USE_THEN "G2" (fun th1 -> (MP_TAC (CONJUNCT2(MATCH_MP lemma_edge_map_walkup_in_dart (CONJ th th1)))))))
  THEN REWRITE_TAC[lemma_in_components]);;


let lemma_walkup_count_not_splitting_components = prove(`!(H:(A)hypermap) (x:A).x IN dart H /\ dart_nondegenerate H x /\ comb_component (edge_walkup H x) (node_map H x) = comb_component (edge_walkup H x) (inverse (edge_map H) x) ==> (number_of_components H) = number_of_components (edge_walkup H x)`,
    REPEAT GEN_TAC
    THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F1") (CONJUNCTS_THEN2 (LABEL_TAC "F2") (LABEL_TAC "F3")))
    THEN REWRITE_TAC[number_of_components]
    THEN USE_THEN "F1" (MP_TAC o MATCH_MP lemma_walkup_components)
    THEN USE_THEN "F1" MP_TAC
    THEN REWRITE_TAC[lemma_in_components]
    THEN DISCH_TAC
    THEN POP_ASSUM (fun th -> (MP_TAC (MATCH_MP CARD_MINUS_ONE (CONJ (SPEC `H:(A)hypermap` FINITE_HYPERMAP_COMPONENTS) th))))
    THEN DISCH_THEN SUBST1_TAC
    THEN DISCH_THEN SUBST1_TAC
    THEN POP_ASSUM (SUBST1_TAC o SYM)
    THEN REWRITE_TAC[SET_RULE `s DIFF {a,a} = s DELETE a`]
    THEN CONV_TAC  SYM_CONV
    THEN MATCH_MP_TAC CARD_MINUS_ONE
    THEN REWRITE_TAC[FINITE_HYPERMAP_COMPONENTS]
    THEN POP_ASSUM MP_TAC
    THEN REWRITE_TAC[dart_nondegenerate]
    THEN DISCH_THEN (LABEL_TAC "G2" o CONJUNCT1 o CONJUNCT2)
    THEN USE_THEN "F1" (fun th-> (USE_THEN "G2" (fun th1 -> (MP_TAC (CONJUNCT1(MATCH_MP lemma_node_map_walkup_in_dart (CONJ th th1)))))))
    THEN REWRITE_TAC[lemma_in_components]);;

let is_splitting_component = new_definition `is_splitting_component (H:(A)hypermap) (x:A) <=> ~(comb_component (edge_walkup H x) (node_map H x) = comb_component (edge_walkup H x) (inverse (edge_map H) x))`;;

let lemma_in_edge = prove(`!(H:(A)hypermap) (x:A) (y:A). y IN edge H x <=> (?j:num. y = ((edge_map H) POWER j) x)`,
   REPEAT GEN_TAC THEN REWRITE_TAC[edge; orbit_map; IN_ELIM_THM] THEN REWRITE_TAC[ARITH_RULE `(n:num) >= 0`]);;

let lemma_planar_index_on_nondegenerate = prove(`!(H:(A)hypermap) (x:A). x IN dart H /\ dart_nondegenerate H x ==>
(is_edge_split H x /\ ~(is_splitting_component H x) ==> (planar_ind H) + &2 = planar_ind (edge_walkup H x)) /\
(~(is_edge_split H x /\ ~(is_splitting_component H x)) ==> (planar_ind H) = planar_ind (edge_walkup H x))`,
     REPEAT GEN_TAC THEN REWRITE_TAC[is_splitting_component]
     THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F1") (LABEL_TAC "F2"))
     THEN STRIP_TAC
     THENL[DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "G1") (LABEL_TAC "G2"))
	     THEN REWRITE_TAC[planar_ind]
	     THEN USE_THEN "F1" (fun th1 -> (USE_THEN "F2" (fun th2 -> (SUBST1_TAC (SYM(MATCH_MP lemma_walkup_count_nodes (CONJ th1 th2)))))))
	     THEN USE_THEN "F1" (fun th1 -> (USE_THEN "F2" (fun th2 -> (SUBST1_TAC (SYM(MATCH_MP lemma_walkup_count_faces (CONJ th1 th2)))))))
	     THEN USE_THEN "F1" (fun th1 -> (USE_THEN "G1" (fun th2 -> (SUBST1_TAC (SYM(MATCH_MP lemma_splitting_case_count_edges (CONJ th1 th2)))))))
	     THEN USE_THEN "F1" (fun th1 -> (SUBST1_TAC (MATCH_MP lemma_card_walkup_dart th1)))
	     THEN USE_THEN "F1" (fun th1 -> (USE_THEN "F2" (fun th2 -> (USE_THEN "G2" (fun th3 -> SUBST1_TAC (SYM(MATCH_MP lemma_walkup_count_not_splitting_components (CONJ th1 (CONJ th2 th3)))))))))
	     THEN REWRITE_TAC[GSYM REAL_ADD']
	     THEN REAL_ARITH_TAC; ALL_TAC]
     THEN REWRITE_TAC[DE_MORGAN_THM]
     THEN ASM_CASES_TAC `~(is_edge_split (H:(A)hypermap) (x:A))`
     THENL[ ASM_REWRITE_TAC[] 
	    THEN POP_ASSUM MP_TAC
	     THEN REWRITE_TAC[is_edge_split]
	     THEN ASM_REWRITE_TAC[]
	     THEN DISCH_THEN (LABEL_TAC "F3")
	     THEN MP_TAC(SPECL[`H:(A)hypermap`; `x:A`] is_edge_merge)
	     THEN ASM_REWRITE_TAC[]
	     THEN DISCH_THEN (LABEL_TAC "F4")
	     THEN SUBGOAL_THEN `comb_component (edge_walkup (H:(A)hypermap) (x:A)) (node_map H x) = comb_component (edge_walkup H x) (inverse (edge_map H) x)` (LABEL_TAC "J1")
	     THENL[USE_THEN "F1" (fun th1 -> (USE_THEN "F4" (fun th2 -> (LABEL_TAC "F8" (SYM(MATCH_MP lemma_edge_merge (CONJ th1 th2)))))))
		     THEN MP_TAC (SPECL[`dart (H:(A)hypermap)`; `edge_map (H:(A)hypermap)`; `x:A`] lemma_inverse_in_orbit)
		     THEN GEN_REWRITE_TAC (LAND_CONV o DEPTH_CONV) [hypermap_lemma]
		     THEN REWRITE_TAC[GSYM edge]
		     THEN DISCH_TAC
		     THEN MP_TAC (SET_RULE `(inverse (edge_map (H:(A)hypermap)) (x:A)) IN (edge H x) ==> (inverse (edge_map H) x)  IN ((edge H x)  UNION (edge H ((node_map H) x)))`)
		     THEN POP_ASSUM (fun th-> REWRITE_TAC[th])
		     THEN POP_ASSUM SUBST1_TAC
		     THEN REWRITE_TAC[IN_UNION; IN_SING]
		     THEN USE_THEN "F2" (fun th -> REWRITE_TAC[MATCH_MP  lemma_inverse_maps_at_nondegenerate_dart th])
		     THEN REWRITE_TAC[lemma_in_edge]
		     THEN DISCH_THEN (X_CHOOSE_THEN `j:num` ASSUME_TAC)
		     THEN MP_TAC (CONJUNCT1(SPECL[`edge_walkup (H:(A)hypermap) (x:A)`; `node_map (H:(A)hypermap) (x:A)`; `j:num`] lemma_powers_in_component))
		     THEN POP_ASSUM (SUBST1_TAC o SYM)
		     THEN DISCH_THEN (MP_TAC o MATCH_MP lemma_component_identity)
		     THEN SIMP_TAC[]; ALL_TAC]
	     THEN REWRITE_TAC[planar_ind]
	     THEN USE_THEN "F1" (fun th1 -> (USE_THEN "F2" (fun th2 -> (SUBST1_TAC (SYM(MATCH_MP lemma_walkup_count_nodes (CONJ th1 th2)))))))
	     THEN USE_THEN "F1" (fun th1 -> (USE_THEN "F2" (fun th2 -> (SUBST1_TAC (SYM(MATCH_MP lemma_walkup_count_faces (CONJ th1 th2)))))))
	     THEN USE_THEN "F1" (fun th1 -> (USE_THEN "F4" (fun th2 -> (SUBST1_TAC (MATCH_MP lemma_merge_case_count_edges (CONJ th1 th2))))))
	     THEN USE_THEN "F1" (fun th1 -> (SUBST1_TAC (MATCH_MP lemma_card_walkup_dart th1)))
	     THEN USE_THEN "F1" (fun th1 -> (USE_THEN "F2" (fun th2 -> (USE_THEN "J1" (fun th3 -> SUBST1_TAC (SYM(MATCH_MP lemma_walkup_count_not_splitting_components (CONJ th1 (CONJ th2 th3)))))))))
	     THEN REWRITE_TAC[GSYM REAL_ADD']
	     THEN REAL_ARITH_TAC; ALL_TAC]
     THEN POP_ASSUM MP_TAC
     THEN REWRITE_TAC[TAUT `~ ~P = P`]
     THEN DISCH_THEN (LABEL_TAC "K1")
     THEN ASM_REWRITE_TAC[]
     THEN DISCH_THEN (LABEL_TAC "K2")
     THEN REWRITE_TAC[planar_ind]
     THEN USE_THEN "F1" (fun th1 -> (USE_THEN "F2" (fun th2 -> (SUBST1_TAC (SYM(MATCH_MP lemma_walkup_count_nodes (CONJ th1 th2)))))))
     THEN USE_THEN "F1" (fun th1 -> (USE_THEN "F2" (fun th2 -> (SUBST1_TAC (SYM(MATCH_MP lemma_walkup_count_faces (CONJ th1 th2)))))))
     THEN USE_THEN "F1" (fun th1 -> (USE_THEN "K1" (fun th2 -> (SUBST1_TAC (SYM(MATCH_MP lemma_splitting_case_count_edges (CONJ th1 th2)))))))
     THEN USE_THEN "F1" (fun th1 -> (SUBST1_TAC (MATCH_MP lemma_card_walkup_dart th1)))
     THEN USE_THEN "F1" (fun th1 -> (USE_THEN "F2" (fun th2 -> (USE_THEN "K2" (fun th3 -> SUBST1_TAC (SYM(MATCH_MP lemma_walkup_count_splitting_components (CONJ th1 (CONJ th2 th3)))))))))
     THEN REWRITE_TAC[GSYM REAL_ADD']
     THEN REAL_ARITH_TAC);;

(* LEMMA IUCLZYI *)

let lemmaIUCLZYI = prove(`!(H:(A)hypermap) x:A. (x IN dart H /\ dart_nondegenerate H x ==> 
(is_edge_split H x ==> number_of_edges H + 1 = number_of_edges (edge_walkup H x)) /\ (is_edge_merge H x ==> number_of_edges H = number_of_edges (edge_walkup H x) + 1) /\ (number_of_nodes H = number_of_nodes (edge_walkup H x)) /\ (number_of_faces H = number_of_faces (edge_walkup H x))
/\ (is_splitting_component H x ==> (number_of_components H) + 1 = number_of_components (edge_walkup H x))/\ (~(is_splitting_component H x) ==> (number_of_components H)  = number_of_components (edge_walkup H x)) /\(is_edge_split H x /\ ~(is_splitting_component H x) ==> (planar_ind H) + &2 = planar_ind (edge_walkup H x)) /\ (~(is_edge_split H x /\ ~(is_splitting_component H x)) ==> (planar_ind H) = planar_ind (edge_walkup H x))) /\ (x IN dart H /\ dart_degenerate H x ==> planar_ind H = planar_ind (edge_walkup H x))`,
   SIMP_TAC[lemma_planar_index_on_walkup_at_degenerate_dart]
   THEN SIMP_TAC[lemma_planar_index_on_nondegenerate]
   THEN SIMP_TAC[lemma_walkup_count_nodes; lemma_walkup_count_faces]
   THEN SIMP_TAC[lemma_merge_case_count_edges; lemma_splitting_case_count_edges]
   THEN REWRITE_TAC[is_splitting_component]
   THEN MESON_TAC[lemma_walkup_count_not_splitting_components; lemma_walkup_count_splitting_components]);;

let lemma_desc_planar_index = prove(`!(H:(A)hypermap) (x:A). x IN dart H ==> planar_ind H <= planar_ind (edge_walkup H x)`,
  REPEAT GEN_TAC
    THEN DISCH_THEN (LABEL_TAC "F1")
    THEN MP_TAC(SPECL[`H:(A)hypermap`; `x:A`] lemma_category_darts)
    THEN STRIP_TAC
    THENL[POP_ASSUM (LABEL_TAC "F2")
       THEN ASM_CASES_TAC `is_edge_split (H:(A)hypermap) (x:A) /\ ~is_splitting_component H x`
       THENL[USE_THEN "F1" (fun th1 -> (USE_THEN "F2" (fun th2 -> (MP_TAC (CONJUNCT1(MATCH_MP lemma_planar_index_on_nondegenerate (CONJ th1 th2)))))))
	   THEN ASM_REWRITE_TAC[]
	   THEN REAL_ARITH_TAC; ALL_TAC]
       THEN USE_THEN "F1" (fun th1 -> (USE_THEN "F2" (fun th2 -> (MP_TAC (CONJUNCT2(MATCH_MP lemma_planar_index_on_nondegenerate (CONJ th1 th2)))))))
       THEN ASM_REWRITE_TAC[]
       THEN REAL_ARITH_TAC; ALL_TAC]
    THEN POP_ASSUM (fun th1 -> (USE_THEN "F1" (fun th2 -> (MP_TAC (MATCH_MP lemma_planar_index_on_walkup_at_degenerate_dart (CONJ th2 th1))))))
    THEN REAL_ARITH_TAC);;

let lemmaBISHKQW = prove(`!(H:(A)hypermap) (x:A). x IN dart H ==> planar_ind H <= planar_ind (edge_walkup H x) /\ planar_ind H <= planar_ind (node_walkup H x) /\ planar_ind H <= planar_ind (face_walkup H x)`,
     REPEAT GEN_TAC
     THEN DISCH_THEN (LABEL_TAC "F1")
     THEN USE_THEN "F1" (fun th -> REWRITE_TAC[MATCH_MP lemma_desc_planar_index th])
     THEN STRIP_TAC
     THENL[REWRITE_TAC[node_walkup]
	     THEN ONCE_REWRITE_TAC[lemma_planar_invariant_shift]
	     THEN REWRITE_TAC[lemma_shift_cycle]
	     THEN POP_ASSUM MP_TAC
	     THEN ONCE_REWRITE_TAC[shift_lemma]
	     THEN DISCH_THEN (fun th -> REWRITE_TAC[MATCH_MP lemma_desc_planar_index th]); ALL_TAC]
     THEN REWRITE_TAC[face_walkup]
     THEN ONCE_REWRITE_TAC[lemma_planar_invariant_shift]
     THEN ONCE_REWRITE_TAC[lemma_planar_invariant_shift]
     THEN REWRITE_TAC[lemma_shift_cycle]
     THEN POP_ASSUM MP_TAC
     THEN ONCE_REWRITE_TAC[double_shift_lemma]
     THEN DISCH_THEN (fun th -> REWRITE_TAC[MATCH_MP lemma_desc_planar_index th]));;


let lemmaFOAGLPA = prove(`!(H:(A)hypermap). planar_ind H <= &0`,
   GEN_TAC
   THEN ABBREV_TAC `n = CARD(dart (H:(A)hypermap))`
   THEN POP_ASSUM (MP_TAC)
   THEN SPEC_TAC(`H:(A)hypermap`, `H:(A)hypermap`)
   THEN SPEC_TAC(`n:num`, `n:num`)
   THEN INDUCT_TAC 
   THENL[REPEAT STRIP_TAC
	THEN POP_ASSUM (MP_TAC o MATCH_MP lemma_null_hypermap_planar_index)
	THEN REAL_ARITH_TAC; ALL_TAC]
   THEN REPEAT STRIP_TAC
   THEN POP_ASSUM (LABEL_TAC "F2")
   THEN ASM_CASES_TAC `dart (H:(A)hypermap) = {}`
   THENL[POP_ASSUM (MP_TAC o MATCH_MP lemma_card_eq_reflect)
	   THEN POP_ASSUM SUBST1_TAC
	   THEN REWRITE_TAC[CARD_CLAUSES]
	   THEN ARITH_TAC; ALL_TAC]
   THEN POP_ASSUM (MP_TAC o MATCH_MP CHOICE_DEF)
   THEN ABBREV_TAC `(x:A) = CHOICE (dart (H:(A)hypermap))`
   THEN DISCH_THEN (LABEL_TAC "F1")
   THEN USE_THEN "F1" (ASSUME_TAC o MATCH_MP lemma_desc_planar_index)
   THEN USE_THEN "F1" (MP_TAC o MATCH_MP lemma_card_walkup_dart)
   THEN REMOVE_THEN "F2" SUBST1_TAC
   THEN REWRITE_TAC[GSYM ADD1; EQ_SUC]
   THEN DISCH_THEN (LABEL_TAC "F3" o SYM)
   THEN FIRST_ASSUM (MP_TAC o SPEC `edge_walkup (H:(A)hypermap) (x:A)`)
   THEN POP_ASSUM (fun th -> REWRITE_TAC[th])
   THEN POP_ASSUM MP_TAC
   THEN REAL_ARITH_TAC);;

let lemmaSGCOSXK = prove(`!(H:(A)hypermap) (x:A). x IN dart H /\ planar_hypermap H ==> planar_hypermap (edge_walkup H x) /\ planar_hypermap (node_walkup H x) /\ planar_hypermap (face_walkup H x)`,
   REPEAT GEN_TAC
     THEN REWRITE_TAC[lemma_planar_hypermap]
     THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F1") (LABEL_TAC "F2"))
     THEN STRIP_TAC
     THENL[USE_THEN "F1" (MP_TAC o CONJUNCT1 o MATCH_MP lemmaBISHKQW)
	     THEN POP_ASSUM SUBST1_TAC
	     THEN MP_TAC (SPEC `edge_walkup (H:(A)hypermap) (x:A)` lemmaFOAGLPA)
	     THEN REAL_ARITH_TAC; ALL_TAC]
     THEN STRIP_TAC
     THENL[USE_THEN "F1" (MP_TAC o CONJUNCT1 o CONJUNCT2 o MATCH_MP lemmaBISHKQW)
             THEN POP_ASSUM SUBST1_TAC
             THEN MP_TAC (SPEC `node_walkup (H:(A)hypermap) (x:A)` lemmaFOAGLPA)
             THEN REAL_ARITH_TAC; ALL_TAC]
     THEN USE_THEN "F1" (MP_TAC o CONJUNCT2 o CONJUNCT2 o MATCH_MP lemmaBISHKQW)
     THEN POP_ASSUM SUBST1_TAC
     THEN MP_TAC (SPEC `face_walkup (H:(A)hypermap) (x:A)` lemmaFOAGLPA)
     THEN REAL_ARITH_TAC);;

(* double walkups *)


let convolution_rep = prove(`!s:A->bool p:A->A. p permutes s ==> (p o p = I <=> p = inverse p)`,
    REPEAT STRIP_TAC
    THEN EQ_TAC
    THENL[POP_ASSUM (fun th-> (DISCH_THEN (fun th1->(MP_TAC (MATCH_MP LEFT_INVERSE_EQUATION (CONJ th th1))))))
	THEN REWRITE_TAC[I_O_ID]; ALL_TAC]
    THEN DISCH_THEN (MP_TAC o SPEC `p:A->A` o  MATCH_MP RIGHT_MULT_MAP)
    THEN POP_ASSUM (fun th -> REWRITE_TAC[MATCH_MP PERMUTES_INVERSES_o th]));;

let convolution_inv = prove(`!s:A->bool p:A->A. p permutes s ==> (p o p = I <=> inverse p o inverse p = I)`,
  REPEAT GEN_TAC
    THEN DISCH_THEN (LABEL_TAC "F1")
    THEN EQ_TAC
    THENL[DISCH_THEN (fun th -> LABEL_TAC "F2" th THEN MP_TAC th)
       THEN USE_THEN "F1" (fun th->(DISCH_THEN (fun th1->(MP_TAC (MATCH_MP LEFT_INVERSE_EQUATION (CONJ th th1))))))
       THEN REWRITE_TAC[I_O_ID]
       THEN DISCH_THEN (SUBST1_TAC o SYM)
       THEN ASM_REWRITE_TAC[]; ALL_TAC]
    THEN DISCH_THEN (MP_TAC o SPEC `p:A->A` o  MATCH_MP RIGHT_MULT_MAP)
    THEN REWRITE_TAC[GSYM o_ASSOC]
    THEN USE_THEN "F1" (fun th-> REWRITE_TAC[MATCH_MP PERMUTES_INVERSES_o th; I_O_ID])
    THEN DISCH_THEN(fun th -> GEN_REWRITE_TAC (LAND_CONV o LAND_CONV o ONCE_DEPTH_CONV) [SYM th])
    THEN USE_THEN "F1" (fun th-> REWRITE_TAC[MATCH_MP PERMUTES_INVERSES_o th; I_O_ID]));;

let convolution_inside = prove(`!s:A->bool p:A->A. p permutes s ==> (p o p = I <=> (!x:A. x IN s ==> p (p x) = x))`,
    REPEAT STRIP_TAC
    THEN EQ_TAC
    THENL[REPEAT STRIP_TAC
        THEN FIRST_X_ASSUM (fun th -> (MP_TAC(AP_THM th `x:A`)))
	THEN REWRITE_TAC[o_THM; I_THM]; ALL_TAC]
    THEN STRIP_TAC
    THEN REWRITE_TAC[FUN_EQ_THM]
    THEN GEN_TAC
    THEN REWRITE_TAC[o_THM; I_THM]
    THEN ASM_CASES_TAC `~(x:A IN s:A->bool)`
    THENL[POP_ASSUM MP_TAC
        THEN UNDISCH_TAC `p:A->A permutes s:A->bool`
	THEN REWRITE_TAC[permutes]
	THEN DISCH_THEN (MP_TAC o CONJUNCT1)
	THEN MESON_TAC[]; ALL_TAC]
    THEN ASM_MESON_TAC[]);;

let edge_convolution = prove(`!(H:(A)hypermap). plain_hypermap H <=> !x:A. x IN dart H ==> node_map H (face_map H (node_map H (face_map H x))) = x`,
    REPEAT GEN_TAC
    THEN REWRITE_TAC[plain_hypermap]
    THEN REWRITE_TAC[MATCH_MP convolution_inv (CONJUNCT2 (SPEC `H:(A)hypermap` edge_map_and_darts))]
    THEN ASSUME_TAC (MATCH_MP PERMUTES_INVERSE (CONJUNCT2(SPEC `H:(A)hypermap` edge_map_and_darts)))
    THEN POP_ASSUM (fun th-> REWRITE_TAC[MATCH_MP convolution_inside th])
    THEN ONCE_REWRITE_TAC[CONJUNCT1(SPEC `H:(A)hypermap` inverse_hypermap_maps)]
    THEN REWRITE_TAC[inverse_hypermap_maps; o_THM]);;

let lemma_convolution_evaluation = prove(`!s:A->bool p:A->A x:A. FINITE s /\ p permutes s ==> ((p (p x)) = x <=> CARD (orbit_map p x) <= 2)`,
   REPEAT GEN_TAC THEN DISCH_TAC THEN EQ_TAC
   THENL[STRIP_TAC THEN MP_TAC (SPECL[`p:A->A`; `2`; `x:A`] card_orbit_le)
	THEN REWRITE_TAC[POWER_2; o_THM;  ARITH_RULE `~(2 = 0)`]
	THEN ASM_REWRITE_TAC[]; ALL_TAC]
   THEN ASM_CASES_TAC `(p:A->A) (x:A) = x` THENL[REWRITE_TAC[POWER_2; o_THM] THEN ASM_REWRITE_TAC[]; ALL_TAC]
   THEN ASM_CASES_TAC `(p:A->A) (p (x:A)) = x` THENL[ASM_REWRITE_TAC[]; ALL_TAC]
   THEN ABBREV_TAC `n = CARD(orbit_map (p:A->A) (x:A))`
   THEN DISCH_TAC
   THEN FIRST_ASSUM (MP_TAC o SPEC `x:A` o MATCH_MP lemma_cycle_orbit)
   THEN ASM_REWRITE_TAC[]
   THEN FIRST_ASSUM (ASSUME_TAC o SPEC `x:A` o MATCH_MP lemma_orbit_finite)
   THEN ASSUME_TAC (SPECL[`p:A->A`; `x:A`] orbit_reflect)
   THEN POP_ASSUM (fun th1 -> (POP_ASSUM (fun th2 -> (MP_TAC (MATCH_MP lemma_card_atleast_one (CONJ th2 th1))))))
   THEN ASM_REWRITE_TAC[]
   THEN DISCH_TAC
   THEN MP_TAC (ARITH_RULE `(n:num) <= 2 /\ n >= 1 ==> n = 1 \/ n = 2`)
   THEN ASM_REWRITE_TAC[]
   THEN STRIP_TAC THENL[ASM_REWRITE_TAC[POWER_1]; ASM_REWRITE_TAC[POWER_2; o_THM]]);;

let lemma_convolution_map = prove(`!s:A->bool p:A->A. FINITE s /\ p permutes s ==> (p o p = I <=> !x:A. x IN s ==> CARD (orbit_map p x) <= 2)`,
   REPEAT GEN_TAC THEN DISCH_TAC THEN EQ_TAC
   THENL[DISCH_THEN (LABEL_TAC "F1") THEN REPEAT STRIP_TAC
      THEN REMOVE_THEN "F1" (fun th -> (MP_TAC (AP_THM th `x:A`)))
      THEN REWRITE_TAC[GSYM POWER_2; I_THM]
      THEN MP_TAC (SPECL[`p:A->A`; `2`; `x:A`] card_orbit_le)
      THEN REWRITE_TAC[ARITH_RULE `~(2 = 0)`]; ALL_TAC]
   THEN STRIP_TAC THEN REWRITE_TAC[FUN_EQ_THM; o_THM; I_THM]
   THEN GEN_TAC THEN ASM_CASES_TAC `x:A IN (s:A->bool)`
   THENL[FIRST_ASSUM (MP_TAC o SPEC `x:A` o  check (is_forall o concl)) 
      THEN POP_ASSUM (fun th -> REWRITE_TAC[th])
      THEN ASM_REWRITE_TAC[]
      THEN FIRST_ASSUM (MP_TAC o MATCH_MP  lemma_convolution_evaluation)
      THEN MESON_TAC[]; ALL_TAC]
   THEN FIND_ASSUM (MP_TAC o CONJUNCT2) `FINITE (s:A->bool) /\ (p:A->A) permutes s`
   THEN REWRITE_TAC[permutes]
   THEN DISCH_THEN (MP_TAC o SPEC `x:A` o CONJUNCT1)
   THEN ASM_REWRITE_TAC[]
   THEN DISCH_THEN ASSUME_TAC
   THEN ASM_REWRITE_TAC[]);;

let lemma_orbit_of_size_2 = prove(`!s:A->bool p:A->A. FINITE s /\ p permutes s ==> (CARD (orbit_map p x) = 2 <=> ~(p x = x) /\ (p (p x) = x))`,
     REPEAT GEN_TAC THEN DISCH_THEN (LABEL_TAC "F1") THEN EQ_TAC
     THENL[DISCH_THEN (LABEL_TAC "F2")
	     THEN USE_THEN "F1" (MP_TAC o SPEC `x:A` o MATCH_MP lemma_convolution_evaluation)
	     THEN USE_THEN "F2" (fun th -> REWRITE_TAC[MATCH_MP (ARITH_RULE `m:num = 2 ==> m <= 2`) th])
	     THEN DISCH_THEN (fun th -> REWRITE_TAC[th])
	     THEN ONCE_REWRITE_TAC[orbit_one_point]
	     THEN POP_ASSUM MP_TAC
	     THEN ONCE_REWRITE_TAC[GSYM CONTRAPOS_THM]
	     THEN REWRITE_TAC[]
	     THEN DISCH_THEN SUBST1_TAC
	     THEN REWRITE_TAC[CARD_SINGLETON]
	     THEN ARITH_TAC; ALL_TAC]
     THEN STRIP_TAC
     THEN USE_THEN "F1" (MP_TAC o SPEC `x:A` o MATCH_MP lemma_convolution_evaluation)
     THEN ASM_REWRITE_TAC[]
     THEN ASSUME_TAC (SPECL[`p:A->A`; `x:A`] orbit_reflect)
     THEN MP_TAC (SPECL[`p:A->A`; `1`; `x:A`] lemma_in_orbit)
     THEN REWRITE_TAC[POWER_1]
     THEN USE_THEN "F1" (ASSUME_TAC o SPEC `x:A` o MATCH_MP lemma_orbit_finite)
     THEN REPEAT STRIP_TAC
     THEN MP_TAC (SPECL[`orbit_map (p:A->A) (x:A)`; `x:A`; `(p:A->A) (x:A)`] CARD_ATLEAST_2)
     THEN ASM_REWRITE_TAC[]
     THEN POP_ASSUM MP_TAC
     THEN ARITH_TAC);;

let EDGE_OF_SIZE_2 = prove(`!(H:(A)hypermap) x:A. (CARD(edge H x) = 2 <=> ~(edge_map H x = x) /\ (edge_map H (edge_map H x) = x))`,
     REPEAT STRIP_TAC THEN REWRITE_TAC[edge] THEN MATCH_MP_TAC lemma_orbit_of_size_2
     THEN EXISTS_TAC `dart (H:(A)hypermap)` THEN REWRITE_TAC[SPEC `H:(A)hypermap` hypermap_lemma]);;

let NODE_OF_SIZE_2 = prove(`!(H:(A)hypermap) x:A. (CARD(node H x) = 2 <=> ~(node_map H x = x) /\ (node_map H (node_map H x) = x))`,
     REPEAT STRIP_TAC THEN REWRITE_TAC[node] THEN MATCH_MP_TAC lemma_orbit_of_size_2
     THEN EXISTS_TAC `dart (H:(A)hypermap)` THEN REWRITE_TAC[SPEC `H:(A)hypermap` hypermap_lemma]);;

let FACE_OF_SIZE_2 = prove(`!(H:(A)hypermap) x:A. (CARD(face H x) = 2 <=> ~(face_map H x = x) /\ (face_map H (face_map H x) = x))`,
     REPEAT STRIP_TAC THEN REWRITE_TAC[face] THEN MATCH_MP_TAC lemma_orbit_of_size_2
     THEN EXISTS_TAC `dart (H:(A)hypermap)` THEN REWRITE_TAC[SPEC `H:(A)hypermap` hypermap_lemma]);;

let lemma_sub_unions_diff = prove(`!s:(A->bool)->bool t:(A->bool)->bool. t SUBSET s ==> UNIONS s = (UNIONS (s DIFF t)) UNION  (UNIONS t)`,
    REPEAT STRIP_TAC THEN REWRITE_TAC[UNIONS; UNION; DIFF]
    THEN REWRITE_TAC[IN_ELIM_THM; EXTENSION] THEN GEN_TAC
    THEN EQ_TAC THENL[STRIP_TAC 
       THEN ASM_CASES_TAC `(u:A->bool) IN (t:(A->bool)->bool)`
       THENL[DISJ2_TAC THEN EXISTS_TAC `u:A->bool`
             THEN ASM_REWRITE_TAC[]; ALL_TAC]
       THEN DISJ1_TAC
       THEN EXISTS_TAC `u:A->bool`
       THEN ASM_REWRITE_TAC[]; ALL_TAC]
    THEN STRIP_TAC 
    THENL[EXISTS_TAC `u:A->bool` THEN ASM_REWRITE_TAC[]; ALL_TAC]
    THEN UNDISCH_TAC `t:(A->bool)->bool SUBSET s:(A->bool)->bool`
    THEN REWRITE_TAC[SUBSET]
    THEN DISCH_THEN (MP_TAC o SPEC `u:A->bool`)
    THEN ASM_REWRITE_TAC[]
    THEN DISCH_TAC
    THEN EXISTS_TAC `u:A->bool`
    THEN ASM_REWRITE_TAC[]);;

let lemma_card_unions_diff = prove(`!s:(A->bool)->bool t:(A->bool)->bool. t SUBSET s /\ FINITE (UNIONS s) /\ (!a:A->bool b:A->bool. a IN s /\ b IN s ==> a = b \/ a INTER b = {}) ==> CARD (UNIONS s) = CARD (UNIONS (s DIFF t)) + CARD (UNIONS t)`,
     REPEAT GEN_TAC
     THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F1") (CONJUNCTS_THEN2 (LABEL_TAC "F2") (LABEL_TAC "F3")))
     THEN USE_THEN "F1" (LABEL_TAC "F4" o MATCH_MP lemma_sub_unions_diff)
     THEN USE_THEN "F4" (fun th2-> (MP_TAC(MATCH_MP (SET_RULE `u = v UNION w ==> v SUBSET u /\ w SUBSET u`) th2 )))
     THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F5") (LABEL_TAC "F6"))
     THEN USE_THEN "F2" (fun th1 -> (USE_THEN "F5" (fun th2 -> (MP_TAC (MATCH_MP FINITE_SUBSET (CONJ th1 th2))))))
     THEN DISCH_THEN (LABEL_TAC "F7")
     THEN USE_THEN "F2" (fun th1 -> (USE_THEN "F6" (fun th2 -> (MP_TAC (MATCH_MP FINITE_SUBSET (CONJ th1 th2))))))
     THEN DISCH_THEN (LABEL_TAC "F8")
     THEN ASM_CASES_TAC `~(((UNIONS ((s:(A->bool)->bool) DIFF (t:(A->bool)->bool))) INTER (UNIONS t)) = {})`
     THENL[POP_ASSUM MP_TAC
	     THEN REWRITE_TAC[GSYM MEMBER_NOT_EMPTY]
	     THEN DISCH_THEN (X_CHOOSE_THEN `el:A` MP_TAC)
	     THEN GEN_REWRITE_TAC (LAND_CONV o DEPTH_CONV) [UNIONS; DIFF; IN_INTER]
	     THEN REWRITE_TAC[IN_ELIM_THM]
	     THEN STRIP_TAC
	     THEN USE_THEN "F1" MP_TAC
	     THEN REWRITE_TAC[SUBSET]
	     THEN DISCH_THEN (MP_TAC o (SPEC `u':A->bool`))
	     THEN ASM_REWRITE_TAC[]
	     THEN DISCH_TAC
	     THEN MP_TAC (SPECL[`u:A->bool`; `u':A->bool`; `el:A`] IN_INTER)
	     THEN ASM_REWRITE_TAC[]
	     THEN DISCH_THEN (MP_TAC o SIMPLE_EXISTS `el:A`)
	     THEN REWRITE_TAC[MEMBER_NOT_EMPTY]
	     THEN STRIP_TAC
	     THEN REMOVE_THEN "F3" (MP_TAC o SPECL[`u:A->bool`; `u':A->bool`])
	     THEN ASM_REWRITE_TAC[]
	     THEN DISCH_TAC
	     THEN UNDISCH_TAC `u':A->bool IN (t:(A->bool)->bool)`
	    THEN POP_ASSUM (SUBST1_TAC o SYM)
	    THEN ASM_REWRITE_TAC[]; ALL_TAC]
     THEN POP_ASSUM MP_TAC
     THEN REWRITE_TAC[]
     THEN DISCH_TAC
     THEN USE_THEN "F4" SUBST1_TAC
     THEN MATCH_MP_TAC CARD_UNION
     THEN ASM_REWRITE_TAC[]);;


let lemma_card_partion2_unions = prove(`!(H:(A)hypermap) (x:A) (y:A). x IN dart H /\ y IN dart H ==> CARD (dart H) = CARD(UNIONS (edge_set H DIFF {edge H x, edge H y})) + CARD(UNIONS {edge H x, edge H y})`,
     REPEAT GEN_TAC THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F1") (LABEL_TAC "F2"))
     THEN SUBGOAL_THEN `dart (H:(A)hypermap) = UNIONS (edge_set H)` (LABEL_TAC "F3")
     THENL[REWRITE_TAC[edge_set]
	     THEN MATCH_MP_TAC lemma_partition
	     THEN REWRITE_TAC[hypermap_lemma]; ALL_TAC]
     THEN SUBGOAL_THEN `FINITE (UNIONS (edge_set (H:(A)hypermap)))` ASSUME_TAC
     THENL[USE_THEN "F3" (SUBST1_TAC o SYM) THEN REWRITE_TAC[hypermap_lemma]; ALL_TAC]
     THEN REMOVE_THEN "F3" (SUBST1_TAC)
     THEN MATCH_MP_TAC lemma_card_unions_diff
     THEN ASM_REWRITE_TAC[]
     THEN REWRITE_TAC[SET_RULE `{u, v} SUBSET w <=> u IN w /\ v IN w`]
     THEN REWRITE_TAC[GSYM lemma_in_edge_set]
     THEN ASM_REWRITE_TAC[]
     THEN REWRITE_TAC[edge_set; IN_ELIM_THM]
     THEN ABBREV_TAC `D = dart (H:(A)hypermap)`
     THEN REPEAT GEN_TAC
     THEN REWRITE_TAC[set_of_orbits; IN_ELIM_THM]
     THEN STRIP_TAC
     THEN ASM_REWRITE_TAC[]
     THEN MP_TAC (MATCH_MP partition_orbit  (CONJ (CONJUNCT1 (SPEC `H:(A)hypermap` hypermap_lemma)) (CONJUNCT1(CONJUNCT2(SPEC `H:(A)hypermap` hypermap_lemma)))))
     THEN MESON_TAC[]);;

let CARD_UNION_EDGES_LE = prove(`!(H:(A)hypermap) (x:A) (y:A). CARD (edge H x UNION edge H y) <= CARD (edge H x) + CARD (edge H y)`,
   REPEAT GEN_TAC
   THEN MATCH_MP_TAC CARD_UNION_LE
   THEN REWRITE_TAC[EDGE_FINITE]);;

let lemma_card_partion2_unions_approx = prove(`!(H:(A)hypermap) (x:A) (y:A). x IN dart H /\ y IN dart H ==> CARD (dart H) <= CARD(UNIONS (edge_set H DIFF {edge H x, edge H y})) + CARD(edge H x) + CARD(edge H y)`,
     REPEAT GEN_TAC
     THEN DISCH_THEN (MP_TAC o MATCH_MP lemma_card_partion2_unions)
     THEN REWRITE_TAC[UNIONS_2]
     THEN DISCH_THEN SUBST1_TAC
     THEN REWRITE_TAC[ARITH_RULE `(m:num) + a <= m + b +c  <=> a <= b + c`]
     THEN MATCH_MP_TAC CARD_UNION_LE
     THEN REWRITE_TAC[edge]
     THEN label_hypermap4_TAC `H:(A)hypermap`
     THEN STRIP_TAC
     THENL[MATCH_MP_TAC lemma_orbit_finite
	  THEN EXISTS_TAC `dart (H:(A)hypermap)`
	  THEN ASM_REWRITE_TAC[]; ALL_TAC]
     THEN MATCH_MP_TAC lemma_orbit_finite
     THEN EXISTS_TAC `dart (H:(A)hypermap)`
     THEN ASM_REWRITE_TAC[]);;

let lemma_card_partion2_unions_eq = prove(`!(H:(A)hypermap) (x:A) (y:A). x IN dart H /\ y IN dart H /\ ~(edge H x = edge H y) ==> CARD (dart H) = CARD(UNIONS (edge_set H DIFF {edge H x, edge H y})) + CARD(edge H x) + CARD(edge H y)`,
   REPEAT GEN_TAC
   THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F1") (CONJUNCTS_THEN2 (LABEL_TAC "F2") (LABEL_TAC "F3")))
   THEN USE_THEN "F1" (fun th1 -> (USE_THEN "F2" (fun th2 -> (MP_TAC (MATCH_MP lemma_card_partion2_unions (CONJ th1 th2))))))
   THEN REWRITE_TAC[UNIONS_2]
   THEN DISCH_THEN SUBST1_TAC
   THEN REWRITE_TAC[ARITH_RULE `(m:num) + a = m + b +c  <=> a = b + c`]
   THEN CONV_TAC  SYM_CONV
   THEN MATCH_MP_TAC CARD_UNION_EQ
   THEN REWRITE_TAC[FINITE_UNION]
   THEN REWRITE_TAC[edge]
   THEN label_hypermap4_TAC `H:(A)hypermap`
   THEN STRIP_TAC
   THENL[STRIP_TAC
       THENL[MATCH_MP_TAC lemma_orbit_finite
	   THEN EXISTS_TAC `dart (H:(A)hypermap)`
	   THEN ASM_REWRITE_TAC[]; ALL_TAC]
       THEN MATCH_MP_TAC lemma_orbit_finite
       THEN EXISTS_TAC `dart (H:(A)hypermap)`
       THEN ASM_REWRITE_TAC[]; ALL_TAC]
   THEN USE_THEN "H1" (fun th1 -> (USE_THEN "H2" (fun th2 -> (MP_TAC (SPECL[`x:A`; `y:A`] (MATCH_MP partition_orbit (CONJ th1 th2)))))))
   THEN REWRITE_TAC[GSYM edge]
   THEN USE_THEN "F3" MP_TAC
   THEN MESON_TAC[]);;

let lemma_card_partion1_unions_eq =  prove(`!(H:(A)hypermap) (x:A). x IN dart H ==> CARD (dart H) = CARD(UNIONS (edge_set H DELETE (edge H x))) + CARD(edge H x)`,
   REPEAT STRIP_TAC
   THEN MP_TAC (SPECL[`H:(A)hypermap`; `x:A`; `x:A`] lemma_card_partion2_unions)
   THEN ASM_REWRITE_TAC[SET_RULE `{a,a} = {a} /\ (s DIFF {a} = s DELETE a)`; UNIONS_1]);;


let lemma_edge_representation = prove(`!(H:(A)hypermap) u:A->bool. u IN edge_set H ==> ?x:A. x IN dart H /\ u = edge H x`,
   REPEAT GEN_TAC THEN REWRITE_TAC[edge_set; set_of_orbits; IN_ELIM_THM]
   THEN REWRITE_TAC[GSYM edge]);;

let lemma_node_representation = prove(`!(H:(A)hypermap) u:A->bool. u IN node_set H ==> ?x:A. x IN dart H /\ u = node H x`,
   REPEAT GEN_TAC THEN REWRITE_TAC[node_set; set_of_orbits; IN_ELIM_THM]
   THEN REWRITE_TAC[GSYM node]);;

let lemma_face_representation = prove(`!(H:(A)hypermap) u:A->bool. u IN face_set H ==> ?x:A. x IN dart H /\ u = face H x`,
   REPEAT GEN_TAC THEN REWRITE_TAC[face_set; set_of_orbits; IN_ELIM_THM]
   THEN REWRITE_TAC[GSYM face]);;

let lemma_component_representation = prove(`!(H:(A)hypermap) u:A->bool. u IN set_of_components H ==> ?x:A. x IN dart H /\ u = comb_component H x`,
   REPEAT GEN_TAC THEN REWRITE_TAC[set_of_components; set_part_components; IN_ELIM_THM]
   THEN REWRITE_TAC[GSYM comb_component]);;

let lemma_edge_complement = prove(`!(H:(A)hypermap) x:A. x IN dart H ==> edge H x = dart H DIFF UNIONS (edge_set H DELETE edge H x)`,
   REPEAT GEN_TAC THEN DISCH_THEN (LABEL_TAC "F1")
     THEN REWRITE_TAC[EXTENSION]
     THEN GEN_TAC
     THEN EQ_TAC
     THENL[DISCH_THEN (LABEL_TAC "F2")
	THEN REWRITE_TAC[IN_DIFF; IN_UNIONS; IN_DELETE]
	THEN MP_TAC (SPEC `x:A` (MATCH_MP orbit_subset (CONJUNCT1(CONJUNCT2 (SPEC `H:(A)hypermap` hypermap_lemma)))))
	THEN ASM_REWRITE_TAC[GSYM edge]
	THEN REWRITE_TAC[SUBSET]
	THEN DISCH_THEN (MP_TAC o SPEC `x':A`)
	THEN ASM_REWRITE_TAC[]
	THEN DISCH_THEN (fun th -> (LABEL_TAC "F3" th THEN REWRITE_TAC[th]))
	THEN STRIP_TAC
	THEN FIRST_X_ASSUM (MP_TAC o check (is_neg o concl))
	THEN REWRITE_TAC[]
	THEN REMOVE_THEN "F2" (MP_TAC o MATCH_MP lemma_edge_identity)
	THEN DISCH_THEN SUBST1_TAC
	THEN FIRST_X_ASSUM (MP_TAC o MATCH_MP lemma_edge_representation)
	THEN DISCH_THEN (X_CHOOSE_THEN `y:A` MP_TAC)
	THEN DISCH_THEN (SUBST_ALL_TAC o CONJUNCT2)
	THEN POP_ASSUM (MP_TAC o MATCH_MP lemma_edge_identity)
	THEN SIMP_TAC[]; ALL_TAC]
     THEN REWRITE_TAC[UNIONS; IN_DIFF; IN_ELIM_THM; IN_DELETE]
     THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F2") (LABEL_TAC "F3"))
     THEN ASM_CASES_TAC `x':A IN edge (H:(A)hypermap) (x:A)`
     THENL[ASM_REWRITE_TAC[]; ALL_TAC]
     THEN ASM_REWRITE_TAC[]
     THEN REMOVE_THEN "F3" MP_TAC
     THEN REWRITE_TAC[]
     THEN EXISTS_TAC `edge (H:(A)hypermap) (x':A)`
     THEN USE_THEN "F2" MP_TAC
     THEN REWRITE_TAC[lemma_in_edge_set]
     THEN DISCH_THEN (fun th -> REWRITE_TAC[th])
     THEN MP_TAC (SPECL[`edge_map (H:(A)hypermap)`; `x':A`] orbit_reflect)
     THEN REWRITE_TAC[GSYM edge]
     THEN DISCH_THEN (LABEL_TAC "F3")
     THEN USE_THEN "F3" (fun th -> REWRITE_TAC[th])
     THEN FIRST_X_ASSUM (MP_TAC o check (is_neg o concl))
     THEN REWRITE_TAC[CONTRAPOS_THM]
     THEN DISCH_THEN (SUBST1_TAC o SYM)
     THEN POP_ASSUM (fun th-> REWRITE_TAC[th]));;

let map_permutes_outside_domain = prove(`!s:A->bool p:A->A. p permutes s ==> (!x:A. ~(x IN s) ==> p x = x)`,
     MESON_TAC[permutes]);;

let power_permutation_outside_domain = prove(`!s:A->bool p:A->A x:A n:num. p permutes s /\ ~(x IN s) ==> (p POWER n) x = x`, 
    REPEAT STRIP_TAC
    THEN SPEC_TAC(`n:num`, `n:num`)
    THEN INDUCT_TAC
    THENL[REWRITE_TAC[POWER_0; I_THM]; ALL_TAC]
    THEN REWRITE_TAC[COM_POWER; o_THM]
    THEN POP_ASSUM SUBST1_TAC
    THEN POP_ASSUM MP_TAC
    THEN POP_ASSUM (fun th-> REWRITE_TAC[MATCH_MP map_permutes_outside_domain th]));;

let lemma_edge_exception = prove(`!(H:(A)hypermap) (x:A). ~(x IN dart H) ==> edge H x = {x}`,
     REPEAT STRIP_TAC
     THEN MP_TAC (SPEC `x:A` (MATCH_MP map_permutes_outside_domain (CONJUNCT1(CONJUNCT2(SPEC `H:(A)hypermap` hypermap_lemma)))))
     THEN ASM_REWRITE_TAC[edge]
     THEN MESON_TAC[orbit_one_point]);;



(* DOUBLE EDGE WALKUP ALONG A NODE OF SIZE 2 CARRING A PLAIN HYPERMAP TO A PLAIN ONE *)

let double_edge_walkup_plain_hypermap = prove(`!(H:(A)hypermap) (x:A).x IN dart H /\ plain_hypermap H /\ CARD (node H x) = 2 ==> plain_hypermap (double_edge_walkup H x (node_map H x))`,
   REPEAT GEN_TAC
     THEN GEN_REWRITE_TAC (LAND_CONV o TOP_DEPTH_CONV) [plain_hypermap]
     THEN MP_TAC (SPECL[`dart (H:(A)hypermap)`; `edge_map (H:(A)hypermap)`] lemma_convolution_map)
     THEN REWRITE_TAC[hypermap_lemma]
     THEN DISCH_THEN (fun th -> REWRITE_TAC[th])
     THEN REWRITE_TAC[NODE_OF_SIZE_2]
     THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F1") (CONJUNCTS_THEN2 (LABEL_TAC "F2") (CONJUNCTS_THEN2 (LABEL_TAC "F3") (LABEL_TAC "F4"))))
     THEN ABBREV_TAC `y = node_map (H:(A)hypermap) (x:A)`
     THEN POP_ASSUM (LABEL_TAC "F5")
     THEN MP_TAC (SPECL[`dart (H:(A)hypermap)`; `node_map (H:(A)hypermap)`; `x:A`; `y:A`] inverse_function)
     THEN ASM_REWRITE_TAC[hypermap_lemma]
     THEN USE_THEN "F4" (SUBST1_TAC o SYM)
     THEN DISCH_THEN (LABEL_TAC "F6" o SYM)
     THEN MP_TAC (SPECL[`dart (H:(A)hypermap)`; `node_map (H:(A)hypermap)`; `y:A`; `x:A`] inverse_function)
     THEN ASM_REWRITE_TAC[hypermap_lemma]
     THEN USE_THEN "F4" (fun th -> REWRITE_TAC[th])
     THEN DISCH_THEN (LABEL_TAC "F7" o SYM)
     THEN USE_THEN "F1" (MP_TAC o MATCH_MP lemma_walkup_edges)
     THEN ASM_REWRITE_TAC[]
     THEN DISCH_THEN (LABEL_TAC "F8")
     THEN ABBREV_TAC `G = edge_walkup  (H:(A)hypermap) (x:A)`
     THEN MP_TAC (SPECL[`H:(A)hypermap`; `x:A`] lemma_node_map_walkup_in_dart)
     THEN ASM_REWRITE_TAC[]
     THEN DISCH_THEN (LABEL_TAC "F9")
     THEN MP_TAC (CONJUNCT1(CONJUNCT2(SPECL[`H:(A)hypermap`; `x:A`; `y:A`] node_map_walkup)))
     THEN ASM_REWRITE_TAC[]
     THEN DISCH_THEN (LABEL_TAC "F10")
     THEN USE_THEN "F9" (MP_TAC o MATCH_MP lemma_walkup_edges)
     THEN ASM_REWRITE_TAC[SET_RULE `{a,a} = {a} /\ s DIFF {a} = s DELETE a`]
     THEN ABBREV_TAC `W = edge_walkup (G:(A)hypermap) (y:A)`
     THEN DISCH_THEN (LABEL_TAC "F11")
     THEN SUBGOAL_THEN `~(edge (W:(A)hypermap) (y:A) IN edge_set W)` (LABEL_TAC "F12")
     THENL[REWRITE_TAC[GSYM lemma_in_edge_set]
	     THEN EXPAND_TAC "W"
	     THEN MP_TAC (CONJUNCT1(SPECL[`G:(A)hypermap`; `y:A`] lemma_edge_walkup))
	     THEN DISCH_THEN SUBST1_TAC
	     THEN REWRITE_TAC[IN_DELETE]; ALL_TAC]
     THEN REMOVE_THEN "F11" MP_TAC
     THEN REWRITE_TAC[SET_RULE `s DIFF {a,b} = (s DELETE a) DELETE b`]
     THEN USE_THEN "F12" (MP_TAC o MATCH_MP (SET_RULE `~(a IN s) ==> s DELETE a = s`))
     THEN DISCH_THEN SUBST1_TAC
     THEN DISCH_THEN (LABEL_TAC "F14")
     THEN MP_TAC (CONJUNCT1 (SPECL[`G:(A)hypermap`; `y:A`] lemma_edge_walkup))
     THEN FIND_ASSUM (fun th -> REWRITE_TAC[th]) `edge_walkup (G:(A)hypermap) (y:A) = W`
     THEN DISCH_THEN (LABEL_TAC "F15")
     THEN SUBGOAL_THEN `~(y:A IN dart (W:(A)hypermap))` (LABEL_TAC "F16")
     THEN USE_THEN "F15" SUBST1_TAC
     THEN REWRITE_TAC[IN_DELETE]
     THEN USE_THEN "F1" (MP_TAC o CONJUNCT1 o CONJUNCT2 o MATCH_MP lemma_dart_invariant)
     THEN USE_THEN "F5" (fun th -> REWRITE_TAC[th])
     THEN DISCH_THEN (LABEL_TAC "F17")
     THEN ASM_CASES_TAC `(inverse (edge_map (H:(A)hypermap)) (x:A)) = x \/ edge (G:(A)hypermap) (y:A) = edge G (inverse (edge_map H) x)`
    THENL[SUBGOAL_THEN `edge_set (G:(A)hypermap) DIFF {edge G (y:A), edge G (inverse (edge_map (H:(A)hypermap)) (x:A))} = edge_set G DELETE (edge G y)` ASSUME_TAC
	THENL[POP_ASSUM MP_TAC THEN STRIP_TAC
		THENL[REWRITE_TAC[SET_RULE `s DIFF {a,b} = (s DELETE b) DELETE a`]
			THEN POP_ASSUM SUBST1_TAC
			THEN MP_TAC (ISPECL[`edge (G:(A)hypermap) (x:A)`; `edge_set (G:(A)hypermap)`] DELETE_NON_ELEMENT)
			THEN REWRITE_TAC[GSYM lemma_in_edge_set]
			THEN REWRITE_TAC[lemma_edge_walkup]
			THEN MP_TAC (CONJUNCT1 (SPECL[`H:(A)hypermap`; `x:A`] lemma_edge_walkup))
			THEN FIND_ASSUM SUBST1_TAC `edge_walkup (H:(A)hypermap) (x:A) = G`
		        THEN DISCH_THEN SUBST1_TAC
			THEN REWRITE_TAC[IN_DELETE]
			THEN DISCH_THEN SUBST1_TAC
			THEN SIMP_TAC[]; ALL_TAC]
		THEN POP_ASSUM (SUBST1_TAC o SYM)
		THEN REWRITE_TAC[SET_RULE `s DIFF {a,a} = s DELETE a`]; ALL_TAC]
	THEN REMOVE_THEN "F8" MP_TAC
	THEN POP_ASSUM  SUBST1_TAC
	THEN DISCH_THEN (LABEL_TAC "K1")	
        THEN SUBGOAL_THEN `CARD (edge (G:(A)hypermap) (y:A)) <= 3` (LABEL_TAC "K2")
	THENL[USE_THEN "F1" (fun th1 -> (USE_THEN "F17" (fun th2 -> (MP_TAC (MATCH_MP lemma_card_partion2_unions (CONJ th1 th2))))))
		THEN USE_THEN "F1" (MP_TAC o MATCH_MP lemma_card_walkup_dart)
		THEN FIND_ASSUM (fun th-> REWRITE_TAC[th]) `edge_walkup (H:(A)hypermap) (x:A) = G`
	        THEN DISCH_THEN  SUBST1_TAC
		THEN USE_THEN "K1" SUBST1_TAC
		THEN USE_THEN "F9" (MP_TAC o MATCH_MP lemma_card_partion1_unions_eq)
		THEN DISCH_THEN SUBST1_TAC
		THEN REWRITE_TAC[ARITH_RULE `((m:num)+n) +1 = m + k <=> n+1 = k`; UNIONS_2]
		THEN DISCH_THEN (fun th -> (MP_TAC (MATCH_MP (ARITH_RULE `(a:num) = b /\ b <= c ==> a <= c`) (CONJ th (SPECL[`H:(A)hypermap`; `x:A`; `y:A`] CARD_UNION_EDGES_LE)))))
		THEN USE_THEN "F2" (MP_TAC o SPEC `x:A`)
		THEN USE_THEN "F2" (MP_TAC o SPEC `y:A`)
		THEN USE_THEN "F1" (fun th-> REWRITE_TAC[th])
		THEN USE_THEN "F17" (fun th-> REWRITE_TAC[th])
		THEN REWRITE_TAC[IMP_IMP; GSYM CONJ_ASSOC]
		THEN REWRITE_TAC[GSYM edge]
		THEN DISCH_THEN (MP_TAC o MATCH_MP (ARITH_RULE `(a:num) <= 2 /\ (b:num) <= 2 /\ (c:num) + 1 <= b + a ==> c <= 3`))
		THEN SIMP_TAC[]; ALL_TAC]
	THEN SUBGOAL_THEN `CARD (edge (W:(A)hypermap) (inverse (edge_map (G:(A)hypermap)) (y:A))) <= 2` (LABEL_TAC "K3")
	THENL[ASM_CASES_TAC `inverse (edge_map (G:(A)hypermap)) (y:A) = y`
	    THENL[POP_ASSUM SUBST1_TAC
		    THEN USE_THEN "F16" (MP_TAC o MATCH_MP lemma_edge_exception)
		    THEN DISCH_THEN SUBST1_TAC
		    THEN REWRITE_TAC[CARD_SINGLETON]
		    THEN ARITH_TAC; ALL_TAC]
	    THEN MP_TAC (SPEC `y:A` (MATCH_MP non_fixed_point_lemma (CONJUNCT1(CONJUNCT2(SPEC `G:(A)hypermap` hypermap_lemma)))))
	    THEN POP_ASSUM (fun th -> ((LABEL_TAC "K4" th) THEN REWRITE_TAC[th]))
	    THEN USE_THEN "F9" (fun th1 -> (DISCH_THEN (fun th2 -> (MP_TAC (CONJUNCT2(MATCH_MP lemma_edge_map_walkup_in_dart (CONJ th1 th2)))))))
	    THEN FIND_ASSUM SUBST1_TAC `edge_walkup (G:(A)hypermap) (y:A) = W`
	    THEN DISCH_THEN (LABEL_TAC "K5")
	    THEN USE_THEN "F9" (MP_TAC o MATCH_MP lemma_card_partion1_unions_eq)
	    THEN USE_THEN "F14" SUBST1_TAC
	    THEN USE_THEN "F9" (MP_TAC o MATCH_MP lemma_card_walkup_dart)
	    THEN FIND_ASSUM (fun th-> REWRITE_TAC[th]) `edge_walkup (G:(A)hypermap) (y:A) = W`
	    THEN DISCH_THEN  SUBST1_TAC
	    THEN USE_THEN "K5" (MP_TAC o MATCH_MP lemma_card_partion1_unions_eq)
	    THEN DISCH_THEN SUBST1_TAC
	    THEN REWRITE_TAC[ARITH_RULE `((m:num)+n) +1 = m + k <=> n+1 = k`]
	    THEN USE_THEN "K2" (fun th1 -> (DISCH_THEN (fun th2 -> (MP_TAC (MATCH_MP (ARITH_RULE `((a:num) <= 3 /\ (b:num) + 1 = a) ==> b <=2`) (CONJ th1 th2))))))
	    THEN SIMP_TAC[]; ALL_TAC]
	THEN ASM_REWRITE_TAC[plain_hypermap; double_edge_walkup]
	THEN MP_TAC (SPECL[`dart (W:(A)hypermap)`; `edge_map (W:(A)hypermap)`] lemma_convolution_map)
	THEN REWRITE_TAC[hypermap_lemma]
	THEN DISCH_THEN (fun th -> REWRITE_TAC[th])
	THEN REWRITE_TAC[GSYM edge]
	THEN GEN_TAC
	THEN ASM_CASES_TAC `edge (W:(A)hypermap) (x':A) = edge W (inverse (edge_map (G:(A)hypermap)) (y:A))`
	THENL[POP_ASSUM SUBST1_TAC
		THEN USE_THEN "K3" (fun th -> REWRITE_TAC[th]); ALL_TAC]

	THEN POP_ASSUM (LABEL_TAC "K10")
	THEN DISCH_THEN (fun th -> (LABEL_TAC "K11" th  THEN MP_TAC th))
	THEN REWRITE_TAC[lemma_in_edge_set]
	THEN DISCH_THEN (LABEL_TAC "K12")
	THEN MP_TAC (ISPECL[`edge_set (W:(A)hypermap)`; `edge (W:(A)hypermap) (x':A)`; `edge (W:(A)hypermap) (inverse (edge_map (G:(A)hypermap)) (y:A))` ] IN_DELETE)
	THEN USE_THEN "K12" (fun th -> REWRITE_TAC[th])
	THEN USE_THEN "K10" (fun th -> REWRITE_TAC[th])
	THEN USE_THEN "F14" (SUBST1_TAC o SYM)
	THEN USE_THEN "K1" (SUBST1_TAC o SYM)
	THEN ABBREV_TAC `E = edge (W:(A)hypermap) (x':A)`
	THEN REWRITE_TAC[IN_DIFF]
	THEN DISCH_THEN (fun th -> (MP_TAC (MATCH_MP lemma_edge_representation (CONJUNCT1 th))))
	THEN STRIP_TAC
	THEN USE_THEN "F2" (MP_TAC o SPEC `x'':A`)
	THEN REWRITE_TAC[GSYM edge]
	THEN POP_ASSUM (SUBST1_TAC o SYM)
	THEN POP_ASSUM (fun th -> REWRITE_TAC[th]);ALL_TAC]
    THEN POP_ASSUM MP_TAC
     THEN REWRITE_TAC[DE_MORGAN_THM]
     THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "J1") (LABEL_TAC "J2"))
     THEN USE_THEN "F1" (MP_TAC o CONJUNCT1 o MATCH_MP lemma_dart_inveriant_under_inverse_maps)
     THEN USE_THEN "F1" (fun th1 -> USE_THEN "J1" (fun th2 -> (DISCH_THEN (fun th3 -> (MP_TAC (MATCH_MP lemma_in_walkup_dart (CONJ th1 (CONJ th3 th2))))))))
     THEN FIND_ASSUM SUBST1_TAC `edge_walkup (H:(A)hypermap) (x:A) = G`
     THEN DISCH_THEN (fun th -> (MP_TAC th THEN (LABEL_TAC "J3" th)))
     THEN REWRITE_TAC[lemma_in_edge_set]
     THEN DISCH_THEN (LABEL_TAC "J4")
     THEN ABBREV_TAC `u = inverse (edge_map (H:(A)hypermap)) (x:A)`
     THEN USE_THEN "F1" (fun th1 -> (USE_THEN "F17" (fun th2 -> (MP_TAC (MATCH_MP lemma_card_partion2_unions_approx (CONJ th1 th2))))))
     THEN USE_THEN "F1" (MP_TAC o MATCH_MP lemma_card_walkup_dart)
     THEN FIND_ASSUM (fun th-> REWRITE_TAC[th]) `edge_walkup (H:(A)hypermap) (x:A) = G`
     THEN DISCH_THEN  SUBST1_TAC
     THEN USE_THEN "F9" (fun th1 -> (USE_THEN "J3" (fun th2 -> (USE_THEN "J2" (fun th3 -> (MP_TAC (MATCH_MP lemma_card_partion2_unions_eq (CONJ th1 (CONJ th2 th3)))))))))
     THEN DISCH_THEN SUBST1_TAC
     THEN USE_THEN "F8" (SUBST1_TAC)
     THEN REWRITE_TAC[ARITH_RULE  `((m:num)+n+k) + 1 <= m + a + b <=> n+k+1 <= a+b`]
     THEN USE_THEN "F2" (MP_TAC o SPEC `x:A`)
     THEN USE_THEN "F1" (fun th -> REWRITE_TAC[th])
     THEN USE_THEN "F2" (MP_TAC o SPEC `y:A`)
     THEN USE_THEN "F17" (fun th -> REWRITE_TAC[th])
     THEN REWRITE_TAC[IMP_IMP; GSYM CONJ_ASSOC]
     THEN REWRITE_TAC[GSYM edge]
     THEN DISCH_THEN (fun th -> (MP_TAC (MATCH_MP (ARITH_RULE `b:num <= 2 /\ a:num <= 2 /\ (m:num) + (n:num) + 1 <=a + b ==> m +n <= 3`) th)))
     THEN MP_TAC (SPECL[`G:(A)hypermap`; `y:A`] EDGE_NOT_EMPTY)
     THEN MP_TAC (SPECL[`G:(A)hypermap`; `u:A`] EDGE_NOT_EMPTY)
     THEN REWRITE_TAC[IMP_IMP; GSYM CONJ_ASSOC]
     THEN DISCH_THEN (MP_TAC o MATCH_MP (ARITH_RULE `1 <= n:num /\ 1 <= m:num /\ m + n <= 3 ==> m <=2 /\ n <=2`))
     THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "J5") (LABEL_TAC "J6"))
     THEN SUBGOAL_THEN `CARD (edge (W:(A)hypermap) (inverse (edge_map (G:(A)hypermap)) (y:A))) <= 2` (LABEL_TAC "J6a")
     THENL[ASM_CASES_TAC `inverse (edge_map (G:(A)hypermap)) (y:A) = y`
	 THENL[POP_ASSUM SUBST1_TAC 
		 THEN MP_TAC (CONJUNCT1(SPECL[`G:(A)hypermap`; `y:A`; `y:A`] edge_map_walkup))
		 THEN FIND_ASSUM SUBST1_TAC `edge_walkup (G:(A)hypermap) (y:A) = W`
	     THEN MP_TAC (SPECL[`edge_map (W:(A)hypermap)`; `y:A`] orbit_one_point)
	     THEN REWRITE_TAC[GSYM edge]
	     THEN DISCH_THEN (fun th -> REWRITE_TAC[th])
	     THEN DISCH_THEN SUBST1_TAC
	     THEN REWRITE_TAC[CARD_SINGLETON]
	     THEN ARITH_TAC; ALL_TAC]
	 THEN POP_ASSUM (LABEL_TAC "J7")
	 THEN MP_TAC (SPEC `y:A` (MATCH_MP non_fixed_point_lemma (CONJUNCT1(CONJUNCT2(SPEC `G:(A)hypermap` hypermap_lemma)))))
	 THEN USE_THEN "J7" (fun th -> REWRITE_TAC[th])
	 THEN USE_THEN "F9" (fun th1 -> (DISCH_THEN (fun th2 -> (MP_TAC (CONJUNCT2(MATCH_MP lemma_edge_map_walkup_in_dart (CONJ th1 th2)))))))
	 THEN FIND_ASSUM SUBST1_TAC `edge_walkup (G:(A)hypermap) (y:A) = W`
	 THEN DISCH_THEN (LABEL_TAC "J8")
	 THEN USE_THEN "F9" (MP_TAC o MATCH_MP lemma_card_partion1_unions_eq)
	 THEN (USE_THEN "F9" (MP_TAC o MATCH_MP lemma_card_walkup_dart))
	 THEN FIND_ASSUM (fun th-> REWRITE_TAC[th]) `edge_walkup (G:(A)hypermap) (y:A) = W`
	 THEN DISCH_THEN  SUBST1_TAC
	 THEN USE_THEN "F14" SUBST1_TAC
	 THEN USE_THEN "J8" (MP_TAC o MATCH_MP lemma_card_partion1_unions_eq)
	 THEN DISCH_THEN SUBST1_TAC
	 THEN REWRITE_TAC[ARITH_RULE `((m:num)+n) +1 = m + k <=> n+1 = k`]
	 THEN USE_THEN "J5" MP_TAC
	 THEN REWRITE_TAC[IMP_IMP]
	 THEN DISCH_THEN (MP_TAC o MATCH_MP (ARITH_RULE `a:num <= 2 /\ (m:num) + 1 = a ==> m <= 2`))
	 THEN SIMP_TAC[]; ALL_TAC]
     THEN ABBREV_TAC `v = inverse (edge_map (G:(A)hypermap)) (y:A)`
    THEN ASM_REWRITE_TAC[plain_hypermap; double_edge_walkup]
    THEN  MP_TAC (SPECL[`dart (W:(A)hypermap)`; `edge_map (W:(A)hypermap)`] lemma_convolution_map)
    THEN  REWRITE_TAC[hypermap_lemma]
    THEN  DISCH_THEN (fun th -> REWRITE_TAC[th])
    THEN  REWRITE_TAC[GSYM edge]
    THEN  GEN_TAC
    THEN  ASM_CASES_TAC `edge (W:(A)hypermap) (x':A) = edge W (v:A)`
    THENL[POP_ASSUM SUBST1_TAC THEN USE_THEN "J6a" (fun th -> REWRITE_TAC[th]); ALL_TAC]
    THEN  POP_ASSUM (LABEL_TAC "J16")
    THEN  DISCH_THEN (fun th -> (LABEL_TAC "J17" th  THEN MP_TAC th))
    THEN  REWRITE_TAC[lemma_in_edge_set]
    THEN  DISCH_THEN (LABEL_TAC "J18")
    THEN  MP_TAC (ISPECL[`edge_set (W:(A)hypermap)`; `edge (W:(A)hypermap) (x':A)`; `edge (W:(A)hypermap) (v:A)` ] IN_DELETE)
    THEN  USE_THEN "J18" (fun th -> REWRITE_TAC[th])
    THEN  USE_THEN "J16" (fun th -> REWRITE_TAC[th])
    THEN  USE_THEN "F14" (SUBST1_TAC o SYM)
    THEN  ASM_CASES_TAC `edge (W:(A)hypermap) (x':A) = edge (G:(A)hypermap) (u:A)`
    THENL[POP_ASSUM SUBST1_TAC
	THEN USE_THEN "J6" (fun th -> REWRITE_TAC[th]); ALL_TAC]
    THEN DISCH_THEN (fun th -> (POP_ASSUM (fun th2 -> (MP_TAC (MATCH_MP (SET_RULE `~(a = b) /\ a IN (s DELETE c) ==> a IN (s DIFF {c, b})`) (CONJ th2 th))))))
    THEN  USE_THEN "F8" (SUBST1_TAC o SYM)
    THEN  ABBREV_TAC `ED = edge (W:(A)hypermap) (x':A)`
    THEN REWRITE_TAC[IN_DIFF]
    THEN DISCH_THEN (fun th -> (MP_TAC (MATCH_MP lemma_edge_representation (CONJUNCT1 th))))
    THEN STRIP_TAC
    THEN USE_THEN "F2" (MP_TAC o SPEC `x'':A`)
    THEN REWRITE_TAC[GSYM edge]
    THEN POP_ASSUM (SUBST1_TAC o SYM)
    THEN POP_ASSUM (fun th -> REWRITE_TAC[th]));;

let lemma_representaion_Wn = prove(`!(H:(A)hypermap) (x:A) (y:A). double_node_walkup H x y = shift(shift(double_edge_walkup (shift H) x y))`,
    REPEAT GEN_TAC THEN REWRITE_TAC[double_node_walkup; node_walkup; double_edge_walkup]
    THEN REWRITE_TAC[lemma_shift_cycle]);;

let lemma_representaion_Wf = prove(`!(H:(A)hypermap) (x:A) (y:A). double_face_walkup H x y = shift(double_edge_walkup (shift(shift H)) x y)`,
    REPEAT GEN_TAC THEN REWRITE_TAC[double_face_walkup; face_walkup; double_edge_walkup]
    THEN REWRITE_TAC[lemma_shift_cycle]);;


let double_node_walkup_plain_hypermap = prove(`!(H:(A)hypermap) (x:A).x IN dart H /\ plain_hypermap H /\ CARD (edge H x) = 2 ==> plain_hypermap (double_node_walkup H x (edge_map H x))`,
   REPEAT GEN_TAC
   THEN REWRITE_TAC[lemma_representaion_Wn]
   THEN REWRITE_TAC[plain_hypermap]
   THEN ABBREV_TAC `G = shift (H:(A)hypermap)`
   THEN REWRITE_TAC[GSYM shift_lemma]
   THEN MP_TAC (CONJUNCT1(SPEC `H:(A)hypermap` shift_lemma))
   THEN DISCH_THEN SUBST1_TAC
   THEN REWRITE_TAC[edge]
   THEN MP_TAC (CONJUNCT1(CONJUNCT2(SPEC `H:(A)hypermap` shift_lemma)))
   THEN DISCH_THEN SUBST1_TAC
   THEN ASM_REWRITE_TAC[]
   THEN REWRITE_TAC[GSYM face]
   THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F1") (CONJUNCTS_THEN2 (LABEL_TAC "F2") (LABEL_TAC "F3")))
   THEN MP_TAC (SPECL[`dart (G:(A)hypermap)`; `face_map (G:(A)hypermap)`] lemma_convolution_map)
   THEN ASM_REWRITE_TAC[hypermap_lemma; GSYM face]
   THEN DISCH_THEN (LABEL_TAC "F4")
   THEN REMOVE_THEN "F3" MP_TAC
   THEN REWRITE_TAC[FACE_OF_SIZE_2]
   THEN ABBREV_TAC `y = face_map (G:(A)hypermap) (x:A)`
   THEN POP_ASSUM (LABEL_TAC "J0")
   THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F5") (LABEL_TAC "F6"))
   THEN USE_THEN "F1" (MP_TAC o MATCH_MP lemma_walkup_faces)
   THEN ABBREV_TAC `J = edge_walkup (G:(A)hypermap) (x:A)`
   THEN POP_ASSUM (LABEL_TAC "J1")
   THEN USE_THEN "F6" (fun th -> (MP_TAC (MATCH_MP inverse_function (CONJ (CONJUNCT1(CONJUNCT2(CONJUNCT2(CONJUNCT2(SPEC `G:(A)hypermap` hypermap_lemma))))) th))))
   THEN DISCH_THEN (fun th -> (LABEL_TAC "J2" (SYM th) THEN (SUBST1_TAC (SYM th))))
   THEN DISCH_THEN (LABEL_TAC "F7")
   THEN USE_THEN "F5" MP_TAC
   THEN USE_THEN "F1" (MP_TAC o CONJUNCT2 o CONJUNCT2 o MATCH_MP lemma_dart_invariant)
   THEN USE_THEN "F5" (fun th -> REWRITE_TAC[th])
   THEN USE_THEN "J0" (fun th -> REWRITE_TAC[th])
   THEN DISCH_THEN (LABEL_TAC "F8")
   THEN USE_THEN "F1" (fun th1 -> (USE_THEN "F8" (fun th2 -> (USE_THEN "F5" (fun th3 -> (MP_TAC (MATCH_MP lemma_in_walkup_dart (CONJ th1 (CONJ th2 th3)))))))))
   THEN USE_THEN "J1" (fun th->REWRITE_TAC[th])
   THEN DISCH_THEN (LABEL_TAC "F9")
   THEN USE_THEN "F9" (MP_TAC o MATCH_MP lemma_walkup_faces)
   THEN MP_TAC (CONJUNCT1(CONJUNCT2(SPECL[`G:(A)hypermap`; `x:A`; `x:A`] face_map_walkup)))
   THEN ASM_REWRITE_TAC[]
   THEN DISCH_THEN (fun th -> (MP_TAC (MATCH_MP inverse_function (CONJ (CONJUNCT1(CONJUNCT2(CONJUNCT2(CONJUNCT2(SPEC `J:(A)hypermap` hypermap_lemma))))) th))))
   THEN DISCH_THEN (SUBST1_TAC o SYM)
   THEN ABBREV_TAC `W = edge_walkup (J:(A)hypermap) (y:A)`
   THEN SUBGOAL_THEN `~(face (W:(A)hypermap) (y:A) IN face_set W)` ASSUME_TAC
   THENL[REWRITE_TAC[GSYM lemma_in_face_set]
	   THEN EXPAND_TAC "W"
	   THEN REWRITE_TAC[lemma_edge_walkup]
	   THEN REWRITE_TAC[IN_DELETE]; ALL_TAC]
  THEN POP_ASSUM (MP_TAC o MATCH_MP (SET_RULE `~(a IN s) ==> (s DELETE a = s)`))
  THEN DISCH_THEN SUBST1_TAC
  THEN REMOVE_THEN "F7" (SUBST1_TAC o SYM)
  THEN DISCH_THEN (LABEL_TAC "F10" o SYM)
  THEN REWRITE_TAC[double_edge_walkup]
  THEN USE_THEN "J1" (fun th -> REWRITE_TAC[th])
  THEN FIND_ASSUM (fun th -> REWRITE_TAC[th]) `edge_walkup (J:(A)hypermap) (y:A) = W`
  THEN MP_TAC (SPECL[`dart (W:(A)hypermap)`; `face_map (W:(A)hypermap)`] lemma_convolution_map)
  THEN REWRITE_TAC[hypermap_lemma]
  THEN DISCH_THEN (fun th -> REWRITE_TAC[th])
  THEN REWRITE_TAC[GSYM face]
  THEN GEN_TAC
  THEN REWRITE_TAC[lemma_in_face_set]
  THEN POP_ASSUM SUBST1_TAC
  THEN REWRITE_TAC[IN_DELETE]
  THEN ABBREV_TAC `FF = face (W:(A)hypermap) (x':A)`
  THEN DISCH_THEN (fun th -> (MP_TAC (MATCH_MP lemma_face_representation (CONJUNCT1 th))))
  THEN REPEAT STRIP_TAC
  THEN REMOVE_THEN "F4" (MP_TAC o SPEC `x'':A`)
  THEN ASM_REWRITE_TAC[]);;

let double_face_walkup_plain_hypermap = prove(`!(H:(A)hypermap) (x:A).x IN dart H /\ plain_hypermap H /\ CARD (edge H x) = 2 ==> plain_hypermap (double_face_walkup H x (edge_map H x))`,
   REPEAT GEN_TAC
   THEN REWRITE_TAC[lemma_representaion_Wf]
   THEN REWRITE_TAC[plain_hypermap]
   THEN ABBREV_TAC `G = shift(shift (H:(A)hypermap))`
   THEN REWRITE_TAC[GSYM shift_lemma]
   THEN MP_TAC (CONJUNCT1(SPEC `H:(A)hypermap` double_shift_lemma))
   THEN DISCH_THEN SUBST1_TAC
   THEN REWRITE_TAC[edge]
   THEN MP_TAC (CONJUNCT1(CONJUNCT2(SPEC `H:(A)hypermap` double_shift_lemma)))
   THEN DISCH_THEN SUBST1_TAC
   THEN ASM_REWRITE_TAC[]
   THEN REWRITE_TAC[GSYM node]
   THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F1") (CONJUNCTS_THEN2 (LABEL_TAC "F2") (LABEL_TAC "F3")))
   THEN MP_TAC (SPECL[`dart (G:(A)hypermap)`; `node_map (G:(A)hypermap)`] lemma_convolution_map)
   THEN ASM_REWRITE_TAC[hypermap_lemma; GSYM node]
   THEN DISCH_THEN (LABEL_TAC "F4")
   THEN REMOVE_THEN "F3" MP_TAC
   THEN REWRITE_TAC[NODE_OF_SIZE_2]
   THEN ABBREV_TAC `y = node_map (G:(A)hypermap) (x:A)`
   THEN POP_ASSUM (LABEL_TAC "J0")
   THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F5") (LABEL_TAC "F6"))
   THEN USE_THEN "F1" (MP_TAC o MATCH_MP lemma_walkup_nodes)
   THEN ABBREV_TAC `J = edge_walkup (G:(A)hypermap) (x:A)`
   THEN POP_ASSUM (LABEL_TAC "J1")
   THEN USE_THEN "F6" (fun th -> (MP_TAC (MATCH_MP inverse_function (CONJ (CONJUNCT1(CONJUNCT2(CONJUNCT2(SPEC `G:(A)hypermap` hypermap_lemma)))) th))))
   THEN DISCH_THEN (fun th -> (LABEL_TAC "J2" (SYM th) THEN (SUBST1_TAC (SYM th))))
   THEN DISCH_THEN (LABEL_TAC "F7")
   THEN USE_THEN "F5" MP_TAC
   THEN USE_THEN "F1" (MP_TAC o CONJUNCT1 o CONJUNCT2 o MATCH_MP lemma_dart_invariant)
   THEN USE_THEN "F5" (fun th -> REWRITE_TAC[th])
   THEN USE_THEN "J0" (fun th -> REWRITE_TAC[th])
   THEN DISCH_THEN (LABEL_TAC "F8")
  THEN USE_THEN "F1" (fun th1 -> (USE_THEN "F8" (fun th2 -> (USE_THEN "F5" (fun th3 -> (MP_TAC (MATCH_MP lemma_in_walkup_dart (CONJ th1 (CONJ th2 th3)))))))))
   THEN USE_THEN "J1" (fun th->REWRITE_TAC[th])
   THEN DISCH_THEN (LABEL_TAC "F9")
   THEN USE_THEN "F9" (MP_TAC o MATCH_MP lemma_walkup_nodes)
   THEN MP_TAC (CONJUNCT1(CONJUNCT2(SPECL[`G:(A)hypermap`; `x:A`; `x:A`] node_map_walkup)))
   THEN ASM_REWRITE_TAC[]
   THEN DISCH_THEN (fun th -> (MP_TAC (MATCH_MP inverse_function (CONJ (CONJUNCT1(CONJUNCT2(CONJUNCT2(SPEC `J:(A)hypermap` hypermap_lemma)))) th))))
   THEN DISCH_THEN (SUBST1_TAC o SYM)
   THEN ABBREV_TAC `W = edge_walkup (J:(A)hypermap) (y:A)`
   THEN SUBGOAL_THEN `~(node (W:(A)hypermap) (y:A) IN node_set W)` ASSUME_TAC
   THENL[REWRITE_TAC[GSYM lemma_in_node_set]
	   THEN EXPAND_TAC "W"
	   THEN REWRITE_TAC[lemma_edge_walkup]
	   THEN REWRITE_TAC[IN_DELETE]; ALL_TAC]
  THEN POP_ASSUM (MP_TAC o MATCH_MP (SET_RULE `~(a IN s) ==> (s DELETE a = s)`))
  THEN DISCH_THEN SUBST1_TAC
  THEN REMOVE_THEN "F7" (SUBST1_TAC o SYM)
  THEN DISCH_THEN (LABEL_TAC "F10" o SYM)
  THEN REWRITE_TAC[double_edge_walkup]
  THEN USE_THEN "J1" (fun th -> REWRITE_TAC[th])
  THEN FIND_ASSUM (fun th -> REWRITE_TAC[th]) `edge_walkup (J:(A)hypermap) (y:A) = W`
  THEN MP_TAC (SPECL[`dart (W:(A)hypermap)`; `node_map (W:(A)hypermap)`] lemma_convolution_map)
  THEN REWRITE_TAC[hypermap_lemma]
  THEN DISCH_THEN (fun th -> REWRITE_TAC[th])
  THEN REWRITE_TAC[GSYM node]
  THEN GEN_TAC
  THEN REWRITE_TAC[lemma_in_node_set]
  THEN POP_ASSUM SUBST1_TAC
  THEN REWRITE_TAC[IN_DELETE]
  THEN ABBREV_TAC `NN = node (W:(A)hypermap) (x':A)`
  THEN DISCH_THEN (fun th -> (MP_TAC (MATCH_MP lemma_node_representation (CONJUNCT1 th))))
  THEN REPEAT STRIP_TAC
  THEN REMOVE_THEN "F4" (MP_TAC o SPEC `x'':A`)
  THEN ASM_REWRITE_TAC[]);;

let lemmaHOZKXVW = prove(`!(H:(A)hypermap) (x:A).x IN dart H /\ plain_hypermap H ==> (CARD (edge H x) = 2 ==> plain_hypermap (double_face_walkup H x (edge_map H x)) /\ plain_hypermap (double_node_walkup H x (edge_map H x))) /\ (CARD (node H x) = 2 ==> plain_hypermap (double_edge_walkup H x (node_map H x)))`,
  REPEAT STRIP_TAC
  THENL[ASM_MESON_TAC[double_face_walkup_plain_hypermap];
        ASM_MESON_TAC[double_node_walkup_plain_hypermap];
        ASM_MESON_TAC[double_edge_walkup_plain_hypermap]]);;

(* WE DEFINE THE MOEBIUS CONTOUR HERE *)

let is_Moebius_contour = new_definition `is_Moebius_contour (H:(A)hypermap) (p:num->A) (k:num) <=> (is_inj_contour H p k /\ (?i:num j:num. 0 < i /\ i <=j /\ j < k /\ (p j = node_map H (p 0)) /\ (p k = node_map H (p i))))`;;

let lemma_contour_in_dart = prove(`!(H:(A)hypermap) (p:num->A) (n:num). p 0 IN dart H /\ is_contour H p n ==> p n IN dart H`,
   REPLICATE_TAC 2 GEN_TAC
   THEN INDUCT_TAC
   THENL[SIMP_TAC[]; ALL_TAC]
   THEN POP_ASSUM (LABEL_TAC "F1")
   THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F2") (MP_TAC))
   THEN REWRITE_TAC[is_contour]
   THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F3") (LABEL_TAC "F4"))
   THEN REMOVE_THEN "F1" MP_TAC
   THEN ASM_REWRITE_TAC[]
   THEN DISCH_THEN (LABEL_TAC "F5")
   THEN REMOVE_THEN "F4" MP_TAC
   THEN REWRITE_TAC[one_step_contour]
   THEN STRIP_TAC
   THENL[USE_THEN "F5" (fun th -> (MP_TAC(CONJUNCT2(CONJUNCT2(MATCH_MP lemma_dart_invariant th)))))
	   THEN POP_ASSUM (SUBST1_TAC o SYM)
	   THEN SIMP_TAC[]; ALL_TAC]
   THEN USE_THEN "F5" (fun th -> (MP_TAC(CONJUNCT1(CONJUNCT2(MATCH_MP lemma_dart_inveriant_under_inverse_maps th)))))
   THEN POP_ASSUM (SUBST1_TAC o SYM)
   THEN SIMP_TAC[]);;

let lemma_darts_in_contour = prove(`!(H:(A)hypermap) (p:num->A) (n:num). p 0 IN dart H /\ is_contour H p n ==> {p (i:num) | i <= n} SUBSET dart H`,
     REPEAT GEN_TAC
     THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F1") (LABEL_TAC "F2"))
     THEN REWRITE_TAC[SUBSET; EXTENSION; IN_ELIM_THM]
     THEN REPEAT STRIP_TAC
     THEN USE_THEN "F2" (MP_TAC o SPEC `i:num` o MATCH_MP lemma_subcontour)
     THEN POP_ASSUM SUBST1_TAC
     THEN POP_ASSUM (fun th -> REWRITE_TAC[th])
     THEN USE_THEN "F1" (fun th1 -> (DISCH_THEN (fun th2 -> (MP_TAC (MATCH_MP lemma_contour_in_dart (CONJ th1 th2))))))
     THEN SIMP_TAC[]);;

let lemma_first_dart_on_inj_contour = prove(`!(H:(A)hypermap) (p:num->A) (n:num). 0 < n /\ is_inj_contour H p n ==> p 0 IN dart H`,
 REPEAT GEN_TAC
   THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F1") (LABEL_TAC "F2"))
   THEN ASM_CASES_TAC `~(((p:num->A) 0) IN dart (H:(A)hypermap))`
   THENL[SUBGOAL_THEN `!m:num. m <= n ==> (p:num->A) m = p 0` ASSUME_TAC
       THENL[INDUCT_TAC THENL[ ARITH_TAC; ALL_TAC]
	   THEN  POP_ASSUM (LABEL_TAC "J0")
           THEN DISCH_THEN (LABEL_TAC "J1")
           THEN REMOVE_THEN "J0" MP_TAC
           THEN USE_THEN "J1" (ASSUME_TAC o REWRITE_RULE[LE_SUC_LT])
           THEN POP_ASSUM (fun th -> REWRITE_TAC[MATCH_MP LT_IMP_LE th])
           THEN DISCH_TAC
           THEN ABBREV_TAC `x = (p:num->A) 0`
           THEN USE_THEN "F2" (MP_TAC o SPEC `m:num` o CONJUNCT1 o  REWRITE_RULE[lemma_def_inj_contour; lemma_def_contour])
           THEN REWRITE_TAC[GSYM LE_SUC_LT]
           THEN REMOVE_THEN "J1" (fun th -> REWRITE_TAC[th])
           THEN REWRITE_TAC[one_step_contour]
           THEN ASM_REWRITE_TAC[]
           THEN MP_TAC (SPEC `x:A` (MATCH_MP map_permutes_outside_domain (CONJUNCT2(SPEC `H:(A)hypermap` face_map_and_darts))))
	   THEN ASM_REWRITE_TAC[]
	   THEN DISCH_THEN SUBST1_TAC
	   THEN MP_TAC (SPEC `x:A` (MATCH_MP map_permutes_outside_domain (CONJUNCT2(SPEC `H:(A)hypermap` node_map_and_darts))))
	   THEN ASM_REWRITE_TAC[]
	   THEN DISCH_THEN (SUBST1_TAC o SYM o ONCE_REWRITE_RULE[node_map_inverse_representation] o SYM)
	   THEN SIMP_TAC[]; ALL_TAC]
       THEN USE_THEN "F2" (MP_TAC o SPECL[`n:num`; `0`] o CONJUNCT2 o REWRITE_RULE[lemma_def_inj_contour])
       THEN USE_THEN "F1" (fun th -> REWRITE_TAC[th; LE_REFL])
       THEN POP_ASSUM (MP_TAC o REWRITE_RULE[LE_REFL] o SPEC `n:num`)
       THEN MESON_TAC[]; ALL_TAC]
   THEN POP_ASSUM (fun th -> MESON_TAC[th]));;

let lemma_darts_on_Moebius_contour = prove(`!(H:(A)hypermap) (p:num->A) (k:num). is_Moebius_contour H p k ==> (2 <= k) /\ (p:num->A) 0 IN dart H /\ SUC k <= CARD(dart H)`,
   REPEAT GEN_TAC  THEN REWRITE_TAC[is_Moebius_contour]
   THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "FJ") (STRIP_ASSUME_TAC))
   THEN MP_TAC (ARITH_RULE `0 < i:num /\ i <= j:num /\ j < k:num ==> 2 <= k`)
   THEN ASM_REWRITE_TAC[]
   THEN DISCH_THEN (fun th -> (ASSUME_TAC th  THEN REWRITE_TAC[th]))
   THEN MP_TAC (SPECL[`H:(A)hypermap`; `p:num->A`;  `k:num`] lemma_first_dart_on_inj_contour)
   THEN POP_ASSUM (fun th -> REWRITE_TAC[MATCH_MP (ARITH_RULE`2 <= k:num ==> 0 < k`) th])
   THEN USE_THEN "FJ" (fun th -> REWRITE_TAC[th])
   THEN DISCH_THEN (LABEL_TAC "F1")
   THEN USE_THEN "F1" (fun th -> REWRITE_TAC[th])
   THEN USE_THEN "FJ" (MP_TAC o CONJUNCT2 o REWRITE_RULE[lemma_def_inj_contour])
   THEN GEN_REWRITE_TAC (LAND_CONV o TOP_DEPTH_CONV) [GSYM LT_SUC_LE]
   THEN REWRITE_TAC[MESON[] `~(a = b) <=> ~(b=a)`]
   THEN DISCH_THEN (MP_TAC o MATCH_MP CARD_FINITE_SERIES_EQ)
   THEN DISCH_THEN (SUBST1_TAC o SYM)
   THEN USE_THEN "FJ" (MP_TAC o CONJUNCT1 o REWRITE_RULE[lemma_def_inj_contour])
   THEN DISCH_THEN (fun th1 -> (USE_THEN "F1" (fun th -> (MP_TAC(MATCH_MP lemma_darts_in_contour (CONJ th th1))))))
   THEN GEN_REWRITE_TAC (LAND_CONV o TOP_DEPTH_CONV) [GSYM LT_SUC_LE]
   THEN DISCH_TAC
   THEN MATCH_MP_TAC CARD_SUBSET
   THEN POP_ASSUM (fun th -> REWRITE_TAC[th; hypermap_lemma]));; 

let lemma_Moebius_contour_points_subset_darts = prove(`!(H:(A)hypermap) (p:num -> A) (k:num). is_Moebius_contour H p k ==> {p (i:num) | i <= k} SUBSET dart H /\ CARD ({p (i:num) | i <= k}) = SUC k`,
   REPEAT GEN_TAC
     THEN DISCH_THEN (LABEL_TAC "F1")
     THEN USE_THEN "F1" (LABEL_TAC "F2" o CONJUNCT1 o CONJUNCT2 o MATCH_MP lemma_darts_on_Moebius_contour)
     THEN USE_THEN "F1" MP_TAC
     THEN REWRITE_TAC[is_Moebius_contour]
     THEN DISCH_THEN (MP_TAC o CONJUNCT1)
     THEN REWRITE_TAC[lemma_def_inj_contour]
     THEN DISCH_THEN (CONJUNCTS_THEN2 (MP_TAC) (LABEL_TAC "F3"))
     THEN REMOVE_THEN "F2" (fun th1 -> (DISCH_THEN (fun th2 -> (MP_TAC (MATCH_MP lemma_darts_in_contour (CONJ th1 th2))))))
     THEN DISCH_THEN (fun th -> REWRITE_TAC[th])
     THEN MP_TAC (GSYM (SPECL[`SUC (k:num)`; `p:num->A`] CARD_FINITE_SERIES_EQ))
     THEN REWRITE_TAC[LT_SUC_LE]
     THEN ASM_REWRITE_TAC[]
     THEN REWRITE_TAC[EQ_SYM]);;

let lemma_darts_is_Moebius_contour = prove(`!(H:(A)hypermap) (p:num->A) (k:num). is_Moebius_contour H p k /\ SUC k = CARD(dart H) ==> dart H = {p (i:num) | i <= k}`,
     REPEAT STRIP_TAC
     THEN CONV_TAC SYM_CONV
     THEN FIRST_X_ASSUM (MP_TAC o MATCH_MP  lemma_Moebius_contour_points_subset_darts)
     THEN POP_ASSUM SUBST1_TAC
     THEN MP_TAC (CONJUNCT1 (SPEC `H:(A)hypermap` hypermap_lemma))
     THEN REWRITE_TAC[IMP_IMP; CARD_SUBSET_EQ]);;

let lemma_point_in_path = prove(`!(p:num->A) k:num x:A. (x IN {p (i:num) | i <= k} <=> ?j:num. j <= k /\ x = p j)`, REWRITE_TAC[IN_ELIM_THM]);;

let lemma_point_not_in_path = prove(`!(p:num->A) k:num x:A. ~(x IN {p (i:num) | i <= k}) <=> !j:num. j <= k ==> ~(x = p j)`,
   REPEAT GEN_TAC
   THEN REWRITE_TAC[lemma_point_in_path]
   THEN MESON_TAC[]);;

let lemma_eliminate_dart_ouside_Moebius_contour = prove(`!(H:(A)hypermap) (p:num->A) (k:num) (x:A). is_Moebius_contour H p k /\ ~(x IN {p (i:num) | i <= k}) ==> is_Moebius_contour (edge_walkup H x) p k`,
   REPEAT GEN_TAC
    THEN REWRITE_TAC[lemma_point_not_in_path]
    THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F1") (LABEL_TAC "F2"))
    THEN label_hypermap4_TAC `H:(A)hypermap`
    THEN (LABEL_TAC "G1" (CONJUNCT1(CONJUNCT2(SPEC `edge_walkup (H:(A)hypermap) (x:A)` hypermap_lemma))))
    THEN (LABEL_TAC "G2" (CONJUNCT1(CONJUNCT2(CONJUNCT2(SPEC `edge_walkup (H:(A)hypermap) (x:A)` hypermap_lemma)))))
    THEN (LABEL_TAC "G3" (CONJUNCT1(CONJUNCT2(CONJUNCT2(CONJUNCT2(SPEC `edge_walkup (H:(A)hypermap) (x:A)` hypermap_lemma))))))
    THEN ABBREV_TAC `G = edge_walkup (H:(A)hypermap) (x:A)`
    THEN ABBREV_TAC `D = dart (H:(A)hypermap)`
    THEN ABBREV_TAC `e = edge_map (H:(A)hypermap)`
    THEN ABBREV_TAC `n = node_map (H:(A)hypermap)`
    THEN ABBREV_TAC `f = face_map (H:(A)hypermap)`
    THEN ABBREV_TAC `D' = dart (G:(A)hypermap)`
    THEN ABBREV_TAC `e' = edge_map (G:(A)hypermap)`
    THEN ABBREV_TAC `n' = node_map (G:(A)hypermap)`
    THEN ABBREV_TAC `f' = face_map (G:(A)hypermap)`
    THEN SUBGOAL_THEN `!i:num j:num. i <= k /\ j <= k /\ (n:A->A) ((p:num->A) i) = p j ==> (n':A->A) (p i) = p j` (LABEL_TAC "F3")
    THENL[REPEAT GEN_TAC
      THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "E3") (CONJUNCTS_THEN2 (LABEL_TAC "E4") (LABEL_TAC "E5")))
      THEN USE_THEN "F2" (MP_TAC o GSYM o SPEC `i:num`)
      THEN USE_THEN "E3" (fun th -> REWRITE_TAC[th])
      THEN DISCH_THEN (LABEL_TAC "E6")
      THEN USE_THEN "F2" (MP_TAC o GSYM o SPEC `j:num`)
      THEN USE_THEN "E4" (fun th -> REWRITE_TAC[th])
      THEN DISCH_THEN (LABEL_TAC "E7")
      THEN SUBGOAL_THEN `~((p:num->A) (i:num) = inverse (n:A->A) (x:A))` (LABEL_TAC "E8")
      THENL[POP_ASSUM MP_TAC
	      THEN REWRITE_TAC[CONTRAPOS_THM]
	      THEN DISCH_THEN (MP_TAC o AP_TERM `n:A->A`)
	      THEN USE_THEN "E5" SUBST1_TAC
	      THEN USE_THEN "H3" (fun th -> REWRITE_TAC[MATCH_MP PERMUTES_INVERSES th]); ALL_TAC]
      THEN MP_TAC (CONJUNCT2(CONJUNCT2(SPECL[`H:(A)hypermap`; `x:A`; `(p:num->A) (i:num)`] node_map_walkup)))
      THEN ASM_REWRITE_TAC[]; ALL_TAC]
   THEN SUBGOAL_THEN `!i:num j:num. i <= k /\ j <= k /\ inverse (n:A->A) ((p:num->A) i) = p j ==> inverse (n':A->A) (p i) = p j` (LABEL_TAC "F4")
   THENL[USE_THEN "H3" (fun th -> REWRITE_TAC[MATCH_MP PERMUTES_INVERSE_EQ th])
	THEN USE_THEN "G2" (fun th -> REWRITE_TAC[MATCH_MP PERMUTES_INVERSE_EQ th])
	THEN POP_ASSUM (fun th -> MESON_TAC[th]); ALL_TAC]
   THEN SUBGOAL_THEN `!i:num j:num. i <= k /\ j <= k /\ (f:A->A) ((p:num->A) i) = p j ==> (f':A->A) (p i) = p j` (LABEL_TAC "F5")
   THENL[ REPEAT GEN_TAC
       THEN  DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "FE3") (CONJUNCTS_THEN2 (LABEL_TAC "FE4") (LABEL_TAC "FE5")))
       THEN USE_THEN "F2" (MP_TAC o GSYM o SPEC `i:num`)
       THEN USE_THEN "FE3" (fun th -> REWRITE_TAC[th])
       THEN DISCH_THEN (LABEL_TAC "FE6")
       THEN USE_THEN "F2" (MP_TAC o GSYM o SPEC `j:num`)
       THEN USE_THEN "FE4" (fun th -> REWRITE_TAC[th])
       THEN DISCH_THEN (LABEL_TAC "FE7")
       THEN SUBGOAL_THEN `~((p:num->A) (i:num) = inverse (f:A->A) (x:A))` (LABEL_TAC "FE8")
       THENL[POP_ASSUM MP_TAC
	       THEN REWRITE_TAC[CONTRAPOS_THM]
	       THEN DISCH_THEN (MP_TAC o AP_TERM `f:A->A`)
	       THEN USE_THEN "FE5" SUBST1_TAC
	       THEN USE_THEN "H4" (fun th -> REWRITE_TAC[MATCH_MP PERMUTES_INVERSES th]); ALL_TAC]
       THEN MP_TAC (CONJUNCT2(CONJUNCT2(SPECL[`H:(A)hypermap`; `x:A`; `(p:num->A) (i:num)`] face_map_walkup)))
       THEN ASM_REWRITE_TAC[]; ALL_TAC]
     THEN SUBGOAL_THEN `!i:num. i <= k:num /\is_inj_contour (H:(A)hypermap) (p:num->A) i ==> is_inj_contour (G:(A)hypermap) (p:num->A) i` ASSUME_TAC
     THENL[INDUCT_TAC
	   THENL[REWRITE_TAC[is_inj_contour]; ALL_TAC]
	   THEN REWRITE_TAC[is_inj_contour]
	   THEN POP_ASSUM (LABEL_TAC "J1")
	   THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "J2") (CONJUNCTS_THEN2 (LABEL_TAC "J3") (CONJUNCTS_THEN2 (LABEL_TAC "J4") (LABEL_TAC "J10"))))
	   THEN USE_THEN "J2" (LABEL_TAC "J5" o MATCH_MP (ARITH_RULE `SUC (i:num) <= (k:num) ==> i <= k`))
	   THEN REMOVE_THEN "J1" MP_TAC
	   THEN USE_THEN "J5" (fun th -> REWRITE_TAC[th])
	   THEN USE_THEN "J3" (fun th -> REWRITE_TAC[th])
	   THEN DISCH_THEN (fun th -> REWRITE_TAC[th])
	   THEN USE_THEN "J10" (fun th -> REWRITE_TAC[th])
	   THEN REMOVE_THEN "J4" MP_TAC
	   THEN REWRITE_TAC[one_step_contour]
	   THEN ASM_REWRITE_TAC[]
	   THEN STRIP_TAC
	   THENL[DISJ1_TAC
		THEN USE_THEN "F5" (MP_TAC o SPECL[`i:num`; `SUC (i:num)`])
		THEN POP_ASSUM (fun th -> REWRITE_TAC[SYM th])
		THEN POP_ASSUM (fun th -> REWRITE_TAC[th])
		THEN USE_THEN "J2" (fun th -> REWRITE_TAC[th])
		THEN REWRITE_TAC[EQ_SYM]; ALL_TAC]
	   THEN DISJ2_TAC
	   THEN USE_THEN "F4" (MP_TAC o SPECL[`i:num`; `SUC i`])
	   THEN POP_ASSUM (fun th -> REWRITE_TAC[SYM th])
	   THEN POP_ASSUM (fun th -> REWRITE_TAC[th])
	   THEN USE_THEN "J2" (fun th -> REWRITE_TAC[th])
	   THEN REWRITE_TAC[EQ_SYM]; ALL_TAC]
     THEN POP_ASSUM (MP_TAC o SPEC `k:num`)
   THEN REWRITE_TAC[LE_REFL]
   THEN DISCH_THEN (LABEL_TAC "F6")
   THEN REMOVE_THEN "F1" (MP_TAC)
   THEN REWRITE_TAC[is_Moebius_contour]
   THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F7") (LABEL_TAC "F8"))
   THEN REMOVE_THEN "F6" MP_TAC
   THEN USE_THEN "F7" (fun th -> REWRITE_TAC[th])
   THEN DISCH_THEN (fun th -> REWRITE_TAC[th])
   THEN POP_ASSUM (X_CHOOSE_THEN `i:num` (X_CHOOSE_THEN `j:num` MP_TAC))
   THEN FIND_ASSUM SUBST1_TAC `node_map (H:(A)hypermap) = n`
    THEN FIND_ASSUM SUBST1_TAC `node_map (G:(A)hypermap) = n'`
    THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F9") (CONJUNCTS_THEN2 (LABEL_TAC "F10") (CONJUNCTS_THEN2 (LABEL_TAC "F11") (CONJUNCTS_THEN2 (LABEL_TAC "F12") (LABEL_TAC "F13")))))
    THEN EXISTS_TAC `i:num`
    THEN EXISTS_TAC `j:num`
    THEN USE_THEN "F9" (fun th -> REWRITE_TAC[th])
    THEN USE_THEN "F10" (fun th -> REWRITE_TAC[th])
    THEN USE_THEN "F11" (fun th -> REWRITE_TAC[th])
    THEN USE_THEN "F11" (LABEL_TAC "F15" o MATCH_MP (ARITH_RULE `j:num < k:num ==> j <= k`))
    THEN USE_THEN "F10" (fun th1 -> (USE_THEN "F15" (fun th2-> (LABEL_TAC "F16" (MATCH_MP LE_TRANS (CONJ th1 th2))))))
    THEN USE_THEN "F3" (MP_TAC o SPECL[`0`; `j:num`])
    THEN USE_THEN "F16" (fun th -> REWRITE_TAC[th; LE_0])
    THEN USE_THEN "F15" (fun th -> REWRITE_TAC[th])
    THEN USE_THEN "F12" (fun th -> REWRITE_TAC[th])
    THEN DISCH_THEN (fun th-> REWRITE_TAC[th])
    THEN USE_THEN "F3" (MP_TAC o SPECL[`i:num`; `k:num`])
    THEN USE_THEN "F16" (fun th -> REWRITE_TAC[th; LE_REFL])
    THEN USE_THEN "F13" (fun th -> REWRITE_TAC[th])
    THEN REWRITE_TAC[EQ_SYM]);;

let shift_path = new_definition `shift_path (p:num->A) (l:num) = \i:num. p (l + i)`;;

let lemma_shift_path_evaluation = prove(`!p:num->A l:num i:num. shift_path p l i = p (l+i)`, REWRITE_TAC[shift_path]);;

let lemma_shift_path = prove(`!(H:(A)hypermap) (p:num->A) (n:num) (l:num). is_path H p n /\ l <= n ==> is_path H (shift_path p l) (n-l)`,
   REPEAT GEN_TAC
   THEN REWRITE_TAC[lemma_def_path]
   THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F1") (LABEL_TAC "F2"))
   THEN GEN_TAC
   THEN DISCH_THEN (LABEL_TAC "F3")
   THEN REWRITE_TAC[go_one_step]
   THEN REWRITE_TAC[lemma_shift_path_evaluation; ADD_SUC]
   THEN USE_THEN "F3" (ASSUME_TAC o MATCH_MP (ARITH_RULE `i:num < (n:num) - (l:num) ==> l +i < n`))
   THEN REWRITE_TAC[GSYM go_one_step]
   THEN USE_THEN "F1" (MP_TAC o SPEC `(l:num) + (i:num)`)
   THEN POP_ASSUM (fun th -> REWRITE_TAC[th]));;

  
let lemma_shift_contour = prove(`!(H:(A)hypermap) (p:num->A) (n:num) (l:num). is_contour H p n /\ l <= n ==> is_contour H (shift_path p l) (n-l)`,
   REPEAT GEN_TAC
   THEN REWRITE_TAC[lemma_def_contour]
   THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F1") (LABEL_TAC "F2"))
   THEN GEN_TAC
   THEN DISCH_THEN (LABEL_TAC "F3")
   THEN REWRITE_TAC[one_step_contour]
   THEN REWRITE_TAC[lemma_shift_path_evaluation; ADD_SUC]
   THEN USE_THEN "F3" (ASSUME_TAC o MATCH_MP (ARITH_RULE `i:num < (n:num) - (l:num) ==> l +i < n`))
   THEN REWRITE_TAC[GSYM one_step_contour]
   THEN USE_THEN "F1" (MP_TAC o SPEC `(l:num) + (i:num)`)
   THEN POP_ASSUM (fun th -> REWRITE_TAC[th]));;

let lemma_shift_inj_contour = prove(`!(H:(A)hypermap) (p:num->A) (n:num) (l:num). is_inj_contour H p n /\ l <= n ==> is_inj_contour H (shift_path p l) (n-l)`,
  REPEAT GEN_TAC
  THEN REWRITE_TAC[lemma_def_inj_contour]
  THEN REWRITE_TAC[lemma_shift_path_evaluation]
  THEN DISCH_THEN (CONJUNCTS_THEN2 (CONJUNCTS_THEN2 (LABEL_TAC "F1") (LABEL_TAC "F2")) (LABEL_TAC "F3"))
  THEN USE_THEN "F1" (fun th1 -> (USE_THEN "F3" (fun th2 -> REWRITE_TAC[MATCH_MP lemma_shift_contour (CONJ th1 th2)])))
  THEN REPEAT GEN_TAC
  THEN DISCH_THEN (MP_TAC o MATCH_MP (ARITH_RULE `i:num <= (n:num) -(l:num) /\ j:num < i ==>  l + i <= n /\ l + j < l + i`))
  THEN DISCH_TAC
  THEN USE_THEN "F2" (MP_TAC o SPECL[`(l:num) + (i:num)`; `(l:num) + (j:num)`])
  THEN POP_ASSUM (fun th -> REWRITE_TAC[th]));;

let concatenate_two_contours = prove(`!(H:(A)hypermap) (p:num->A) (q:num->A) n:num m:num. is_inj_contour H p n /\ is_inj_contour H q m /\ p n = q 0  /\ (!j:num. 0 < j /\ j <= m ==> (!i:num. i <= n ==> ~(q j = p i))) ==> ?g:num->A. g 0 = p 0 /\ g (n+m) = q m /\ is_inj_contour H g (n+m) /\ (!i:num. i <= n ==> g i = p i) /\ (!i:num. i <= m ==> g (n+i) = q i)`,
   REPEAT GEN_TAC
   THEN REWRITE_TAC[lemma_def_inj_contour]
   THEN DISCH_THEN (CONJUNCTS_THEN2 (CONJUNCTS_THEN2 (LABEL_TAC "F1") (LABEL_TAC "F2")) (CONJUNCTS_THEN2(CONJUNCTS_THEN2 (LABEL_TAC "F3") (LABEL_TAC "F4")) (CONJUNCTS_THEN2 (LABEL_TAC "F5") (LABEL_TAC "F6"))))
   THEN USE_THEN "F1" (fun th1 -> (USE_THEN "F3" (fun th2 -> (USE_THEN "F5" (fun th3 -> (MP_TAC (MATCH_MP concatenate_contours (CONJ th1 (CONJ th2 th3)))))))))
   THEN DISCH_THEN (X_CHOOSE_THEN `g:num->A` (CONJUNCTS_THEN2 (LABEL_TAC "F7") (CONJUNCTS_THEN2 (LABEL_TAC "F8") (CONJUNCTS_THEN2 (LABEL_TAC "F9") (CONJUNCTS_THEN2 (LABEL_TAC "F10") (LABEL_TAC "F11"))))))
   THEN EXISTS_TAC `g:num->A`
   THEN ASM_REWRITE_TAC[]
   THEN REPEAT GEN_TAC
   THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F12") (LABEL_TAC "F14"))
   THEN ASM_CASES_TAC `i:num <= n:num`
   THENL[POP_ASSUM (LABEL_TAC "F15")
       THEN USE_THEN "F10" (MP_TAC o SPEC `i:num`)
       THEN USE_THEN "F15" (fun th -> REWRITE_TAC[th])
       THEN DISCH_THEN SUBST1_TAC
       THEN USE_THEN "F10" (MP_TAC o SPEC `j:num`)
       THEN USE_THEN "F14" (fun th -> (USE_THEN "F15" (fun th2 -> REWRITE_TAC[MATCH_MP (ARITH_RULE `j:num < i:num /\ (i <=n) ==> j <=n`) (CONJ th th2)])))
       THEN DISCH_THEN SUBST1_TAC
       THEN USE_THEN "F2" (MP_TAC o SPECL[`i:num`; `j:num`])
       THEN USE_THEN "F14" (fun th -> REWRITE_TAC[th])
       THEN USE_THEN "F15" (fun th -> REWRITE_TAC[th]); ALL_TAC]
   THEN POP_ASSUM MP_TAC
   THEN REWRITE_TAC[NOT_LE; LT_EXISTS]
   THEN DISCH_THEN (X_CHOOSE_THEN `d:num` (LABEL_TAC "K1"))
   THEN ABBREV_TAC `u = SUC d`
   THEN REMOVE_THEN "K1" (SUBST_ALL_TAC)
   THEN USE_THEN "F11" (MP_TAC o SPEC `u:num`)
   THEN USE_THEN "F12" (fun th -> (LABEL_TAC "F15" (MATCH_MP (ARITH_RULE `(n:num) + (u:num) <= n + (m:num) ==> u <= m`) th)))
   THEN USE_THEN "F15" (fun th -> REWRITE_TAC[th])
   THEN DISCH_THEN SUBST1_TAC
   THEN ASM_CASES_TAC `j:num <= n:num`
   THENL[USE_THEN "F10" (MP_TAC o SPEC `j:num`)
       THEN POP_ASSUM (fun th -> (REWRITE_TAC[th] THEN (LABEL_TAC "F16" th)))
       THEN DISCH_THEN SUBST1_TAC
       THEN MP_TAC (SPEC `d:num` LT_0)
       THEN FIND_ASSUM SUBST1_TAC `SUC d = (u:num)`
       THEN DISCH_THEN (LABEL_TAC "F17")
       THEN USE_THEN "F6" (MP_TAC o SPEC `u:num`)
       THEN POP_ASSUM (fun th -> REWRITE_TAC[th])
       THEN USE_THEN "F15" (fun th -> REWRITE_TAC[th])
       THEN USE_THEN "F16" (fun th -> MESON_TAC[th]); ALL_TAC]
   THEN POP_ASSUM MP_TAC
   THEN REWRITE_TAC[NOT_LE; LT_EXISTS]
   THEN DISCH_THEN (X_CHOOSE_THEN `v:num` SUBST_ALL_TAC)
   THEN USE_THEN "F14" MP_TAC
   THEN REWRITE_TAC[LT_ADD_LCANCEL]
   THEN DISCH_THEN (LABEL_TAC "F21")
   THEN USE_THEN "F11" (MP_TAC o SPEC `SUC (v:num)`)
   THEN USE_THEN "F21" (fun th1 -> (USE_THEN "F15" (fun th2 -> REWRITE_TAC[MATCH_MP (ARITH_RULE `SUC v < u:num /\ u <= m:num ==> SUC v <= m`) (CONJ th1 th2)])))
   THEN DISCH_THEN SUBST1_TAC
   THEN USE_THEN "F4" (MP_TAC o SPECL[`u:num`; `SUC (v:num)`])
   THEN USE_THEN "F15" (fun th -> REWRITE_TAC[th])
   THEN USE_THEN "F21" (fun th -> REWRITE_TAC[th]));;


let concatenate_two_disjoint_contours = prove(`!(H:(A)hypermap) (p:num->A) (q:num->A) n:num m:num. is_inj_contour H p n /\ is_inj_contour H q m /\ one_step_contour H (p n) (q 0) /\(!i:num j:num. i <= n /\ j <= m ==> ~(q j = p i)) ==> ?g:num->A. g 0 = p 0 /\ g (n+m+1) = q m /\ is_inj_contour H g (n+m+1) /\ (!i:num. i <= n ==> g i = p i) /\ (!i:num. i <= m ==> g (n+i+1) = q i)`,
   REPEAT GEN_TAC
   THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F1") (CONJUNCTS_THEN2 (LABEL_TAC "F2") (CONJUNCTS_THEN2 (LABEL_TAC "F3") (LABEL_TAC "F4"))))
   THEN ABBREV_TAC `w = (\k:num. if k = SUC (n:num) then (q:num->A) 0 else (p:num->A) k)`
   THEN POP_ASSUM (LABEL_TAC "FC")
   THEN SUBGOAL_THEN `!i:num. i <= n:num ==> (p:num->A) i = (w:num->A) i` (LABEL_TAC "F5")
   THENL[GEN_TAC
       THEN EXPAND_TAC "w"
       THEN MESON_TAC[COND_ELIM_THM; ARITH_RULE `i:num <= n:num ==> ~(i = SUC n)`]; ALL_TAC]
   THEN USE_THEN "F1" (fun th1 -> (USE_THEN "F5" (fun th2 -> (LABEL_TAC "F6" (MATCH_MP identify_inj_contour (CONJ th1 th2))))))
   THEN SUBGOAL_THEN `is_inj_contour (H:(A)hypermap) (w:num->A) (SUC (n:num))` (LABEL_TAC "F7")
   THENL[REWRITE_TAC[is_inj_contour]
      THEN USE_THEN "F6" (fun th -> REWRITE_TAC[th])
      THEN USE_THEN "F5" (MP_TAC o SPEC `n:num`)
      THEN REWRITE_TAC[LE_REFL]
      THEN DISCH_THEN (SUBST1_TAC o SYM)
      THEN USE_THEN "FC" (fun th -> (MP_TAC (AP_THM th `SUC (n:num)`)))
      THEN REWRITE_TAC[]
      THEN DISCH_THEN (SUBST1_TAC o SYM)
      THEN USE_THEN "F3" (fun th -> REWRITE_TAC[th])
      THEN GEN_TAC
      THEN DISCH_THEN (LABEL_TAC "F7")
      THEN USE_THEN "F5" (MP_TAC o SPEC `i:num`)
      THEN USE_THEN "F7" (fun th -> REWRITE_TAC[th])
      THEN DISCH_THEN (SUBST1_TAC o SYM)
      THEN DISCH_THEN (MP_TAC o SYM)
      THEN USE_THEN "F4" (MP_TAC o SPECL[`i:num`; `0`])
      THEN USE_THEN "F7"(fun th -> REWRITE_TAC[th; LE_0]); ALL_TAC]
   THEN USE_THEN "FC" (fun th -> (MP_TAC (AP_THM th `SUC (n:num)`)))
   THEN REWRITE_TAC[]
   THEN DISCH_THEN (LABEL_TAC "F8" o SYM)
   THEN SUBGOAL_THEN `!j:num. 0 < j /\ j <= m:num ==> (!i:num. i <= SUC (n:num) ==> ~((q:num->A) j = (w:num->A) i))` (LABEL_TAC "F9")
   THENL[GEN_TAC
      THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "G1") (LABEL_TAC "G2"))
      THEN GEN_TAC
      THEN DISCH_THEN (LABEL_TAC "G3")
      THEN ASM_CASES_TAC `i:num = SUC (n:num)`
      THENL[POP_ASSUM SUBST_ALL_TAC
	   THEN USE_THEN "F8" SUBST1_TAC
	   THEN USE_THEN "F2" MP_TAC
	   THEN REWRITE_TAC[lemma_def_inj_contour]
	   THEN DISCH_THEN (MP_TAC o SPECL[`j:num`; `0`] o CONJUNCT2)
	   THEN ASM_REWRITE_TAC[]
	   THEN SIMP_TAC[]; ALL_TAC]
      THEN USE_THEN "F5" (MP_TAC o SPEC `i:num`)
      THEN POP_ASSUM (fun th1 -> (USE_THEN "G3" (fun th2 -> (LABEL_TAC "G4" (MATCH_MP (ARITH_RULE `~(i:num = SUC n) /\ (i <= SUC n) ==> i <= n`) (CONJ th1 th2))))))
      THEN USE_THEN "G4" (fun th -> REWRITE_TAC[th])
      THEN DISCH_THEN (SUBST1_TAC o SYM)
      THEN USE_THEN "F4" (MP_TAC o SPECL[`i:num`; `j:num`])
      THEN USE_THEN "G4" (fun th -> REWRITE_TAC[th])
      THEN USE_THEN "G2" (fun th -> REWRITE_TAC[th]); ALL_TAC]
   THEN USE_THEN "F7" (fun th1 -> (USE_THEN "F2" (fun th2 -> (USE_THEN "F8" (fun th3 -> (USE_THEN "F9" (fun th4 -> (MP_TAC (MATCH_MP concatenate_two_contours (CONJ th1 (CONJ th2 (CONJ th3 th4))))))))))))
   THEN DISCH_THEN (X_CHOOSE_THEN `g:num->A` (CONJUNCTS_THEN2 (LABEL_TAC "F10") (CONJUNCTS_THEN2 (LABEL_TAC "F11") (CONJUNCTS_THEN2 (LABEL_TAC "F12") (CONJUNCTS_THEN2 (LABEL_TAC "F14") (LABEL_TAC "F15"))))))
   THEN EXISTS_TAC `g:num->A`
   THEN USE_THEN "F12" MP_TAC
   THEN REWRITE_TAC[GSYM ADD1; ADD_SUC; ADD]
   THEN DISCH_THEN (fun th -> REWRITE_TAC[th])
   THEN USE_THEN "F10" SUBST1_TAC
   THEN USE_THEN "F5" (MP_TAC o SPEC `0`)
   THEN REWRITE_TAC[LE_0]
   THEN DISCH_THEN  (fun th -> REWRITE_TAC[SYM th])
   THEN USE_THEN "F11" MP_TAC
   THEN REWRITE_TAC[ADD]
   THEN DISCH_THEN (fun th -> REWRITE_TAC[th])
   THEN USE_THEN "F15" (fun th -> REWRITE_TAC[th; GSYM ADD])
   THEN GEN_TAC
   THEN DISCH_THEN (LABEL_TAC "F16")
   THEN USE_THEN "F5" (MP_TAC o SPEC `i:num`)
   THEN USE_THEN "F16" (fun th -> REWRITE_TAC[th])
   THEN DISCH_THEN (fun th -> REWRITE_TAC[th])
   THEN USE_THEN "F14" (MP_TAC o SPEC `i:num`)
   THEN USE_THEN "F16" (fun th -> REWRITE_TAC[MATCH_MP (ARITH_RULE `i:num <= n ==> i <= SUC n`) th]));;

(* Lemma on reducing darts from a contour to make an injective contour *)

let lemma4dot11 = prove(`!(H:(A)hypermap) p:num->A n:num. is_contour H p n ==> ?q:num->A m:num. m <= n /\q 0 = p 0 /\ q m = p n /\ is_inj_contour H q m /\ (!i:num. (i < m)==>(?j:num. i <= j /\ j < n /\ q i = p j /\ q (SUC i) = p (SUC j)))`,
   REPLICATE_TAC 2 GEN_TAC
   THEN INDUCT_TAC 
   THENL[STRIP_TAC THEN EXISTS_TAC `p:num->A` THEN EXISTS_TAC `0` THEN ASM_REWRITE_TAC[is_inj_contour] THEN  ARITH_TAC; ALL_TAC]
   THEN REWRITE_TAC[is_contour] THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F1") (LABEL_TAC "F2"))
   THEN FIRST_X_ASSUM(MP_TAC o check(is_imp o concl))
   THEN ASM_REWRITE_TAC[]
   THEN DISCH_THEN (X_CHOOSE_THEN `q:num->A` (X_CHOOSE_THEN `m:num` (CONJUNCTS_THEN2 (LABEL_TAC "F3") (CONJUNCTS_THEN2 (LABEL_TAC "F4") (CONJUNCTS_THEN2 (LABEL_TAC "F5") (CONJUNCTS_THEN2 (LABEL_TAC "F6") (LABEL_TAC "F7")))))))
   THEN ASM_CASES_TAC `?k:num. k <= m:num /\ (q:num->A) k = p (SUC n:num)`
   THENL[POP_ASSUM (X_CHOOSE_THEN `k:num` (CONJUNCTS_THEN2 (LABEL_TAC "G1") (LABEL_TAC "G2")))
       THEN EXISTS_TAC `q:num->A`
       THEN EXISTS_TAC `k:num`
       THEN ASM_REWRITE_TAC[]  
       THEN USE_THEN "G1" (fun th1 -> (USE_THEN "F3" (fun th2 -> MP_TAC(MATCH_MP LE_TRANS (CONJ th1 th2)))))
       THEN DISCH_THEN (fun th -> REWRITE_TAC[MATCH_MP (ARITH_RULE `k:num <= n:num ==> k <= SUC n`) th])
       THEN USE_THEN "F6" (MP_TAC o (SPEC `k:num`) o MATCH_MP lemma_sub_inj_contour)
       THEN USE_THEN "G1" (fun th -> REWRITE_TAC[th])
       THEN DISCH_THEN (fun th -> REWRITE_TAC[th])
       THEN REPEAT STRIP_TAC
       THEN USE_THEN "F7" (MP_TAC o SPEC `i:num`)
       THEN POP_ASSUM (fun th -> (USE_THEN "G1" (fun th1 -> REWRITE_TAC[MATCH_MP LTE_TRANS (CONJ th th1)])))
       THEN MESON_TAC[LT_RIGHT_SUC]; ALL_TAC]
   THEN POP_ASSUM MP_TAC
   THEN STRIP_TAC
   THEN ABBREV_TAC `g = (\i:num. (p:num->A) (SUC n))`
   THEN SUBGOAL_THEN `is_inj_contour (H:(A)hypermap) (g:num->A) 0` ASSUME_TAC
   THENL[REWRITE_TAC[is_inj_contour]; ALL_TAC]
   THEN SUBGOAL_THEN `one_step_contour (H:(A)hypermap) ((q:num->A) (m:num)) ((g:num->A) 0)` ASSUME_TAC
   THENL[USE_THEN "F5" SUBST1_TAC
      THEN EXPAND_TAC "g"
      THEN USE_THEN "F2" (fun th -> REWRITE_TAC[th]); ALL_TAC]
   THEN SUBGOAL_THEN `!i:num j:num. i <= m:num /\ j <= 0 ==> ~((g:num->A) j = (q:num->A) i)` ASSUME_TAC
   THENL[REPEAT GEN_TAC
       THEN REWRITE_TAC[LE]
       THEN STRIP_TAC
       THEN POP_ASSUM SUBST1_TAC
       THEN EXPAND_TAC "g"
       THEN FIRST_ASSUM (MP_TAC o check (is_neg o  concl))
       THEN REWRITE_TAC[CONTRAPOS_THM]
       THEN DISCH_THEN SUBST1_TAC
       THEN EXISTS_TAC `i:num`
       THEN POP_ASSUM (fun th -> REWRITE_TAC[th]); ALL_TAC]
   THEN USE_THEN "F6" (fun th1 -> (POP_ASSUM (fun th4 -> (POP_ASSUM (fun th3 -> (POP_ASSUM (fun th2 -> (MP_TAC (MATCH_MP concatenate_two_disjoint_contours (CONJ th1 (CONJ th2 (CONJ th3 th4))))))))))))
   THEN EXPAND_TAC "g"
   THEN REWRITE_TAC[ADD;GSYM ADD1; ADD_SUC]
   THEN DISCH_THEN (X_CHOOSE_THEN `w:num->A` (CONJUNCTS_THEN2 (LABEL_TAC "H1") (CONJUNCTS_THEN2 (LABEL_TAC "H2") (CONJUNCTS_THEN2 (LABEL_TAC "H3") (LABEL_TAC "H4" o CONJUNCT1)))))
   THEN EXISTS_TAC `w:num->A`
   THEN EXISTS_TAC `SUC m`
   THEN REWRITE_TAC[LE_SUC]   
   THEN ASM_REWRITE_TAC[]
   THEN REPEAT STRIP_TAC
   THEN POP_ASSUM MP_TAC
   THEN GEN_REWRITE_TAC (LAND_CONV o TOP_DEPTH_CONV) [LT_SUC_LE; LE_LT]
   THEN STRIP_TAC
   THENL[POP_ASSUM (LABEL_TAC "H5")
       THEN USE_THEN "F7" (MP_TAC o SPEC `i:num`)
       THEN USE_THEN "H5" (fun th -> REWRITE_TAC[th])
       THEN USE_THEN "H4" (MP_TAC o SPEC `i:num`)
       THEN USE_THEN "H5" (fun th -> REWRITE_TAC[MATCH_MP LT_IMP_LE th])
       THEN DISCH_THEN  SUBST1_TAC
       THEN USE_THEN "H4" (MP_TAC o SPEC `SUC i`)
       THEN REWRITE_TAC[LE_SUC_LT]
       THEN USE_THEN "H5" (fun th -> REWRITE_TAC[th])
       THEN DISCH_THEN  SUBST1_TAC
       THEN MESON_TAC[ARITH_RULE `j:num < n:num ==> j < SUC n`]; ALL_TAC] 
   THEN EXISTS_TAC `n:num`
   THEN REWRITE_TAC[LT_PLUS]
   THEN POP_ASSUM SUBST1_TAC
   THEN USE_THEN "H2" SUBST1_TAC
   THEN USE_THEN "H4" (MP_TAC o SPEC `m:num`)
   THEN REWRITE_TAC[LE_REFL; EQ_SYM]
   THEN USE_THEN "F5" (fun th -> REWRITE_TAC[th])
   THEN USE_THEN "F3" (fun th -> REWRITE_TAC[th]));;
    
let lemma_one_step_contour = prove(`!(H:(A)hypermap) (x:A) (y:A). one_step_contour H x y <=> y = face_map H x \/ x = node_map H y`,
   REPEAT GEN_TAC
   THEN REWRITE_TAC[one_step_contour]
   THEN REWRITE_TAC[]
   THEN MP_TAC(SPECL[`y:A`; `x:A`] (MATCH_MP PERMUTES_INVERSE_EQ (CONJUNCT1(CONJUNCT2(CONJUNCT2(SPEC `H:(A)hypermap` hypermap_lemma))))))
   THEN MESON_TAC[]);;

let lemma_only_one_orbit = prove(`!s:A->bool p:A->A x:A. FINITE s /\ p permutes s /\ orbit_map p x = s ==> set_of_orbits s p = {orbit_map p x}`,
     REPEAT GEN_TAC
     THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F1") (CONJUNCTS_THEN2 (LABEL_TAC "F2") (LABEL_TAC "F3")))
     THEN MP_TAC (SPECL[`p:A->A`; `x:A`] orbit_reflect)
     THEN USE_THEN "F3" (fun th -> GEN_REWRITE_TAC (LAND_CONV o RAND_CONV) [th])
     THEN DISCH_THEN (LABEL_TAC "F4")
     THEN MATCH_MP_TAC SUBSET_ANTISYM
     THEN STRIP_TAC
     THENL[REWRITE_TAC[SUBSET; IN_SING]
	 THEN GEN_TAC
	 THEN REWRITE_TAC[set_of_orbits; IN_ELIM_THM]
	 THEN STRIP_TAC
	 THEN POP_ASSUM SUBST1_TAC
	 THEN POP_ASSUM MP_TAC
	 THEN USE_THEN "F3" (SUBST1_TAC o SYM)
	 THEN USE_THEN "F1" (fun th1 -> (USE_THEN "F2" (fun th2 -> (DISCH_THEN (fun th3 -> (MP_TAC (MATCH_MP lemma_orbit_identity (CONJ th1 (CONJ th2 th3)))))))))
	 THEN REWRITE_TAC[EQ_SYM]; ALL_TAC]
     THEN REWRITE_TAC[set_of_orbits; SUBSET; IN_SING; IN_ELIM_THM]
     THEN GEN_TAC
     THEN DISCH_TAC
     THEN EXISTS_TAC `x:A`
     THEN ASM_REWRITE_TAC[]);;

let lemma_atmost_two_orbits = prove(`!s:A->bool p:A->A x:A y:A. FINITE s /\ p permutes s /\ s SUBSET (orbit_map p x UNION orbit_map p y) ==> number_of_orbits s p <=2`,
   REPEAT GEN_TAC
   THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F1") (CONJUNCTS_THEN2 (LABEL_TAC "F2") (LABEL_TAC "F3")))
   THEN SUBGOAL_THEN `set_of_orbits (s:A->bool) (p:A->A) SUBSET {orbit_map p (x:A), orbit_map p (y:A)}` ASSUME_TAC
   THENL[ REWRITE_TAC[set_of_orbits; SUBSET; IN_ELIM_THM]
       THEN REPEAT STRIP_TAC
       THEN POP_ASSUM SUBST1_TAC
       THEN USE_THEN "F3" MP_TAC
       THEN REWRITE_TAC[SUBSET]
       THEN DISCH_THEN (MP_TAC o SPEC `x'':A`)
       THEN POP_ASSUM (fun th -> REWRITE_TAC[th])
       THEN REWRITE_TAC[IN_UNION]
       THEN STRIP_TAC
       THENL[USE_THEN "F1" (fun th1 -> (USE_THEN "F2" (fun th2 -> (POP_ASSUM  (fun th3 -> (MP_TAC (MATCH_MP lemma_orbit_identity (CONJ th1 (CONJ th2 th3)))))))))
	       THEN DISCH_THEN (SUBST1_TAC o SYM)
	       THEN SET_TAC[]; ALL_TAC]
       THEN USE_THEN "F1" (fun th1 -> (USE_THEN "F2" (fun th2 -> (POP_ASSUM  (fun th3 -> (MP_TAC (MATCH_MP lemma_orbit_identity (CONJ th1 (CONJ th2 th3)))))))))
       THEN DISCH_THEN (SUBST1_TAC o SYM)
       THEN SET_TAC[]; ALL_TAC]
   THEN MP_TAC (ISPECL[`orbit_map (p:A->A) (x:A)`; `orbit_map (p:A->A) (y:A)`] FINITE_TWO_ELEMENTS)
   THEN POP_ASSUM (fun th1 -> (DISCH_THEN (fun th2 -> (MP_TAC (MATCH_MP CARD_SUBSET (CONJ th1 th2))))))
   THEN REWRITE_TAC[number_of_orbits]
   THEN ASM_CASES_TAC `orbit_map (p:A->A) (x:A) = orbit_map p (y:A)`
   THENL[POP_ASSUM SUBST1_TAC
	THEN REWRITE_TAC[SET_RULE `{a,a} = {a}`; CARD_SINGLETON]
	THEN ARITH_TAC; ALL_TAC]
   THEN POP_ASSUM (MP_TAC o MATCH_MP CARD_TWO_ELEMENTS)
   THEN DISCH_THEN (fun th -> REWRITE_TAC[th]));;

let lemma_only_one_component = prove(`!(H:(A)hypermap) (x:A). comb_component H x = dart H ==> set_of_components H = {comb_component H x}`,
  REPEAT GEN_TAC
    THEN  DISCH_THEN (LABEL_TAC "F1")
    THEN MP_TAC (SPECL[`H:(A)hypermap`; `x:A`] lemma_component_reflect)
    THEN DISCH_THEN (LABEL_TAC "F2")
    THEN MATCH_MP_TAC SUBSET_ANTISYM
    THEN STRIP_TAC
    THENL[REWRITE_TAC[SUBSET; IN_SING]
       THEN GEN_TAC
       THEN REWRITE_TAC[set_of_components; set_part_components;IN_ELIM_THM]
       THEN STRIP_TAC
       THEN POP_ASSUM SUBST1_TAC
       THEN POP_ASSUM MP_TAC
       THEN USE_THEN "F1" (SUBST1_TAC o SYM)
       THEN DISCH_THEN (MP_TAC o MATCH_MP lemma_component_identity)
       THEN REWRITE_TAC[EQ_SYM]; ALL_TAC]
    THEN REWRITE_TAC[set_of_components; SUBSET; IN_SING; IN_ELIM_THM; set_part_components]
    THEN GEN_TAC
    THEN DISCH_TAC
    THEN EXISTS_TAC `x:A`
    THEN REMOVE_THEN "F1" (SUBST1_TAC o SYM)
    THEN ASM_REWRITE_TAC[]);;


(* THE MINIMUM HYPERMAP WHICH HAS A MOEBIUS CONTOUR - THE HYPERMAP OF ORDER 3 *)

let lemma_minimum_Moebius_hypermap = prove(`!(H:(A)hypermap). CARD(dart H) = 3 /\ (?p:num->A k:num. is_Moebius_contour H p k) ==> ~(planar_hypermap H)`,
  GEN_TAC
   THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F1") (X_CHOOSE_THEN `p:num->A` (X_CHOOSE_THEN `k:num` (LABEL_TAC "F2"))))
   THEN USE_THEN "F2" (MP_TAC o MATCH_MP lemma_darts_on_Moebius_contour)
   THEN ASM_REWRITE_TAC[]
   THEN DISCH_THEN ASSUME_TAC
   THEN MP_TAC (ARITH_RULE `2 <= k:num /\ SUC k <= 3 ==> k = 2`)
   THEN POP_ASSUM (fun th -> REWRITE_TAC[th])
   THEN DISCH_THEN SUBST_ALL_TAC
   THEN USE_THEN "F1" MP_TAC
   THEN REWRITE_TAC[ARITH_RULE `3 = SUC 2`]
   THEN USE_THEN "F2" (fun th1 -> (DISCH_THEN (fun th2 -> (MP_TAC(MATCH_MP lemma_darts_is_Moebius_contour (CONJ th1 (SYM th2)))))))
   THEN DISCH_THEN (LABEL_TAC "F3")
   THEN USE_THEN "F2" MP_TAC
   THEN REWRITE_TAC[is_Moebius_contour]
   THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F4") (X_CHOOSE_THEN `i:num` (X_CHOOSE_THEN `j:num` MP_TAC)))
   THEN USE_THEN "F3" SUBST1_TAC
   THEN DISCH_THEN (LABEL_TAC "C1")
   THEN MP_TAC (ARITH_RULE `0 < i:num /\ i <= j:num /\ j < 2 ==> (i = 1) /\ (j = 1)`)
   THEN USE_THEN "C1" (fun th -> REWRITE_TAC[th])
   THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F5") (LABEL_TAC "F6"))
   THEN REMOVE_THEN "C1" MP_TAC
   THEN ASM_REWRITE_TAC[]
   THEN REWRITE_TAC[ARITH_RULE `0 < 1 /\ 1 <= 1 /\ 1 < 2`]
   THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F7") (LABEL_TAC "F8"))
   THEN USE_THEN "F4" MP_TAC
   THEN REWRITE_TAC[lemma_def_inj_contour]
   THEN DISCH_THEN (LABEL_TAC "C2" o CONJUNCT2)
   THEN USE_THEN "C2" (MP_TAC o SPECL[`1`; `0`])
   THEN REWRITE_TAC[ARITH_RULE `1 <= 2 /\ 0 < 1`]
   THEN DISCH_THEN (LABEL_TAC "F9")
   THEN USE_THEN "C2" (MP_TAC o SPECL[`2`; `1`])
   THEN REWRITE_TAC[LE_REFL; ARITH_RULE `1 < 2`]
   THEN DISCH_THEN (LABEL_TAC "F10")
   THEN REMOVE_THEN "C2" (MP_TAC o SPECL[`2`; `0`])
   THEN REWRITE_TAC[LE_REFL; ARITH_RULE `0 < 2`]
   THEN DISCH_THEN (LABEL_TAC "F11")
   THEN USE_THEN "F4" MP_TAC
   THEN REWRITE_TAC[lemma_def_inj_contour]
   THEN DISCH_THEN (MP_TAC o CONJUNCT1)
   THEN REWRITE_TAC[lemma_def_contour]
   THEN DISCH_THEN (LABEL_TAC "C2")
   THEN USE_THEN "C2" (MP_TAC o SPEC `0`)
   THEN REWRITE_TAC[ARITH_RULE `0 < 2`; GSYM ONE; one_step_contour]
   THEN GEN_REWRITE_TAC (LAND_CONV) [GSYM DISJ_SYM]
   THEN STRIP_TAC
   THENL[POP_ASSUM MP_TAC
      THEN REWRITE_TAC[GSYM node_map_inverse_representation]
      THEN USE_THEN "F8" (SUBST1_TAC o SYM)
      THEN USE_THEN "F11" (fun th -> REWRITE_TAC[GSYM th]); ALL_TAC]
   THEN POP_ASSUM (LABEL_TAC "F12")
   THEN REMOVE_THEN "C2" (MP_TAC o SPEC `1`)
   THEN REWRITE_TAC[ARITH_RULE `1 < 2`; GSYM TWO; one_step_contour]
   THEN GEN_REWRITE_TAC (LAND_CONV) [GSYM DISJ_SYM]
   THEN STRIP_TAC
   THENL[POP_ASSUM MP_TAC
       THEN REWRITE_TAC[GSYM node_map_inverse_representation]
       THEN USE_THEN "F7" (fun th1 -> (DISCH_THEN (fun th2 -> (MP_TAC (MATCH_MP EQ_TRANS (CONJ (SYM th1) th2))))))
       THEN REWRITE_TAC[MATCH_MP PERMUTES_INJECTIVE (CONJUNCT1(CONJUNCT2(CONJUNCT2(SPEC `H:(A)hypermap` hypermap_lemma))))]
       THEN USE_THEN "F11" (fun th -> REWRITE_TAC[th]); ALL_TAC]
   THEN POP_ASSUM (LABEL_TAC "F14")
   THEN SUBGOAL_THEN `!x:A. x IN {(p:num->A) (i:num) | i <= 2} <=> x = p 0 \/ x = p 1 \/ x = p 2` MP_TAC
   THENL[GEN_TAC
      THEN REWRITE_TAC[ARITH_RULE `i:num <= 2 <=> i = 0 \/ i = 1 \/ i = 2`]
      THEN REWRITE_TAC[IN_ELIM_THM]
      THEN MESON_TAC[]; ALL_TAC]
   THEN USE_THEN "F3" (SUBST1_TAC o SYM)
   THEN DISCH_THEN (LABEL_TAC "F15")
   THEN ABBREV_TAC `a = (p:num->A) 0`
   THEN ABBREV_TAC `b = (p:num->A) 1`
   THEN ABBREV_TAC `c = (p:num->A) 2`
   THEN label_hypermap_TAC `H:(A)hypermap`
   THEN ABBREV_TAC `D = dart (H:(A)hypermap)`
   THEN POP_ASSUM (LABEL_TAC "AB1")
   THEN ABBREV_TAC `e = edge_map (H:(A)hypermap)`
   THEN POP_ASSUM (LABEL_TAC "AB2")
   THEN ABBREV_TAC `n = node_map (H:(A)hypermap)`
   THEN POP_ASSUM (LABEL_TAC "AB3")
   THEN ABBREV_TAC `f = face_map (H:(A)hypermap)`
   THEN POP_ASSUM (LABEL_TAC "AB4")
   THEN USE_THEN "F15" (MP_TAC o SPEC `c:A`)
   THEN REWRITE_TAC[]
   THEN DISCH_THEN (LABEL_TAC "F16")
   THEN SUBGOAL_THEN `(f:A->A) (c:A) = a:A` (LABEL_TAC "F17")
   THENL[USE_THEN "F16" MP_TAC
       THEN EXPAND_TAC "D"
       THEN DISCH_THEN (MP_TAC o CONJUNCT2 o CONJUNCT2 o MATCH_MP lemma_dart_invariant)
       THEN USE_THEN "AB4" (fun th -> REWRITE_TAC[th])
       THEN USE_THEN "AB1" (fun th -> REWRITE_TAC[th])
       THEN DISCH_TAC
       THEN USE_THEN "F15" (MP_TAC o SPEC `(f:A->A) (c:A)`)
       THEN POP_ASSUM (fun th -> REWRITE_TAC[th])
       THEN STRIP_TAC
       THENL[POP_ASSUM (fun th1 -> (USE_THEN "F12" (fun th2 -> MP_TAC(MATCH_MP EQ_TRANS (CONJ th1 th2)))))
	   THEN USE_THEN "H4"(fun th -> REWRITE_TAC[MATCH_MP PERMUTES_INJECTIVE th])
	   THEN USE_THEN "F11" (fun th -> REWRITE_TAC[GSYM th]); ALL_TAC]
       THEN POP_ASSUM (fun th1 -> (USE_THEN "F14" (fun th2 -> MP_TAC(MATCH_MP EQ_TRANS (CONJ th1 th2)))))
       THEN USE_THEN "H4"(fun th -> REWRITE_TAC[MATCH_MP PERMUTES_INJECTIVE th])
       THEN USE_THEN "F10" (fun th -> REWRITE_TAC[GSYM th]); ALL_TAC]
   THEN USE_THEN "F15" (MP_TAC o SPEC `a:A`)
   THEN REWRITE_TAC[]
   THEN DISCH_THEN (LABEL_TAC "F18")
   THEN USE_THEN "F15" (MP_TAC o SPEC `b:A`)
   THEN REWRITE_TAC[]
   THEN DISCH_THEN (LABEL_TAC "F19")
   THEN SUBGOAL_THEN `orbit_map (f:A->A) (a:A) = D:A->bool` (LABEL_TAC "F20")
   THENL[MATCH_MP_TAC SUBSET_ANTISYM
       THEN USE_THEN "H4" (MP_TAC o SPEC `a:A` o MATCH_MP orbit_subset)
       THEN USE_THEN "F18" (fun th -> REWRITE_TAC[th])
       THEN DISCH_THEN (fun th -> REWRITE_TAC[th])
       THEN REWRITE_TAC[SUBSET]
       THEN GEN_TAC
       THEN DISCH_TAC
       THEN USE_THEN "F15" (MP_TAC o SPEC `x:A`)
       THEN POP_ASSUM(fun th -> REWRITE_TAC[th])
       THEN STRIP_TAC
       THENL[POP_ASSUM SUBST1_TAC
	   THEN REWRITE_TAC[orbit_reflect];
	 POP_ASSUM SUBST1_TAC
	   THEN MP_TAC (SPECL[`f:A->A`; `1`; `a:A`] lemma_in_orbit)
	   THEN REWRITE_TAC[POWER_1]
	   THEN USE_THEN "F12" (SUBST1_TAC o SYM)
	   THEN SIMP_TAC[];
         POP_ASSUM SUBST1_TAC
	   THEN MP_TAC (SPECL[`f:A->A`; `2`; `a:A`] lemma_in_orbit)
	   THEN REWRITE_TAC[POWER_2; o_THM]
	   THEN USE_THEN "F12" (SUBST1_TAC o SYM)
	   THEN USE_THEN "F14" (SUBST1_TAC o SYM)
	   THEN SIMP_TAC[]]; ALL_TAC]
   THEN SUBGOAL_THEN `orbit_map (n:A->A) (a:A) = D:A->bool` (LABEL_TAC "F21")
   THENL[MATCH_MP_TAC SUBSET_ANTISYM
       THEN USE_THEN "H3" (MP_TAC o SPEC `a:A` o MATCH_MP orbit_subset)
       THEN USE_THEN "F18" (fun th -> REWRITE_TAC[th])
       THEN DISCH_THEN (fun th -> REWRITE_TAC[th])
       THEN REWRITE_TAC[SUBSET]
       THEN GEN_TAC
       THEN DISCH_TAC
       THEN USE_THEN "F15" (MP_TAC o SPEC `x:A`)
       THEN POP_ASSUM(fun th -> REWRITE_TAC[th])
       THEN STRIP_TAC
       THENL[POP_ASSUM SUBST1_TAC
	   THEN REWRITE_TAC[orbit_reflect];
	 POP_ASSUM SUBST1_TAC
	   THEN MP_TAC (SPECL[`n:A->A`; `1`; `a:A`] lemma_in_orbit)
	   THEN REWRITE_TAC[POWER_1]
	   THEN USE_THEN "F7" (SUBST1_TAC o SYM)
	   THEN SIMP_TAC[];
         POP_ASSUM SUBST1_TAC
	   THEN MP_TAC (SPECL[`n:A->A`; `2`; `a:A`] lemma_in_orbit)
	   THEN REWRITE_TAC[POWER_2; o_THM]
	   THEN USE_THEN "F7" (SUBST1_TAC o SYM)
	   THEN USE_THEN "F8" (SUBST1_TAC o SYM)
	   THEN SIMP_TAC[]]; ALL_TAC]
   THEN SUBGOAL_THEN `orbit_map (e:A->A) (b:A) = D:A->bool` (LABEL_TAC "F22")
   THENL[USE_THEN "H5" (fun th -> (MP_TAC (AP_THM th `c:A`)))
       THEN REWRITE_TAC[o_THM; I_THM]
       THEN USE_THEN "F17" (fun th -> REWRITE_TAC[th])
       THEN USE_THEN "F7" (fun th -> REWRITE_TAC[SYM th])
       THEN DISCH_THEN (LABEL_TAC "EE1")
       THEN USE_THEN "H5" (fun th -> (MP_TAC (AP_THM th `a:A`)))
       THEN REWRITE_TAC[o_THM; I_THM]
       THEN USE_THEN "F12" (fun th -> REWRITE_TAC[SYM th])
       THEN USE_THEN "F8" (fun th -> REWRITE_TAC[SYM th])
       THEN DISCH_THEN (LABEL_TAC "EE2")       
       THEN MATCH_MP_TAC SUBSET_ANTISYM
       THEN USE_THEN "H2" (MP_TAC o SPEC `b:A` o MATCH_MP orbit_subset)
       THEN USE_THEN "F19" (fun th -> REWRITE_TAC[th])
       THEN DISCH_THEN (fun th -> REWRITE_TAC[th])
       THEN REWRITE_TAC[SUBSET]
       THEN GEN_TAC
       THEN DISCH_TAC
       THEN USE_THEN "F15" (MP_TAC o SPEC `x:A`)
       THEN POP_ASSUM(fun th -> REWRITE_TAC[th])
       THEN STRIP_TAC
       THENL[POP_ASSUM SUBST1_TAC
	   THEN MP_TAC (SPECL[`e:A->A`; `2`; `b:A`] lemma_in_orbit)
	   THEN REWRITE_TAC[POWER_2; o_THM]
	   THEN USE_THEN "EE1" SUBST1_TAC
	   THEN USE_THEN "EE2" SUBST1_TAC
	   THEN SIMP_TAC[];        
         POP_ASSUM SUBST1_TAC
	   THEN REWRITE_TAC[orbit_reflect];
	 POP_ASSUM SUBST1_TAC
	   THEN MP_TAC (SPECL[`e:A->A`; `1`; `b:A`] lemma_in_orbit)
	   THEN REWRITE_TAC[POWER_1]
	   THEN USE_THEN "EE1" SUBST1_TAC
	   THEN SIMP_TAC[]]; ALL_TAC]
   THEN SUBGOAL_THEN `comb_component (H:(A)hypermap) (a:A) = dart (H:(A)hypermap)` (LABEL_TAC "F23")
   THENL[MATCH_MP_TAC SUBSET_ANTISYM
      THEN USE_THEN "F18" MP_TAC
      THEN USE_THEN "AB1" (SUBST1_TAC o SYM)
      THEN DISCH_THEN (fun th -> (REWRITE_TAC[MATCH_MP lemma_component_subset th]))
      THEN USE_THEN "AB1" (SUBST1_TAC)
      THEN USE_THEN "F21" (SUBST1_TAC o SYM)
      THEN EXPAND_TAC "n"
      THEN REWRITE_TAC[GSYM node]
      THEN REWRITE_TAC[lemma_node_subset_component]; ALL_TAC]
   THEN  REWRITE_TAC[planar_hypermap; number_of_components]
   THEN POP_ASSUM (fun th -> (REWRITE_TAC[MATCH_MP lemma_only_one_component th]))
   THEN REWRITE_TAC[number_of_nodes; number_of_edges; number_of_faces; node_set; edge_set; face_set]
   THEN USE_THEN "AB1" SUBST1_TAC
   THEN USE_THEN "F1" SUBST1_TAC
   THEN USE_THEN "AB2" SUBST1_TAC
   THEN USE_THEN "AB3" SUBST1_TAC
   THEN USE_THEN "AB4" SUBST1_TAC
   THEN USE_THEN "H1" (fun th1 -> (USE_THEN "H4" (fun th2 -> (USE_THEN "F20" (fun th3 -> (MP_TAC(MATCH_MP lemma_only_one_orbit (CONJ th1 (CONJ th2 th3)))))))))
   THEN DISCH_THEN SUBST1_TAC
   THEN USE_THEN "H1" (fun th1 -> (USE_THEN "H3" (fun th2 -> (USE_THEN "F21" (fun th3 -> (MP_TAC(MATCH_MP lemma_only_one_orbit (CONJ th1 (CONJ th2 th3)))))))))
   THEN DISCH_THEN SUBST1_TAC
   THEN USE_THEN "H1" (fun th1 -> (USE_THEN "H2" (fun th2 -> (USE_THEN "F22" (fun th3 -> (MP_TAC(MATCH_MP lemma_only_one_orbit (CONJ th1 (CONJ th2 th3)))))))))
   THEN DISCH_THEN SUBST1_TAC
   THEN REWRITE_TAC[CARD_SINGLETON]
   THEN CONV_TAC NUM_REDUCE_CONV);;
   
(* FACE_WALKUP *)

let dart_face_walkup = prove(`!(H:(A)hypermap) (x:A). dart (face_walkup H x) = (dart H) DELETE x`,
    REPEAT STRIP_TAC
    THEN REWRITE_TAC[face_walkup]
    THEN REWRITE_TAC[GSYM shift_lemma]
    THEN REWRITE_TAC[lemma_edge_walkup]
    THEN REWRITE_TAC[GSYM double_shift_lemma]);;

let lemma_card_face_walkup_dart = prove(`!(H:(A)hypermap) (x:A). x IN dart H ==> CARD(dart H) = CARD(dart(face_walkup H x)) + 1`,
     REPEAT STRIP_TAC THEN MP_TAC(SPECL[`H:(A)hypermap`; `x:A`] dart_face_walkup)
     THEN DISCH_THEN SUBST1_TAC THEN MATCH_MP_TAC CARD_MINUS_ONE
     THEN ASM_REWRITE_TAC[hypermap_lemma]);;

let face_map_face_walkup = prove(`!(H:(A)hypermap) (x:A) (y:A). face_map (face_walkup H x) x = x
/\ (~(edge_map H x = x) /\ ~(face_map H x = x) ==> face_map (face_walkup H x) (edge_map H x) = face_map H x)
/\ (~(inverse (node_map H) x = x) /\ ~(inverse (face_map H) x = x) ==> face_map (face_walkup H x) (inverse (face_map H) x) = inverse (node_map H) x)
/\ (~(y = x) /\ ~(y = inverse (face_map H) x) /\ ~(y = edge_map H x) ==> face_map (face_walkup H x) y = face_map H y)`,
   REPEAT GEN_TAC
   THEN REWRITE_TAC[face_walkup]
   THEN ONCE_REWRITE_TAC[double_shift_lemma]
   THEN REWRITE_TAC[lemma_shift_cycle]
   THEN ABBREV_TAC `G = shift (shift (H:(A)hypermap))`
   THEN REWRITE_TAC[edge_map_walkup]);;

let node_map_face_walkup = prove(`!(H:(A)hypermap) (x:A) (y:A). node_map (face_walkup H x) x = x /\ node_map (face_walkup H x) (inverse (node_map H) x) = node_map H x /\ (~(y = x) /\ ~(y = inverse (node_map H) x) ==> node_map (face_walkup H x) y = node_map H y)`,
   REPEAT GEN_TAC
   THEN REWRITE_TAC[face_walkup]
   THEN ONCE_REWRITE_TAC[double_shift_lemma]
   THEN REWRITE_TAC[lemma_shift_cycle]
   THEN ABBREV_TAC `G = shift (shift (H:(A)hypermap))`
   THEN REWRITE_TAC[face_map_walkup]);;

(* NODE_WALKUP *)

let dart_node_walkup = prove(`!(H:(A)hypermap) (x:A). dart (node_walkup H x) = (dart H) DELETE x`,
    REPEAT STRIP_TAC
    THEN REWRITE_TAC[node_walkup]
    THEN REWRITE_TAC[GSYM double_shift_lemma]
    THEN REWRITE_TAC[lemma_edge_walkup]
    THEN REWRITE_TAC[GSYM shift_lemma]);;

let lemma_card_node_walkup_dart = prove(`!(H:(A)hypermap) (x:A). x IN dart H ==> CARD(dart H) = CARD(dart(node_walkup H x)) + 1`,
     REPEAT STRIP_TAC THEN MP_TAC(SPECL[`H:(A)hypermap`; `x:A`] dart_node_walkup)
     THEN DISCH_THEN SUBST1_TAC THEN MATCH_MP_TAC CARD_MINUS_ONE
     THEN ASM_REWRITE_TAC[hypermap_lemma]);;


let node_map_node_walkup = prove(`!(H:(A)hypermap) (x:A) (y:A). node_map (node_walkup H x) x = x /\ (~(face_map H x = x) /\ ~(node_map H x = x) ==> node_map (node_walkup H x) (face_map H x) = node_map H x) /\ (~(inverse (edge_map H) x = x) /\ ~(inverse (node_map H) x = x) ==> node_map (node_walkup H x) (inverse (node_map H) x) = inverse (edge_map H) x) /\ (~(y = x) /\ ~(y = inverse (node_map H) x) /\ ~(y = face_map H x) ==> node_map (node_walkup H x) y = node_map H y)`,
   REPEAT GEN_TAC
   THEN REWRITE_TAC[node_walkup]
   THEN ONCE_REWRITE_TAC[shift_lemma]
   THEN REWRITE_TAC[lemma_shift_cycle]
   THEN ABBREV_TAC `G = shift (H:(A)hypermap)`
   THEN REWRITE_TAC[edge_map_walkup]);;

let face_map_node_walkup = prove(`!(H:(A)hypermap) (x:A) (y:A). face_map (node_walkup H x) x = x /\ face_map (node_walkup H x) (inverse (face_map H) x) = face_map H x /\ (~(y = x) /\ ~(y = inverse (face_map H) x) ==> face_map (node_walkup H x) y = face_map H y)`,
   REPEAT GEN_TAC
   THEN REWRITE_TAC[node_walkup]
   THEN ONCE_REWRITE_TAC[shift_lemma]
   THEN REWRITE_TAC[lemma_shift_cycle]
   THEN ABBREV_TAC `G = shift (H:(A)hypermap)`
   THEN REWRITE_TAC[node_map_walkup]);;

let lemma_face_walkup_second_segment_contour = prove(`!(H:(A)hypermap) (p:num->A) (k:num) (m:num). (is_inj_contour H p k /\ m < k /\ node_map H (p (m+1)) = p m) ==> is_inj_contour (face_walkup H (p m)) (shift_path p (m+1)) (k-(m+1))`,
   REPEAT GEN_TAC
   THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F1") (CONJUNCTS_THEN2 (LABEL_TAC "F2") (LABEL_TAC "F3")))
   THEN USE_THEN "F1" MP_TAC
   THEN REWRITE_TAC[lemma_def_inj_contour; lemma_def_contour]
   THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "J1") (LABEL_TAC "J2"))
   THEN STRIP_TAC
   THENL[GEN_TAC
      THEN REWRITE_TAC[lemma_sub_two_numbers]
      THEN DISCH_THEN (LABEL_TAC "J3")
      THEN REWRITE_TAC[lemma_shift_path_evaluation]
      THEN REWRITE_TAC[ARITH_RULE `((m:num) + 1) + (i:num) = m + i + 1 /\ (m+1) + SUC i = SUC (m + i + 1)`]
      THEN REMOVE_THEN "J3" (fun th -> (LABEL_TAC "J4") (MATCH_MP (ARITH_RULE `i:num < (k:num) - ((m:num) + 1) ==> m + i + 1 < k`) th))
      THEN LABEL_TAC "J5" (ARITH_RULE `m:num < m + (i:num) + 1`)
      THEN ABBREV_TAC `id = (m:num) + (i:num) + 1`
      THEN USE_THEN "J1" (MP_TAC o SPEC `id:num`)
      THEN USE_THEN "J4" (fun th -> REWRITE_TAC[th])
      THEN REWRITE_TAC[one_step_contour]
      THEN STRIP_TAC
      THENL[DISJ1_TAC
	 THEN POP_ASSUM (LABEL_TAC "J6")
	 THEN USE_THEN "J2" (MP_TAC o SPECL[`id:num`; `m:num`])
	 THEN USE_THEN "J5" (fun th -> REWRITE_TAC[th])
	 THEN USE_THEN "J4" (fun th -> REWRITE_TAC[MATCH_MP LT_IMP_LE th])
	 THEN DISCH_THEN (LABEL_TAC "J7" o GSYM)
	 THEN SUBGOAL_THEN `~((p:num->A) (id:num) = inverse (face_map (H:(A)hypermap)) ((p:num->A) (m:num)))` (LABEL_TAC "J8")
	 THENL[POP_ASSUM MP_TAC
             THEN REWRITE_TAC[CONTRAPOS_THM]
	     THEN REWRITE_TAC[GSYM face_map_inverse_representation]
	     THEN POP_ASSUM (SUBST1_TAC o SYM)
	     THEN USE_THEN "J2" (MP_TAC o SPECL[`SUC (id:num)`; `m:num`])
	     THEN USE_THEN "J5" (fun th -> REWRITE_TAC[MP (ARITH_RULE `m:num < id:num ==> m < SUC id`) th])
	     THEN USE_THEN "J4" (fun th -> REWRITE_TAC[MP (ARITH_RULE `id:num < k:num ==> SUC id <= k`) th])
	     THEN MESON_TAC[]; ALL_TAC]
	 THEN SUBGOAL_THEN `~((p:num->A) (id:num) = edge_map (H:(A)hypermap) ((p:num->A) (m:num)))` (LABEL_TAC "J9")
	 THENL[USE_THEN "J7" MP_TAC
             THEN REWRITE_TAC[CONTRAPOS_THM]
	     THEN USE_THEN "F3" (SUBST1_TAC o SYM)
	     THEN DISCH_THEN (MP_TAC o AP_TERM `face_map (H:(A)hypermap)`)
	     THEN REPLICATE_TAC 2 (GEN_REWRITE_TAC (LAND_CONV o RAND_CONV) [GSYM o_THM])
	     THEN REWRITE_TAC[GSYM o_ASSOC]
	     THEN REWRITE_TAC[hypermap_cyclic; I_THM]
	     THEN USE_THEN "J6" (SUBST1_TAC o SYM)
	     THEN USE_THEN "J2" (MP_TAC o SPECL[`SUC (id:num)`; `(m:num) + 1`])
	     THEN USE_THEN "J4" (fun th -> REWRITE_TAC[MP (ARITH_RULE `id:num < k:num ==> SUC id <= k`) th])
	     THEN USE_THEN "J5" (fun th -> REWRITE_TAC[MP (ARITH_RULE `m:num < id:num ==> m + 1 < SUC id`) th])
	     THEN MESON_TAC[]; ALL_TAC]
	 THEN MP_TAC (CONJUNCT2(CONJUNCT2(CONJUNCT2(SPECL[`H:(A)hypermap`; `(p:num->A) (m:num)`; `(p:num->A) (id:num)`] face_map_face_walkup))))
	 THEN REPLICATE_TAC 3 (POP_ASSUM (fun th -> REWRITE_TAC[th]))
	 THEN POP_ASSUM (SUBST1_TAC o SYM)
	 THEN REWRITE_TAC[EQ_SYM]; ALL_TAC]
      THEN DISJ2_TAC
      THEN POP_ASSUM MP_TAC
      THEN REWRITE_TAC[GSYM node_map_inverse_representation]
      THEN DISCH_THEN (LABEL_TAC "J10")
      THEN USE_THEN "J2" (MP_TAC o SPECL[`SUC (id:num)`; `m:num`])
      THEN USE_THEN "J4" (fun th -> REWRITE_TAC[MP (ARITH_RULE `id:num < k:num ==> SUC id <= k`) th])
      THEN USE_THEN "J5" (fun th -> REWRITE_TAC[MP (ARITH_RULE `m:num < id:num ==> m < SUC id`) th])
      THEN DISCH_THEN (LABEL_TAC "J11" o GSYM)
      THEN SUBGOAL_THEN `~((p:num->A) (SUC (id:num)) = inverse (node_map (H:(A)hypermap)) ((p:num->A) (m:num)))` (LABEL_TAC "J12")
      THENL[POP_ASSUM MP_TAC
	 THEN REWRITE_TAC[CONTRAPOS_THM]
	 THEN REWRITE_TAC[GSYM node_map_inverse_representation]
	 THEN POP_ASSUM (SUBST1_TAC o SYM)
	 THEN USE_THEN "J2" (MP_TAC o SPECL[`id:num`; `m:num`])
	 THEN USE_THEN "J5" (fun th -> REWRITE_TAC[th])
	 THEN USE_THEN "J4" (fun th -> REWRITE_TAC[MATCH_MP LT_IMP_LE th])
	 THEN MESON_TAC[]; ALL_TAC]
      THEN MP_TAC (CONJUNCT2(CONJUNCT2(SPECL[`H:(A)hypermap`; `(p:num->A) (m:num)`; `(p:num->A) (SUC (id:num))`] node_map_face_walkup)))
      THEN POP_ASSUM (fun th -> REWRITE_TAC[th])
      THEN POP_ASSUM (fun th -> REWRITE_TAC[th])
      THEN POP_ASSUM (SUBST1_TAC o SYM)
      THEN REWRITE_TAC[EQ_SYM]; ALL_TAC]
   THEN REWRITE_TAC[lemma_shift_path_evaluation]
   THEN REPEAT GEN_TAC
   THEN REWRITE_TAC[lemma_sub_two_numbers]
   THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "K1") (LABEL_TAC "K2"))
   THEN USE_THEN "J2" (MP_TAC o SPECL[`((m:num) + 1) + (i:num)`; `((m:num)+1)+(j:num)`])
   THEN USE_THEN "K1" (fun th -> (USE_THEN "F2" (fun th1->  REWRITE_TAC[MP (ARITH_RULE `i:num <= (k:num) - ((m:num) + 1) /\ m < k ==> (m + 1) + i <= k`) (CONJ th th1)])))
   THEN USE_THEN "K2" (fun th -> REWRITE_TAC[MP (ARITH_RULE `j:num < i:num ==> ((m:num) + 1) + j < (m + 1) + i`) th])
  );;


let lemma_face_walkup_eliminate_dart_on_Moebius_contour = prove(`!(H:(A)hypermap) (p:num->A) (k:num) (m:num). (is_inj_contour H p k /\ 0 < m /\ m < k /\ node_map H (p (m+1)) = p m) ==> is_inj_contour (face_walkup H (p m)) p (m-1) /\ is_inj_contour (face_walkup H (p m)) (shift_path p (m+1)) (k-m-1)
/\ one_step_contour (face_walkup H (p m)) (p (m-1)) (p (m+1))`,
   REPEAT GEN_TAC
   THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F1") (CONJUNCTS_THEN2 (LABEL_TAC "F2") (CONJUNCTS_THEN2 (LABEL_TAC "F3") (LABEL_TAC "F4"))))
   THEN STRIP_TAC
   THENL[USE_THEN "F1" (MP_TAC o SPEC `(m:num)-1` o MATCH_MP lemma_sub_inj_contour)
       THEN USE_THEN "F3" (fun th -> REWRITE_TAC[MATCH_MP (ARITH_RULE `m:num < k:num ==> m - 1 <= k`) th])
       THEN REWRITE_TAC[lemma_def_inj_contour; lemma_def_contour]
       THEN SIMP_TAC[]
       THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "G1") (LABEL_TAC "G2"))
       THEN STRIP_TAC
       THEN DISCH_THEN (LABEL_TAC "G3")
       THEN USE_THEN "G1" (MP_TAC o SPEC `i:num`)
       THEN USE_THEN "G3" (fun th -> REWRITE_TAC[th])
       THEN USE_THEN "F1" MP_TAC
       THEN REWRITE_TAC[lemma_def_inj_contour; lemma_def_contour]
       THEN DISCH_THEN (LABEL_TAC "G4" o CONJUNCT2)
       THEN USE_THEN "G4" (MP_TAC o SPECL[`m:num`; `i:num`])
       THEN USE_THEN "G3" (fun th -> REWRITE_TAC[MATCH_MP (ARITH_RULE `i:num < (m:num) - 1 ==> i < m`) th])
       THEN USE_THEN "F3" (fun th -> REWRITE_TAC[MATCH_MP LT_IMP_LE th])
       THEN DISCH_THEN (LABEL_TAC "G5")
       THEN REWRITE_TAC[one_step_contour]
       THEN STRIP_TAC
       THENL[DISJ1_TAC
	   THEN POP_ASSUM (LABEL_TAC "G6")
	   THEN SUBGOAL_THEN `~((p:num->A) (i:num) = inverse (face_map H) (p (m:num)))` (LABEL_TAC "G7")
	   THENL[USE_THEN "G4" (MP_TAC o SPECL[`m:num`; `SUC (i:num)`])
	       THEN USE_THEN "G3" (fun th -> (REWRITE_TAC[MATCH_MP (ARITH_RULE `i:num < (m:num) - 1 ==> SUC i < m`) th]))
	       THEN USE_THEN "F3" (fun th -> (REWRITE_TAC[MATCH_MP LT_IMP_LE th]))
	       THEN REWRITE_TAC[CONTRAPOS_THM]
	       THEN REWRITE_TAC[GSYM face_map_inverse_representation]
	       THEN USE_THEN "G6" (SUBST1_TAC o SYM)
	       THEN REWRITE_TAC[EQ_SYM]; ALL_TAC]
	   THEN SUBGOAL_THEN `~((p:num->A) (i:num) = (edge_map H) (p (m:num)))` (LABEL_TAC "G8")
	   THENL[POP_ASSUM MP_TAC
	       THEN REWRITE_TAC[CONTRAPOS_THM]
	       THEN DISCH_TAC
	       THEN REMOVE_THEN "G6" MP_TAC
	       THEN POP_ASSUM SUBST1_TAC
	       THEN DISCH_THEN (MP_TAC o AP_TERM `node_map (H:(A)hypermap)`)
	       THEN GEN_REWRITE_TAC (LAND_CONV o RAND_CONV) [GSYM o_THM]
	       THEN GEN_REWRITE_TAC (LAND_CONV o RAND_CONV) [GSYM o_THM]
	       THEN REWRITE_TAC[GSYM o_ASSOC]
	       THEN REWRITE_TAC[hypermap_cyclic; I_THM]
	       THEN USE_THEN "F4" (SUBST1_TAC o SYM)
	       THEN REWRITE_TAC[node_map_injective; ADD1]
	       THEN DISCH_TAC
	       THEN USE_THEN "G4" (MP_TAC o SPECL[`(m:num) + 1`; `(i:num) + 1`])
	       THEN USE_THEN "F3" (fun th -> REWRITE_TAC[MATCH_MP (ARITH_RULE `(m:num) < k:num ==> m+ 1 <= k:num`) th])
	       THEN USE_THEN "G3" (fun th -> REWRITE_TAC[MATCH_MP (ARITH_RULE `i:num < (m:num) -1 ==> i+ 1 < m+1`) th])
	       THEN POP_ASSUM (fun th -> REWRITE_TAC[th]); ALL_TAC]
	   THEN MP_TAC (CONJUNCT2(CONJUNCT2(CONJUNCT2(SPECL[`H:(A)hypermap`; `(p:num->A) (m:num)`; `(p:num->A) (i:num)`] face_map_face_walkup))))
	   THEN ASM_REWRITE_TAC[EQ_SYM]; ALL_TAC]
       THEN DISJ2_TAC
       THEN POP_ASSUM MP_TAC
       THEN REWRITE_TAC[GSYM node_map_inverse_representation]
       THEN DISCH_THEN (LABEL_TAC "G10")
       THEN USE_THEN "G4" (MP_TAC o SPECL[`m:num`; `SUC (i:num)`])
       THEN USE_THEN "F3" (fun th -> REWRITE_TAC[MATCH_MP LT_IMP_LE th])
       THEN USE_THEN "G3" (fun th -> REWRITE_TAC[MATCH_MP (ARITH_RULE `i:num < (m:num) -1 ==> SUC i < m`) th])
       THEN DISCH_THEN (LABEL_TAC"G11")
       THEN SUBGOAL_THEN `~((p:num->A) (SUC (i:num)) = inverse (node_map (H:(A)hypermap)) ((p:num->A) (m:num)))` (LABEL_TAC "G12")
       THENL[POP_ASSUM MP_TAC
	   THEN REWRITE_TAC[CONTRAPOS_THM]
	   THEN REWRITE_TAC[GSYM node_map_inverse_representation]
	   THEN POP_ASSUM (SUBST1_TAC o SYM)
	   THEN POP_ASSUM (fun th -> REWRITE_TAC[GSYM th]); ALL_TAC]
       THEN MP_TAC (CONJUNCT2(CONJUNCT2(SPECL[`H:(A)hypermap`; `(p:num->A) (m:num)`; `(p:num->A) (SUC (i:num))`] node_map_face_walkup)))
       THEN POP_ASSUM (fun th -> REWRITE_TAC[th])
       THEN POP_ASSUM (fun th -> REWRITE_TAC[th])
       THEN POP_ASSUM (SUBST1_TAC o SYM)
       THEN REWRITE_TAC[EQ_SYM]; ALL_TAC]
   THEN REWRITE_TAC[lemma_sub_two_numbers]
   THEN USE_THEN "F1" (fun th1 -> (USE_THEN "F3" (fun th2 -> (USE_THEN "F4" (fun th3 -> (REWRITE_TAC[MATCH_MP lemma_face_walkup_second_segment_contour (CONJ th1 (CONJ th2 th3))]))))))
   THEN USE_THEN "F1" MP_TAC
   THEN REWRITE_TAC[lemma_def_inj_contour]
   THEN DISCH_THEN (CONJUNCTS_THEN2 (MP_TAC) (LABEL_TAC "FF"))
   THEN REWRITE_TAC[lemma_def_contour]
   THEN DISCH_THEN (MP_TAC o SPEC `(m:num) - 1`)
   THEN USE_THEN "F3" (fun th -> REWRITE_TAC[MP (ARITH_RULE `m:num < k:num ==> m - 1 < k`) th])
   THEN REWRITE_TAC[lemma_one_step_contour]
   THEN USE_THEN "F2" (fun th -> REWRITE_TAC[MATCH_MP (ARITH_RULE `0 < m:num ==> SUC (m-1) = m`) th])
   THEN STRIP_TAC
   THENL[DISJ1_TAC
       THEN POP_ASSUM MP_TAC
       THEN GEN_REWRITE_TAC (LAND_CONV o DEPTH_CONV) [face_map_inverse_representation]
       THEN DISCH_THEN (LABEL_TAC "L1")
       THEN USE_THEN "F4" (MP_TAC o SYM)
       THEN GEN_REWRITE_TAC (LAND_CONV o DEPTH_CONV) [node_map_inverse_representation]
       THEN DISCH_THEN (LABEL_TAC "L2")
       THEN USE_THEN "FF" (MP_TAC o SPECL[`m:num`; `(m:num)-1`])
       THEN USE_THEN "F3" (fun th -> REWRITE_TAC[MATCH_MP LT_IMP_LE th])
       THEN USE_THEN "F2" (fun th -> REWRITE_TAC[MATCH_MP (ARITH_RULE `0 < m:num ==> m - 1 < m`) th])
       THEN USE_THEN "L1" SUBST1_TAC
       THEN DISCH_THEN (LABEL_TAC "L3")
       THEN USE_THEN "FF" (MP_TAC o GSYM o  SPECL[`(m:num)+1`; `(m:num)`])
       THEN USE_THEN "F3" (fun th -> REWRITE_TAC[MP (ARITH_RULE `m:num < k:num ==> m + 1 <= k`) th])
       THEN REWRITE_TAC[ARITH_RULE ` m:num < m + 1`]
       THEN USE_THEN "L2" SUBST1_TAC
       THEN DISCH_THEN (LABEL_TAC "L4")
       THEN MP_TAC (CONJUNCT1(CONJUNCT2(CONJUNCT2(SPECL[`H:(A)hypermap`; `(p:num->A) (m:num)`; `(p:num->A) (m:num)`] face_map_face_walkup))))
       THEN POP_ASSUM (fun th -> REWRITE_TAC[th])
       THEN POP_ASSUM (fun th -> REWRITE_TAC[th])
       THEN REWRITE_TAC[EQ_SYM]; ALL_TAC]
   THEN DISJ2_TAC
   THEN POP_ASSUM SUBST1_TAC
   THEN USE_THEN "F4" (MP_TAC o SYM)
   THEN GEN_REWRITE_TAC (LAND_CONV o DEPTH_CONV) [node_map_inverse_representation]
   THEN DISCH_THEN SUBST1_TAC
   THEN REWRITE_TAC[node_map_face_walkup]
);;

(* FORMULATE THIS LEMMA FOR f STEP *)

let lemma_node_walkup_second_segment_contour = prove(`!(H:(A)hypermap) (p:num->A) (k:num) (m:num). is_inj_contour H p k /\ m < k /\ p (m+1) = face_map H (p m) ==> is_inj_contour (node_walkup H (p m)) (shift_path p (m+1)) (k-(m+1))`,
   REPEAT GEN_TAC
   THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F1") (CONJUNCTS_THEN2 (LABEL_TAC "F2") (LABEL_TAC "F3")))
   THEN REWRITE_TAC[lemma_sub_two_numbers]
   THEN ASM_CASES_TAC `k:num = ((m:num) + 1)`
   THENL[POP_ASSUM SUBST1_TAC THEN REWRITE_TAC[SUB_REFL; is_inj_contour]; ALL_TAC]
  THEN POP_ASSUM (fun th -> (USE_THEN "F2"(fun th2 -> (LABEL_TAC "F4" (MATCH_MP (ARITH_RULE `m:num < k:num /\ ~(k = m+1) ==> m + 1 < k`) (CONJ th2 th))))))
   THEN USE_THEN "F1" MP_TAC
   THEN REWRITE_TAC[lemma_def_inj_contour]
   THEN DISCH_THEN (CONJUNCTS_THEN2 (MP_TAC) (LABEL_TAC "F5"))
   THEN REWRITE_TAC[lemma_def_contour]
   THEN DISCH_THEN (LABEL_TAC "F6")
   THEN STRIP_TAC
   THENL[GEN_TAC
       THEN DISCH_THEN (LABEL_TAC "F7")
       THEN REWRITE_TAC[lemma_shift_path_evaluation]
       THEN USE_THEN "F6" (MP_TAC o SPEC `((m:num)+1) + (i:num)`)
       THEN USE_THEN "F7" (fun th1 -> (USE_THEN "F4" (fun th2 -> (LABEL_TAC "F8" (MATCH_MP (ARITH_RULE `i:num < (k:num) - ((m:num) + 1) /\ m + 1 < k ==> (m+1)+ i < k`) (CONJ th1 th2))))))
       THEN ABBREV_TAC `id = ((m:num) + 1) + (i:num)`
       THEN POP_ASSUM (LABEL_TAC "F9")
       THEN USE_THEN "F8" (fun th -> REWRITE_TAC[th])
       THEN REWRITE_TAC[ADD_SUC]
       THEN USE_THEN "F9" (SUBST1_TAC)
       THEN REWRITE_TAC[lemma_one_step_contour]
       THEN CONV_TAC (ONCE_REWRITE_CONV[DISJ_SYM])
       THEN STRIP_TAC
       THENL[DISJ1_TAC
          THEN POP_ASSUM (LABEL_TAC "F10")
	  THEN USE_THEN "F5" (MP_TAC o SPECL[`SUC (id:num)`; `m:num`])
	  THEN USE_THEN "F8" (fun th -> REWRITE_TAC[MATCH_MP (ARITH_RULE `id:num < k:num ==> SUC id <= k`) th])
	  THEN USE_THEN "F9" (fun th -> REWRITE_TAC[MATCH_MP (ARITH_RULE `((m:num) + 1) + (i:num) = id ==> m < SUC id`) th])
	  THEN DISCH_THEN (LABEL_TAC "F11" o GSYM)
	  THEN SUBGOAL_THEN `~((p:num->A) (SUC (id:num)) = face_map (H:(A)hypermap) ((p:num->A) (m:num)))` (LABEL_TAC "F12")
	  THENL[USE_THEN "F11" MP_TAC
	      THEN REWRITE_TAC[CONTRAPOS_THM]
	      THEN USE_THEN "F3" (SUBST1_TAC o SYM)
	      THEN USE_THEN "F5" (MP_TAC o SPECL[`SUC (id:num)`; `(m:num) + 1`])
	      THEN USE_THEN "F8" (fun th -> REWRITE_TAC[MATCH_MP (ARITH_RULE `id:num < k:num ==> SUC id <= k`) th])
	      THEN USE_THEN "F9" (fun th -> REWRITE_TAC[MATCH_MP (ARITH_RULE `((m:num) + 1) + (i:num) = id ==> m + 1 < SUC id`) th])
	      THEN MESON_TAC[]; ALL_TAC]
	  THEN SUBGOAL_THEN `~((p:num->A) (SUC (id:num)) = inverse (node_map (H:(A)hypermap)) ((p:num->A) (m:num)))` (LABEL_TAC "F14")
	  THENL[USE_THEN "F12" MP_TAC
	      THEN REWRITE_TAC[CONTRAPOS_THM]
	      THEN REWRITE_TAC[GSYM node_map_inverse_representation]
	      THEN USE_THEN "F10" (SUBST1_TAC o SYM)
	      THEN USE_THEN "F5" (MP_TAC o SPECL[`(id:num)`; `(m:num)`])
	      THEN USE_THEN "F8" (fun th -> REWRITE_TAC[MATCH_MP LT_IMP_LE th])
	      THEN USE_THEN "F9" (fun th -> REWRITE_TAC[MATCH_MP (ARITH_RULE `((m:num) + 1) + (i:num) = id ==> m < id`) th])
	      THEN MESON_TAC[]; ALL_TAC]
	  THEN MP_TAC (CONJUNCT2(CONJUNCT2(CONJUNCT2(SPECL[`H:(A)hypermap`; `(p:num->A) (m:num)`; `(p:num->A) (SUC (id:num))`] node_map_node_walkup))))
	  THEN REPLICATE_TAC 3 (POP_ASSUM (fun th -> REWRITE_TAC[th]))
	  THEN POP_ASSUM (SUBST1_TAC o SYM)
	  THEN REWRITE_TAC[EQ_SYM]; ALL_TAC]
       THEN DISJ2_TAC
       THEN POP_ASSUM (LABEL_TAC "F10")
       THEN USE_THEN "F5" (MP_TAC o SPECL[`id:num`; `m:num`])
       THEN USE_THEN "F8" (fun th -> REWRITE_TAC[MATCH_MP LT_IMP_LE th])
       THEN USE_THEN "F9" (fun th -> REWRITE_TAC[MATCH_MP (ARITH_RULE `((m:num) + 1) + (i:num) = id ==> m < id`) th])
       THEN DISCH_TAC
       THEN SUBGOAL_THEN  `~((p:num->A) (id:num) = inverse (face_map (H:(A)hypermap)) ((p:num->A) (m:num)))` ASSUME_TAC
       THENL[POP_ASSUM MP_TAC
           THEN REWRITE_TAC[CONTRAPOS_THM]
           THEN REWRITE_TAC[GSYM face_map_inverse_representation]
           THEN POP_ASSUM (SUBST1_TAC o SYM)
           THEN USE_THEN "F5" (MP_TAC o SPECL[`SUC (id:num)`; `m:num`])
           THEN USE_THEN "F8" (fun th -> REWRITE_TAC[MATCH_MP (ARITH_RULE `id:num < k:num ==> SUC id <= k`) th])
           THEN USE_THEN "F9" (fun th -> REWRITE_TAC[MATCH_MP (ARITH_RULE `((m:num) + 1) + (i:num) = id ==> m  < SUC  id`) th])
           THEN MESON_TAC[]; ALL_TAC]
       THEN MP_TAC (CONJUNCT2(CONJUNCT2(SPECL[`H:(A)hypermap`; `(p:num->A) (m:num)`; `(p:num->A) (id:num)`] face_map_node_walkup)))
       THEN REPLICATE_TAC 2 (POP_ASSUM (fun th -> REWRITE_TAC[th]))
       THEN POP_ASSUM (SUBST1_TAC o SYM)
       THEN REWRITE_TAC[EQ_SYM]; ALL_TAC]
   THEN REWRITE_TAC[lemma_shift_path_evaluation]
   THEN REPEAT GEN_TAC
   THEN REWRITE_TAC[lemma_sub_two_numbers]
   THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "K1") (LABEL_TAC "K2"))
   THEN USE_THEN "F5" (MP_TAC o SPECL[`((m:num) + 1) + (i:num)`; `((m:num)+1)+(j:num)`])
   THEN USE_THEN "K1" (fun th -> (USE_THEN "F2" (fun th1->  REWRITE_TAC[MP (ARITH_RULE `i:num <= (k:num) - ((m:num) + 1) /\ m < k ==> (m + 1) + i <= k`) (CONJ th th1)])))
   THEN USE_THEN "K2" (fun th -> REWRITE_TAC[MP (ARITH_RULE `j:num < i:num ==> ((m:num) + 1) + j < (m + 1) + i`) th])
  );;

let lemma_node_walkup_eliminate_dart_on_Moebius_contour = prove(`!(H:(A)hypermap) (p:num->A) (k:num) (m:num). is_inj_contour H p k /\ 0 < m /\ m < k /\ p (m+1) = face_map H (p m) ==> is_inj_contour (node_walkup H (p m)) p (m-1) /\ is_inj_contour (node_walkup H (p m)) (shift_path p (m+1)) (k-m-1)
/\ one_step_contour (node_walkup H (p m)) (p (m-1)) (p (m+1))`,
   REPEAT GEN_TAC
   THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F1") (CONJUNCTS_THEN2 (LABEL_TAC "F2") (CONJUNCTS_THEN2 (LABEL_TAC "F3") (LABEL_TAC "F4"))))
   THEN STRIP_TAC
   THENL[USE_THEN "F1" (MP_TAC o SPEC `(m:num)-1` o MATCH_MP lemma_sub_inj_contour)
       THEN USE_THEN "F3" (fun th -> REWRITE_TAC[MATCH_MP (ARITH_RULE `m:num < k:num ==> m - 1 <= k`) th])
       THEN REWRITE_TAC[lemma_def_inj_contour; lemma_def_contour]
       THEN SIMP_TAC[]
       THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "G1") (LABEL_TAC "G2"))
       THEN STRIP_TAC
       THEN DISCH_THEN (LABEL_TAC "G3")
       THEN USE_THEN "G1" (MP_TAC o SPEC `i:num`)
       THEN USE_THEN "G3" (fun th -> REWRITE_TAC[th])
       THEN USE_THEN "F1" MP_TAC
       THEN REWRITE_TAC[lemma_def_inj_contour; lemma_def_contour]
       THEN DISCH_THEN (LABEL_TAC "G4" o CONJUNCT2)
       THEN USE_THEN "G4" (MP_TAC o SPECL[`m:num`; `SUC (i:num)`])
       THEN USE_THEN "G3" (fun th -> (USE_THEN "F2"(fun th2 ->  REWRITE_TAC[MATCH_MP (ARITH_RULE `i:num < (m:num) - 1 /\ 0 < m ==> SUC i < m`) (CONJ th th2)])))
       THEN USE_THEN "F3" (fun th -> REWRITE_TAC[MATCH_MP LT_IMP_LE th])
       THEN DISCH_THEN (LABEL_TAC "G5")
       THEN REWRITE_TAC[one_step_contour]
       THEN GEN_REWRITE_TAC (LAND_CONV o ONCE_DEPTH_CONV) [DISJ_SYM]
       THEN STRIP_TAC
       THENL[DISJ2_TAC
	   THEN POP_ASSUM (LABEL_TAC "G6")
	   THEN SUBGOAL_THEN `~((p:num->A) (SUC (i:num)) = inverse (node_map H) (p (m:num)))` (LABEL_TAC "G7")
	   THENL[USE_THEN "G5" MP_TAC
	       THEN REWRITE_TAC[CONTRAPOS_THM]
	       THEN POP_ASSUM MP_TAC
	       THEN REWRITE_TAC[GSYM node_map_inverse_representation]
	       THEN DISCH_THEN (SUBST1_TAC o SYM)
	       THEN USE_THEN "G4" (MP_TAC o SPECL[`m:num`; `i:num`])
	       THEN USE_THEN "G3" (fun th -> (REWRITE_TAC[MATCH_MP (ARITH_RULE `i:num < (m:num) - 1 ==> i < m`) th]))
	       THEN USE_THEN "F3" (fun th -> (REWRITE_TAC[MATCH_MP LT_IMP_LE th]))
	       THEN MESON_TAC[]; ALL_TAC]
	   THEN SUBGOAL_THEN `~((p:num->A) (SUC(i:num)) = (face_map H) (p (m:num)))` (LABEL_TAC "G8")
	   THENL[POP_ASSUM MP_TAC
	       THEN REWRITE_TAC[CONTRAPOS_THM]
	       THEN USE_THEN "F4" (SUBST1_TAC o SYM)
	       THEN DISCH_TAC
	       THEN USE_THEN "G4" (MP_TAC o SPECL[`(m:num) + 1`; `SUC (i:num)`])
	       THEN USE_THEN "F3" (fun th -> REWRITE_TAC[MATCH_MP (ARITH_RULE `(m:num) < k:num ==> m+ 1 <= k:num`) th])
	       THEN USE_THEN "G3" (fun th -> REWRITE_TAC[MATCH_MP (ARITH_RULE `i:num < (m:num) -1 ==> SUC i < m+1`) th])
	       THEN POP_ASSUM (fun th -> REWRITE_TAC[th]); ALL_TAC]
	   THEN MP_TAC (CONJUNCT2(CONJUNCT2(CONJUNCT2(SPECL[`H:(A)hypermap`; `(p:num->A) (m:num)`; `(p:num->A) (SUC (i:num))`] node_map_node_walkup))))
	   THEN REPLICATE_TAC 2(POP_ASSUM (fun th -> REWRITE_TAC[th]))
	   THEN USE_THEN "G5" (fun th -> REWRITE_TAC[th])
	   THEN POP_ASSUM MP_TAC
	   THEN GEN_REWRITE_TAC (LAND_CONV o DEPTH_CONV) [GSYM node_map_inverse_representation]
	   THEN ASM_REWRITE_TAC[EQ_SYM]
	   THEN DISCH_THEN (SUBST1_TAC o SYM)
	   THEN REWRITE_TAC[GSYM node_map_inverse_representation; EQ_SYM]; ALL_TAC]
       THEN DISJ1_TAC
       THEN POP_ASSUM (LABEL_TAC "G10")
       THEN USE_THEN "G4" (MP_TAC o SPECL[`m:num`; `(i:num)`])
       THEN USE_THEN "F3" (fun th -> REWRITE_TAC[MATCH_MP LT_IMP_LE th])
       THEN USE_THEN "G3" (fun th -> REWRITE_TAC[MATCH_MP (ARITH_RULE `i:num < (m:num) -1 ==> i < m`) th])
       THEN DISCH_THEN (LABEL_TAC"G11")
       THEN SUBGOAL_THEN `~((p:num->A) (i:num) = inverse (face_map (H:(A)hypermap)) ((p:num->A) (m:num)))` (LABEL_TAC "G12")
       THENL[POP_ASSUM MP_TAC
	   THEN REWRITE_TAC[CONTRAPOS_THM]
	   THEN REWRITE_TAC[GSYM face_map_inverse_representation]
	   THEN POP_ASSUM (SUBST1_TAC o SYM)
	   THEN POP_ASSUM (fun th -> REWRITE_TAC[GSYM th]); ALL_TAC]
       THEN MP_TAC (CONJUNCT2(CONJUNCT2(SPECL[`H:(A)hypermap`; `(p:num->A) (m:num)`; `(p:num->A) (i:num)`] face_map_node_walkup)))
       THEN POP_ASSUM (fun th -> REWRITE_TAC[th])
       THEN POP_ASSUM (fun th -> REWRITE_TAC[th])
       THEN POP_ASSUM (SUBST1_TAC o SYM)
       THEN REWRITE_TAC[EQ_SYM]; ALL_TAC]
   THEN REWRITE_TAC[lemma_sub_two_numbers]
   THEN USE_THEN "F1" (fun th1 -> (USE_THEN "F3" (fun th2 -> (USE_THEN "F4" (fun th3 -> (REWRITE_TAC[MATCH_MP lemma_node_walkup_second_segment_contour (CONJ th1 (CONJ th2 th3))]))))))
   THEN USE_THEN "F1" MP_TAC
   THEN REWRITE_TAC[lemma_def_inj_contour]
   THEN DISCH_THEN (CONJUNCTS_THEN2 (MP_TAC) (LABEL_TAC "FF"))
   THEN REWRITE_TAC[lemma_def_contour]
   THEN DISCH_THEN (MP_TAC o SPEC `(m:num) - 1`)
   THEN USE_THEN "F3" (fun th -> REWRITE_TAC[MP (ARITH_RULE `m:num < k:num ==> m - 1 < k`) th])
   THEN REWRITE_TAC[lemma_one_step_contour]
   THEN USE_THEN "F2" (fun th -> REWRITE_TAC[MATCH_MP (ARITH_RULE `0 < m:num ==> SUC (m-1) = m`) th])
   THEN CONV_TAC (ONCE_REWRITE_CONV[DISJ_SYM])
   THEN STRIP_TAC
   THENL[DISJ1_TAC
       THEN POP_ASSUM MP_TAC
       THEN DISCH_THEN (LABEL_TAC "L1")
       THEN USE_THEN "FF" (MP_TAC o SPECL[`m:num`; `(m:num)-1`])
       THEN USE_THEN "F3" (fun th -> REWRITE_TAC[MATCH_MP LT_IMP_LE th])
       THEN USE_THEN "F2" (fun th -> REWRITE_TAC[MATCH_MP (ARITH_RULE `0 < m:num ==> m - 1 < m`) th])
       THEN USE_THEN "L1" SUBST1_TAC
       THEN DISCH_THEN (LABEL_TAC "L3")
       THEN USE_THEN "FF" (MP_TAC o GSYM o  SPECL[`(m:num)+1`; `(m:num)`])
       THEN USE_THEN "F3" (fun th -> REWRITE_TAC[MP (ARITH_RULE `m:num < k:num ==> m + 1 <= k`) th])
       THEN REWRITE_TAC[ARITH_RULE ` m:num < m + 1`]
       THEN USE_THEN "F4" SUBST1_TAC
       THEN DISCH_THEN (LABEL_TAC "L4")
       THEN MP_TAC (CONJUNCT1(CONJUNCT2(SPECL[`H:(A)hypermap`; `(p:num->A) (m:num)`; `(p:num->A) (m:num)`] node_map_node_walkup)))
       THEN REPLICATE_TAC 2 (POP_ASSUM (fun th -> REWRITE_TAC[th]))
       THEN REWRITE_TAC[EQ_SYM]; ALL_TAC]
   THEN DISJ2_TAC
   THEN POP_ASSUM  MP_TAC
   THEN GEN_REWRITE_TAC (LAND_CONV o DEPTH_CONV) [face_map_inverse_representation]
   THEN DISCH_THEN SUBST1_TAC
   THEN USE_THEN "F4" SUBST1_TAC
   THEN REWRITE_TAC[face_map_node_walkup]
  );;


(* THE COMBINATORIAL JORDAN CURVE THEOREM *)

let lemmaLIPYTUI = prove(`!(H:(A)hypermap). planar_hypermap H ==> ~(?(p:num->A) k:num. is_Moebius_contour H p k)`,
   GEN_TAC
   THEN ABBREV_TAC `n = CARD (dart (H:(A)hypermap))`
   THEN POP_ASSUM MP_TAC
   THEN REWRITE_TAC[IMP_IMP]
   THEN SPEC_TAC (`H:(A)hypermap`, `H:(A)hypermap`)
   THEN SPEC_TAC (`n:num`, `n:num`)
   THEN INDUCT_TAC
   THENL[REPEAT STRIP_TAC
      THEN POP_ASSUM (MP_TAC o CONJUNCT2 o CONJUNCT2 o MATCH_MP lemma_darts_on_Moebius_contour)
      THEN DISCH_THEN (MP_TAC o MATCH_MP (ARITH_RULE `SUC (k:num) <= l:num ==> ~(l = 0)`))
      THEN ASM_REWRITE_TAC[]; ALL_TAC]
   THEN POP_ASSUM (LABEL_TAC "FI")   
   THEN GEN_TAC
     THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F1") (LABEL_TAC "F2"))
     THEN STRIP_TAC
     THEN POP_ASSUM (LABEL_TAC "F3")
     THEN USE_THEN "F3" (MP_TAC o MATCH_MP lemma_Moebius_contour_points_subset_darts)
     THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F4") (LABEL_TAC "F5"))
     THEN LABEL_TAC "F6" (CONJUNCT1(SPEC `H:(A)hypermap` hypermap_lemma))
   THEN ASM_CASES_TAC `~({(p:num->A) (i:num) | i <= (k:num)} = dart (H:(A)hypermap))`
   THENL[POP_ASSUM MP_TAC
       THEN USE_THEN "F4" MP_TAC
       THEN REWRITE_TAC[IMP_IMP; GSYM PSUBSET]
       THEN REWRITE_TAC[PSUBSET_MEMBER]
       THEN USE_THEN "F4" (fun th -> REWRITE_TAC[th])
       THEN STRIP_TAC
       THEN POP_ASSUM (fun th1 -> (USE_THEN "F3" (fun th2 -> (MP_TAC (MATCH_MP lemma_eliminate_dart_ouside_Moebius_contour (CONJ th2 th1))))))
       THEN FIRST_ASSUM  (MP_TAC o (SPEC `edge_walkup (H:(A)hypermap) (y:A)`))
       THEN REWRITE_TAC[]
       THEN POP_ASSUM (fun th -> (MP_TAC (MATCH_MP lemma_card_walkup_dart th) THEN ASSUME_TAC th))
       THEN USE_THEN "F1" (fun th -> REWRITE_TAC[th; GSYM ADD1; EQ_SUC])
       THEN DISCH_THEN (fun th -> REWRITE_TAC[SYM th])
       THEN POP_ASSUM (fun th1 -> (USE_THEN "F2" (fun th2 -> REWRITE_TAC[MATCH_MP lemmaSGCOSXK (CONJ th1 th2)])))
       THEN REWRITE_TAC[CONTRAPOS_THM]
       THEN STRIP_TAC
       THEN EXISTS_TAC `p:num->A` THEN EXISTS_TAC `k:num`
       THEN POP_ASSUM (fun th -> REWRITE_TAC[th]); ALL_TAC]
   THEN POP_ASSUM MP_TAC
   THEN REWRITE_TAC[]
   THEN USE_THEN "F3" MP_TAC
   THEN REWRITE_TAC[is_Moebius_contour]
   THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F7") (LABEL_TAC "F8"))
   THEN USE_THEN "F7" MP_TAC
   THEN REWRITE_TAC[lemma_def_inj_contour]
   THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F9") (LABEL_TAC "F10"))
   THEN DISCH_THEN (LABEL_TAC "F11")
   THEN REMOVE_THEN "F8" (X_CHOOSE_THEN `m:num` (X_CHOOSE_THEN `t:num` (CONJUNCTS_THEN2 (LABEL_TAC "F12") (CONJUNCTS_THEN2 (LABEL_TAC "F14") (CONJUNCTS_THEN2 (LABEL_TAC "F15") (CONJUNCTS_THEN2 (LABEL_TAC "F16") (LABEL_TAC "F16k")))))))
   THEN USE_THEN "F9" MP_TAC
   THEN REWRITE_TAC[lemma_def_contour]
   THEN DISCH_THEN (LABEL_TAC "F17")
   THEN ASM_CASES_TAC `m:num < t:num`
   THENL[POP_ASSUM (fun th -> (LABEL_TAC "G1" (MATCH_MP (ARITH_RULE `m:num < t:num ==> SUC m <= t`) th)))
	THEN USE_THEN "F17" (MP_TAC o SPEC `m:num`)
	THEN USE_THEN "F14" (fun th1 -> (USE_THEN "F15" (fun th2 -> (LABEL_TAC "G2" (MP (ARITH_RULE `m:num <= t:num /\ t < k:num ==> m < k`) (CONJ th1 th2))))))
	THEN USE_THEN "G2" (fun th -> REWRITE_TAC[th])
	THEN REWRITE_TAC[one_step_contour]
	THEN STRIP_TAC
	THENL[POP_ASSUM (fun th -> (LABEL_TAC "G3" th THEN MP_TAC th))
            THEN REWRITE_TAC[ADD1]
	    THEN USE_THEN "F7"(fun th1 -> (USE_THEN "F12" (fun th2 -> (USE_THEN "G2" (fun th3 -> (DISCH_THEN (fun th4 -> (MP_TAC (MATCH_MP lemma_node_walkup_eliminate_dart_on_Moebius_contour (CONJ th1 (CONJ th2 (CONJ th3 th4))))))))))))
	    THEN REWRITE_TAC[lemma_sub_two_numbers]
	    THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "G4") (CONJUNCTS_THEN2 (LABEL_TAC "G5") (LABEL_TAC "G6")))
	    THEN ABBREV_TAC `G = node_walkup (H:(A)hypermap) ((p:num->A) (m:num))`
	    THEN POP_ASSUM (LABEL_TAC "G7")
	    THEN SUBGOAL_THEN `one_step_contour G ((p:num->A) ((m:num)-1)) ((shift_path (p:num->A) ((m:num)+1)) 0)` ASSUME_TAC
	    THENL[REWRITE_TAC[lemma_shift_path_evaluation]
		THEN REWRITE_TAC[ADD_0]
		THEN REMOVE_THEN "G6" (fun th -> REWRITE_TAC[th]); ALL_TAC]
	    THEN SUBGOAL_THEN `(!i:num j:num. i <= (m:num-1) /\ j <= (k:num) - (m+1) ==> ~(shift_path (p:num->A) (m+1) j = p i))` ASSUME_TAC
	    THENL[REPEAT GEN_TAC
		THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "G8") (LABEL_TAC "G9"))
		THEN REWRITE_TAC[lemma_shift_path_evaluation; GSYM ADD_ASSOC]
		THEN USE_THEN "F10" (MP_TAC o SPECL[`(m:num) + 1 + (j:num)`; `i:num`])
		THEN USE_THEN "G8" (fun th1 -> (REWRITE_TAC[MATCH_MP (ARITH_RULE `i:num <= (m:num) - 1 ==> i < m + 1 + (j:num)`) th1]))
		THEN USE_THEN "G9" (fun th1 -> (USE_THEN "G2" (fun th2 -> (REWRITE_TAC[MATCH_MP (ARITH_RULE `j:num <= (k:num) - ((m:num) + 1) /\ m < k:num ==> m + 1 + j <= k`) (CONJ th1 th2)]))))
		THEN REWRITE_TAC[CONTRAPOS_THM; EQ_SYM]; ALL_TAC]
	    THEN REMOVE_THEN "G4" (fun th1 -> (REMOVE_THEN "G5" (fun th2 -> (POP_ASSUM (fun th4-> (POP_ASSUM (fun th3 -> MP_TAC (MATCH_MP concatenate_two_disjoint_contours (CONJ th1 (CONJ th2 (CONJ th3 th4)))))))))))
	    THEN REWRITE_TAC[lemma_shift_path_evaluation]
	    THEN USE_THEN "F12" (fun th1 -> (USE_THEN "G2" (fun th2 ->  REWRITE_TAC[MATCH_MP (ARITH_RULE `0 < (m:num) /\ m < (k:num) ==> m - 1 + k - (m+1) + 1 = k -1`) (CONJ th1 th2)])))
	    THEN USE_THEN "G2" (fun th -> REWRITE_TAC[MATCH_MP (ARITH_RULE `(m:num) < (k:num) ==> (m + 1) + k - (m+1) = k`) th])
	    THEN USE_THEN "F12" (fun th -> REWRITE_TAC[MP (ARITH_RULE `0 < (m:num) ==> m - 1 + (i:num) + 1 = m + i`) th])
	    THEN DISCH_THEN (X_CHOOSE_THEN `g:num->A` (CONJUNCTS_THEN2 (LABEL_TAC "G10") (CONJUNCTS_THEN2 (LABEL_TAC "G11") (CONJUNCTS_THEN2 (LABEL_TAC "G12") (CONJUNCTS_THEN2 (LABEL_TAC "G14") (LABEL_TAC "G15"))))))
	    THEN SUBGOAL_THEN `is_Moebius_contour (G:(A)hypermap) (g:num->A) ((k:num) - 1)` (LABEL_TAC "G16")
	    THENL[REWRITE_TAC[is_Moebius_contour]
		THEN USE_THEN "G12" (fun th -> REWRITE_TAC[th])
		THEN EXISTS_TAC `m:num`
		THEN EXISTS_TAC `(t:num) - 1`
		THEN USE_THEN "F12" (fun th -> REWRITE_TAC[th])
		THEN USE_THEN "G1" (fun th -> REWRITE_TAC[MP (ARITH_RULE `SUC (m:num) <= t:num ==> m <= t - 1`) th])
		THEN USE_THEN "G1" (fun th1 -> (USE_THEN "F15" (fun th2 -> REWRITE_TAC[MP (ARITH_RULE `SUC (m:num) <= t:num /\ t < k:num ==> t - 1 < k - 1`) (CONJ th1 th2)])))
		THEN USE_THEN "G10" (SUBST1_TAC)
		THEN USE_THEN "G11" (SUBST1_TAC)
		THEN USE_THEN "G15" (MP_TAC o SPEC `0`)
		THEN REWRITE_TAC[LE_0; ADD_0]
		THEN DISCH_THEN SUBST1_TAC
		THEN USE_THEN "G1" MP_TAC
		THEN REWRITE_TAC[LE_EXISTS; ADD1]
		THEN DISCH_THEN (X_CHOOSE_THEN `d:num` (LABEL_TAC "G16"))
		THEN USE_THEN "F15" (fun th1 -> (USE_THEN "G16" (fun th2 -> (ASSUME_TAC (MATCH_MP (ARITH_RULE `t:num < k:num /\ t = ((m:num) + 1) + (d:num) ==> d <= k - (m+1)`) (CONJ th1 th2))))))
		THEN USE_THEN "G15" (MP_TAC o SPEC `d:num`)
		THEN POP_ASSUM (fun th -> REWRITE_TAC[th])
		THEN USE_THEN "G16" (fun th -> GEN_REWRITE_TAC (LAND_CONV o RAND_CONV o RAND_CONV) [SYM th])
		THEN POP_ASSUM (fun th -> REWRITE_TAC[MATCH_MP (ARITH_RULE `t:num = ((m:num)+1) + (d:num) ==> m + d = t - 1`) th])
		THEN DISCH_THEN SUBST1_TAC
		THEN EXPAND_TAC "G"
		THEN STRIP_TAC
		THENL[USE_THEN "F10" (MP_TAC o SPECL[`m:num`; `0`])
	            THEN USE_THEN "F12" (fun th -> REWRITE_TAC[th])
		    THEN USE_THEN "G2" (fun th -> REWRITE_TAC[MATCH_MP LT_IMP_LE th])
		    THEN DISCH_THEN (LABEL_TAC "G21")
		    THEN SUBGOAL_THEN `~((p:num->A) 0 = face_map (H:(A)hypermap) ((p:num->A) (m:num)))` (LABEL_TAC "G22")
		    THENL[USE_THEN "G21" MP_TAC
		        THEN REWRITE_TAC[CONTRAPOS_THM]
		        THEN USE_THEN "G3" (SUBST1_TAC o SYM)
		        THEN USE_THEN "F10" (MP_TAC o SPECL[`SUC (m:num)`; `0`])
		        THEN USE_THEN "G2" (fun th -> (REWRITE_TAC[MATCH_MP (ARITH_RULE `m:num < k:num ==> SUC m <= k`) th]))
		        THEN REWRITE_TAC[LT_0]
			THEN MESON_TAC[]; ALL_TAC]
		    THEN SUBGOAL_THEN `~((p:num->A) 0 = inverse (node_map (H:(A)hypermap)) ((p:num->A) (m:num)))` (LABEL_TAC "G23")
		    THENL[ REWRITE_TAC[GSYM node_map_inverse_representation]
		        THEN USE_THEN "G21" MP_TAC
		        THEN REWRITE_TAC[CONTRAPOS_THM]
		        THEN USE_THEN "F16" (SUBST1_TAC o SYM)
		        THEN USE_THEN "F10" (MP_TAC o SPECL[`t:num`; `m:num`])
		        THEN USE_THEN "F15" (fun th -> (REWRITE_TAC[MATCH_MP LT_IMP_LE th]))
		        THEN USE_THEN "G1" (fun th -> (REWRITE_TAC[MATCH_MP (ARITH_RULE `SUC (m:num) <= t:num ==> m < t`) th]))
		        THEN MESON_TAC[]; ALL_TAC]
		    THEN MP_TAC (CONJUNCT2(CONJUNCT2(CONJUNCT2(SPECL[`H:(A)hypermap`; `(p:num->A) (m:num)`; `(p:num->A) 0`] node_map_node_walkup))))
		    THEN REPLICATE_TAC 3 (POP_ASSUM (fun th -> REWRITE_TAC[th]))
		    THEN USE_THEN "F16" (fun th -> REWRITE_TAC[th])
		    THEN REWRITE_TAC[EQ_SYM]; ALL_TAC]
		THEN USE_THEN "F10" (MP_TAC o SPECL[`(m:num) + 1`; `m:num`])
		THEN USE_THEN "F12" (fun th -> REWRITE_TAC[ARITH_RULE `m:num < m + 1`])
		THEN USE_THEN "G2" (fun th -> REWRITE_TAC[MATCH_MP (ARITH_RULE `m:num < k:num ==> m+1 <= k`) th])
		THEN USE_THEN "G3" MP_TAC
		THEN REWRITE_TAC[ADD1]
		THEN DISCH_THEN SUBST1_TAC
		THEN DISCH_THEN (LABEL_TAC "G3" o GSYM)
		THEN SUBGOAL_THEN `~(node_map (H:(A)hypermap) ((p:num->A) (m:num)) = p m)` (LABEL_TAC "G25")
		THENL[USE_THEN "F16k" (SUBST1_TAC o SYM)
	            THEN USE_THEN "F10" (MP_TAC o SPECL[`k:num`; `m:num`])
		    THEN USE_THEN "G2" (fun th -> REWRITE_TAC[LE_REFL; th])
		    THEN MESON_TAC[]; ALL_TAC]
		THEN MP_TAC (CONJUNCT1(CONJUNCT2(SPECL[`H:(A)hypermap`; `(p:num->A) (m:num)`; `(p:num->A) (m:num)`] node_map_node_walkup)))
		THEN REPLICATE_TAC 2 (POP_ASSUM (fun th -> REWRITE_TAC[th]))
		THEN USE_THEN "F16k" (fun th -> REWRITE_TAC[th])
		THEN REWRITE_TAC[EQ_SYM]; ALL_TAC]
	    THEN SUBGOAL_THEN `(p:num->A) (m:num) IN dart (H:(A)hypermap)` (LABEL_TAC "G26")
	    THENL[USE_THEN "F11" (SUBST1_TAC o SYM)
		THEN REWRITE_TAC[IN_ELIM_THM; LE_0]
		THEN EXISTS_TAC `m:num`
		THEN USE_THEN "G2" (fun th -> (REWRITE_TAC[MATCH_MP LT_IMP_LE th])); ALL_TAC]
	    THEN USE_THEN "G26" (MP_TAC o MATCH_MP lemma_card_node_walkup_dart)
	    THEN USE_THEN "G7" SUBST1_TAC
	    THEN USE_THEN "F1" SUBST1_TAC
	    THEN REWRITE_TAC[GSYM ADD1; EQ_SUC]
	    THEN DISCH_THEN (LABEL_TAC "G21")
	    THEN USE_THEN "FI" (MP_TAC o SPEC `node_walkup (H:(A)hypermap) ((p:num->A) (m:num))`)
	    THEN USE_THEN "G26" (fun th1 -> (USE_THEN "F2" (fun th2 -> REWRITE_TAC[MATCH_MP lemmaSGCOSXK (CONJ th1 th2)])))
	    THEN USE_THEN "G7" SUBST1_TAC
	    THEN POP_ASSUM (fun th -> REWRITE_TAC[th])
	    THEN EXISTS_TAC `g:num->A`
	    THEN EXISTS_TAC `(k:num) - 1`
	    THEN USE_THEN "G16" (fun th -> REWRITE_TAC[th]); ALL_TAC]
	THEN POP_ASSUM MP_TAC
	THEN REWRITE_TAC[ADD1]
	THEN DISCH_THEN (fun th -> (LABEL_TAC "K3A" th THEN MP_TAC th))
	THEN REWRITE_TAC[GSYM node_map_inverse_representation]
	THEN DISCH_THEN (LABEL_TAC "K3B")
	THEN USE_THEN "F7"(fun th1 -> (USE_THEN "F12" (fun th2 -> (USE_THEN "G2" (fun th3 -> (USE_THEN "K3B" (fun th4 -> (MP_TAC (MATCH_MP lemma_face_walkup_eliminate_dart_on_Moebius_contour (CONJ th1 (CONJ th2 (CONJ th3 (SYM th4)))))))))))))
	THEN REWRITE_TAC[lemma_sub_two_numbers]
	THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "K4") (CONJUNCTS_THEN2 (LABEL_TAC "K5") (LABEL_TAC "K6")))
	THEN ABBREV_TAC `G = face_walkup (H:(A)hypermap) ((p:num->A) (m:num))`
	THEN POP_ASSUM (LABEL_TAC "K7")
	THEN SUBGOAL_THEN `one_step_contour G ((p:num->A) ((m:num)-1)) ((shift_path (p:num->A) ((m:num)+1)) 0)` ASSUME_TAC
	THENL[REWRITE_TAC[lemma_shift_path_evaluation]
            THEN REWRITE_TAC[ADD_0]
	    THEN REMOVE_THEN "K6" (fun th -> REWRITE_TAC[th]); ALL_TAC]
	THEN SUBGOAL_THEN `(!i:num j:num. i <= (m:num-1) /\ j <= (k:num) - (m+1) ==> ~(shift_path (p:num->A) (m+1) j = p i))` ASSUME_TAC
	THENL[REPEAT GEN_TAC
            THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "K8") (LABEL_TAC "K9"))
	    THEN REWRITE_TAC[lemma_shift_path_evaluation; GSYM ADD_ASSOC]
	    THEN USE_THEN "F10" (MP_TAC o SPECL[`(m:num) + 1 + (j:num)`; `i:num`])
	    THEN USE_THEN "K8" (fun th1 -> (REWRITE_TAC[MATCH_MP (ARITH_RULE `i:num <= (m:num) - 1 ==> i < m + 1 + (j:num)`) th1]))
	    THEN USE_THEN "K9" (fun th1 -> (USE_THEN "G2" (fun th2 -> (REWRITE_TAC[MATCH_MP (ARITH_RULE `j:num <= (k:num) - ((m:num) + 1) /\ m < k:num ==> m + 1 + j <= k`) (CONJ th1 th2)]))))
	    THEN REWRITE_TAC[CONTRAPOS_THM; EQ_SYM]; ALL_TAC]
	THEN REMOVE_THEN "K4" (fun th1 -> (REMOVE_THEN "K5" (fun th2 -> (POP_ASSUM (fun th4-> (POP_ASSUM (fun th3 -> MP_TAC (MATCH_MP concatenate_two_disjoint_contours (CONJ th1 (CONJ th2 (CONJ th3 th4)))))))))))
	THEN REWRITE_TAC[lemma_shift_path_evaluation]
	THEN USE_THEN "F12" (fun th1 -> (USE_THEN "G2" (fun th2 ->  REWRITE_TAC[MATCH_MP (ARITH_RULE `0 < (m:num) /\ m < (k:num) ==> m - 1 + k - (m+1) + 1 = k -1`) (CONJ th1 th2)])))
	THEN USE_THEN "G2" (fun th -> REWRITE_TAC[MATCH_MP (ARITH_RULE `(m:num) < (k:num) ==> (m + 1) + k - (m+1) = k`) th])
	THEN USE_THEN "F12" (fun th -> REWRITE_TAC[MP (ARITH_RULE `0 < (m:num) ==> m - 1 + (i:num) + 1 = m + i`) th])
	THEN DISCH_THEN (X_CHOOSE_THEN `g:num->A` (CONJUNCTS_THEN2 (LABEL_TAC "K10") (CONJUNCTS_THEN2 (LABEL_TAC "K11") (CONJUNCTS_THEN2 (LABEL_TAC "K12") (CONJUNCTS_THEN2 (LABEL_TAC "K14") (LABEL_TAC "K15"))))))
	THEN SUBGOAL_THEN `is_Moebius_contour (G:(A)hypermap) (g:num->A) ((k:num) - 1)` (LABEL_TAC "K16")
	THENL[REWRITE_TAC[is_Moebius_contour]
            THEN USE_THEN "K12" (fun th -> REWRITE_TAC[th])
	    THEN EXISTS_TAC `m:num`
	    THEN EXISTS_TAC `(t:num) - 1`
	    THEN USE_THEN "F12" (fun th -> REWRITE_TAC[th])
	    THEN USE_THEN "G1" (fun th -> REWRITE_TAC[MP (ARITH_RULE `SUC (m:num) <= t:num ==> m <= t - 1`) th])
	    THEN USE_THEN "G1" (fun th1 -> (USE_THEN "F15" (fun th2 -> REWRITE_TAC[MP (ARITH_RULE `SUC (m:num) <= t:num /\ t < k:num ==> t - 1 < k - 1`) (CONJ th1 th2)])))
	    THEN USE_THEN "K10" (SUBST1_TAC)
	    THEN USE_THEN "K11" (SUBST1_TAC)
	    THEN USE_THEN "K15" (MP_TAC o SPEC `0`)
	    THEN REWRITE_TAC[LE_0; ADD_0]
	    THEN DISCH_THEN SUBST1_TAC
	    THEN USE_THEN "G1" MP_TAC
	    THEN REWRITE_TAC[LE_EXISTS; ADD1]
	    THEN DISCH_THEN (X_CHOOSE_THEN `d:num` (LABEL_TAC "K16"))
	    THEN USE_THEN "F15" (fun th1 -> (USE_THEN "K16" (fun th2 -> (ASSUME_TAC (MATCH_MP (ARITH_RULE `t:num < k:num /\ t = ((m:num) + 1) + (d:num) ==> d <= k - (m+1)`) (CONJ th1 th2))))))
	    THEN USE_THEN "K15" (MP_TAC o SPEC `d:num`)
	    THEN POP_ASSUM (fun th -> REWRITE_TAC[th])
	    THEN USE_THEN "K16" (fun th -> GEN_REWRITE_TAC (LAND_CONV o RAND_CONV o RAND_CONV) [SYM th])
	    THEN POP_ASSUM (fun th -> REWRITE_TAC[MATCH_MP (ARITH_RULE `t:num = ((m:num)+1) + (d:num) ==> m + d = t - 1`) th])
	    THEN DISCH_THEN SUBST1_TAC
	    THEN EXPAND_TAC "G"
	    THEN STRIP_TAC
	    THENL[USE_THEN "F10" (MP_TAC o SPECL[`m:num`; `0`])
		THEN USE_THEN "F12" (fun th -> REWRITE_TAC[th])
		THEN USE_THEN "G2" (fun th -> REWRITE_TAC[MATCH_MP LT_IMP_LE th])
		THEN DISCH_THEN (LABEL_TAC "K21")
		THEN SUBGOAL_THEN `~((p:num->A) 0 = inverse (node_map (H:(A)hypermap)) ((p:num->A) (m:num)))` (LABEL_TAC "K23")
		THENL[ REWRITE_TAC[GSYM node_map_inverse_representation]
		    THEN USE_THEN "K21" MP_TAC
		    THEN REWRITE_TAC[CONTRAPOS_THM]
		    THEN USE_THEN "F16" (SUBST1_TAC o SYM)
		    THEN USE_THEN "F10" (MP_TAC o SPECL[`t:num`; `m:num`])
		    THEN USE_THEN "F15" (fun th -> (REWRITE_TAC[MATCH_MP LT_IMP_LE th]))
		    THEN USE_THEN "G1" (fun th -> (REWRITE_TAC[MATCH_MP (ARITH_RULE `SUC (m:num) <= t:num ==> m < t`) th]))
		    THEN MESON_TAC[]; ALL_TAC]
		THEN MP_TAC (CONJUNCT2(CONJUNCT2(SPECL[`H:(A)hypermap`; `(p:num->A) (m:num)`; `(p:num->A) 0`] node_map_face_walkup)))
		THEN REPLICATE_TAC 2 (POP_ASSUM (fun th -> REWRITE_TAC[th]))
		THEN USE_THEN "F16" (fun th -> REWRITE_TAC[th])
		THEN REWRITE_TAC[EQ_SYM]; ALL_TAC]
	    THEN USE_THEN "K3A" SUBST1_TAC
	    THEN REWRITE_TAC[node_map_face_walkup]
	    THEN USE_THEN "F16k" (fun th -> REWRITE_TAC[th]); ALL_TAC]
	THEN SUBGOAL_THEN `(p:num->A) (m:num) IN dart (H:(A)hypermap)` (LABEL_TAC "K17")
	THENL[USE_THEN "F11" (SUBST1_TAC o SYM)
            THEN REWRITE_TAC[IN_ELIM_THM; LE_0]
	    THEN EXISTS_TAC `m:num`
	    THEN USE_THEN "G2" (fun th -> (REWRITE_TAC[MATCH_MP LT_IMP_LE th])); ALL_TAC]
	THEN USE_THEN "K17" (MP_TAC o MATCH_MP lemma_card_face_walkup_dart)
	THEN USE_THEN "K7" SUBST1_TAC
	THEN USE_THEN "F1" SUBST1_TAC
	THEN REWRITE_TAC[GSYM ADD1; EQ_SUC]
	THEN DISCH_THEN (LABEL_TAC "K18")
	THEN USE_THEN "FI" (MP_TAC o SPEC `face_walkup (H:(A)hypermap) ((p:num->A) (m:num))`)
	THEN USE_THEN "K17" (fun th1 -> (USE_THEN "F2" (fun th2 -> REWRITE_TAC[MATCH_MP lemmaSGCOSXK (CONJ th1 th2)])))
	THEN USE_THEN "K7" SUBST1_TAC
	THEN POP_ASSUM (fun th -> REWRITE_TAC[th])
	THEN EXISTS_TAC `g:num->A`
	THEN EXISTS_TAC `(k:num) - 1`
	THEN USE_THEN "K16" (fun th -> REWRITE_TAC[th]); ALL_TAC]
    THEN POP_ASSUM (fun th1 -> (REMOVE_THEN "F14" (fun th2 -> (MP_TAC (MATCH_MP (ARITH_RULE `m:num <= t:num /\ ~(m < t) ==> t = m`) (CONJ th2 th1))))))
    THEN DISCH_THEN SUBST_ALL_TAC
    THEN ASM_CASES_TAC `1 < m:num`
    THENL[ POP_ASSUM (fun th -> (LABEL_TAC "B1" th THEN LABEL_TAC "B2" (MATCH_MP (ARITH_RULE `1 < m:num ==> 2 <= m`) th)))
      THEN USE_THEN "F17" (MP_TAC o SPEC `0:num`)
      THEN USE_THEN "B2" (fun th1 -> (USE_THEN "F15" (fun th2 -> (LABEL_TAC "B3" (MP (ARITH_RULE `2 <= m:num /\ m < k:num ==> 2 < k`) (CONJ th1 th2))))))
      THEN USE_THEN "B3" (fun th -> REWRITE_TAC[MP (ARITH_RULE `2 < k:num ==> 0 < k`) th])
      THEN REWRITE_TAC[one_step_contour]
      THEN STRIP_TAC
      THENL[POP_ASSUM MP_TAC
          THEN REWRITE_TAC[ADD1]
          THEN DISCH_THEN (LABEL_TAC "B4")
          THEN USE_THEN "F15" (fun th -> MP_TAC (MATCH_MP (ARITH_RULE `m:num < k:num ==> 0 < k`) th))
          THEN USE_THEN "F7" (fun th1 -> (DISCH_THEN (fun th2 -> (USE_THEN "B4" (fun th3 -> (MP_TAC (MATCH_MP lemma_node_walkup_second_segment_contour (CONJ th1 (CONJ th2 th3)))))))))
          THEN REWRITE_TAC[ADD]
          THEN DISCH_THEN (LABEL_TAC "B5")
          THEN ABBREV_TAC `G = node_walkup (H:(A)hypermap) ((p:num->A) 0)`
          THEN POP_ASSUM (LABEL_TAC "B6")
          THEN ABBREV_TAC `g = shift_path (p:num->A) 1`
          THEN POP_ASSUM (LABEL_TAC "B7")
          THEN SUBGOAL_THEN `is_Moebius_contour (G:(A)hypermap) (g:num->A) ((k:num) - 1)` (LABEL_TAC "B8")
          THENL[REWRITE_TAC[is_Moebius_contour]
	      THEN USE_THEN "B5" (fun th -> REWRITE_TAC[th])
	      THEN EXISTS_TAC `(m:num) - 1`
	      THEN EXISTS_TAC `(m:num) - 1`
	      THEN USE_THEN "B2" (fun th -> REWRITE_TAC[MATCH_MP (ARITH_RULE `2 <= m:num ==> 0 < m - 1`) th; LE_REFL])
	      THEN USE_THEN "F12" (fun th1 -> (USE_THEN "F15" (fun th2 -> REWRITE_TAC[MP (ARITH_RULE `0 < m:num /\ m < k:num ==> m - 1 < k - 1`) (CONJ th1 th2)])))
	      THEN EXPAND_TAC "g"
	      THEN REWRITE_TAC[lemma_shift_path_evaluation]
	      THEN REWRITE_TAC[ADD_SYM; GSYM ADD]
	      THEN USE_THEN "F12" (fun th -> REWRITE_TAC[MP (ARITH_RULE `0 < m:num ==> m - 1 + 1 = m`) th])
	      THEN USE_THEN "B3" (fun th -> REWRITE_TAC[MP (ARITH_RULE `2 < k:num ==> k - 1 + 1 = k`) th])
	      THEN REWRITE_TAC[ARITH_RULE `1+0 = 1`]
	      THEN POP_ASSUM (LABEL_TAC "B9")
	      THEN EXPAND_TAC "G"
	      THEN STRIP_TAC
	      THENL[USE_THEN "B4" MP_TAC
	          THEN REWRITE_TAC[ADD]
	          THEN DISCH_THEN SUBST1_TAC
	          THEN SUBGOAL_THEN `~(face_map (H:(A)hypermap) ((p:num->A) 0) = p 0)` ASSUME_TAC
	          THENL[ USE_THEN "B4" (SUBST1_TAC o SYM)
	              THEN REWRITE_TAC[ADD]
	              THEN USE_THEN "F10" (MP_TAC o SPECL[`1`; `0`])
	              THEN USE_THEN "B3" (fun th -> REWRITE_TAC[MP (ARITH_RULE `2 < k:num ==> 1 <= k`) th])
	              THEN REWRITE_TAC[ARITH_RULE `0 < 1`]
	              THEN MESON_TAC[]; ALL_TAC]
	          THEN  SUBGOAL_THEN `~(node_map (H:(A)hypermap) ((p:num->A) 0) = p 0)` ASSUME_TAC
	          THENL[USE_THEN "F16" (SUBST1_TAC o SYM)
	              THEN USE_THEN "F10" (MP_TAC o SPECL[`m:num`; `0`])
	              THEN USE_THEN "F15" (fun th -> REWRITE_TAC[MATCH_MP LT_IMP_LE th])
	              THEN USE_THEN "F12" (fun th -> REWRITE_TAC[th])
	              THEN MESON_TAC[]; ALL_TAC]
	          THEN MP_TAC (CONJUNCT1(CONJUNCT2(SPECL[`H:(A)hypermap`; `(p:num->A) 0`; `(p:num->A) 0`] node_map_node_walkup)))
	          THEN REPLICATE_TAC 2 (POP_ASSUM (fun th -> REWRITE_TAC[th]))
	          THEN USE_THEN "F16" (fun th -> REWRITE_TAC[th])
	          THEN  REWRITE_TAC[EQ_SYM]; ALL_TAC]
              THEN  USE_THEN "F10" (MP_TAC o SPECL[`m:num`; `0`])
              THEN USE_THEN "F15" (fun th -> REWRITE_TAC[MATCH_MP LT_IMP_LE  th])
              THEN USE_THEN "F12" (fun th -> REWRITE_TAC[th])
              THEN DISCH_TAC
	      THEN SUBGOAL_THEN `~((p:num->A) (m:num) = face_map (H:(A)hypermap) ((p:num->A) 0))` ASSUME_TAC
	      THENL[USE_THEN "B4" (SUBST1_TAC o SYM)
	          THEN REWRITE_TAC[ADD]
	          THEN USE_THEN "F10" (MP_TAC o SPECL[`m:num`; `1`])
	          THEN USE_THEN "F15" (fun th -> (REWRITE_TAC[MATCH_MP LT_IMP_LE th]))
	          THEN USE_THEN "B1" (fun th -> (REWRITE_TAC[th]))
	          THEN MESON_TAC[]; ALL_TAC]
	      THEN SUBGOAL_THEN `~((p:num->A) (m:num) = inverse (node_map (H:(A)hypermap)) ((p:num->A) 0))` ASSUME_TAC
	      THENL[REWRITE_TAC[GSYM node_map_inverse_representation]
	          THEN USE_THEN "F16k" (SUBST1_TAC o SYM)
	          THEN USE_THEN "F10" (MP_TAC o SPECL[`k:num`; `0`])
	          THEN USE_THEN "B3" (fun th -> (REWRITE_TAC[MATCH_MP (ARITH_RULE `2 < k:num ==> 0 < k`) th; LE_REFL])); ALL_TAC]
	      THEN MP_TAC (CONJUNCT2(CONJUNCT2(CONJUNCT2(SPECL[`H:(A)hypermap`; `(p:num->A) 0`; `(p:num->A) (m:num)`] node_map_node_walkup))))
	      THEN REPLICATE_TAC 2 (POP_ASSUM (fun th -> REWRITE_TAC[th]))
	      THEN POP_ASSUM (fun th -> REWRITE_TAC[GSYM th])
	      THEN USE_THEN "F16k" (fun th -> REWRITE_TAC[th])
	      THEN REWRITE_TAC[EQ_SYM]; ALL_TAC]
           THEN SUBGOAL_THEN `(p:num->A) 0 IN dart (H:(A)hypermap)` (LABEL_TAC "B10")
           THENL[USE_THEN "F11" (SUBST1_TAC o SYM)
              THEN REWRITE_TAC[IN_ELIM_THM; LE_0]
              THEN EXISTS_TAC `0`
              THEN REWRITE_TAC[LE_0]; ALL_TAC]
           THEN USE_THEN "B10" (MP_TAC o MATCH_MP lemma_card_node_walkup_dart)
           THEN USE_THEN "B6" SUBST1_TAC
           THEN USE_THEN "F1" SUBST1_TAC
           THEN REWRITE_TAC[GSYM ADD1; EQ_SUC]
           THEN DISCH_THEN (LABEL_TAC "B11")
           THEN USE_THEN "FI" (MP_TAC o SPEC `node_walkup (H:(A)hypermap) ((p:num->A) 0)`)
           THEN USE_THEN "B10" (fun th1 -> (USE_THEN "F2" (fun th2 -> REWRITE_TAC[MATCH_MP lemmaSGCOSXK (CONJ th1 th2)])))
           THEN USE_THEN "B6" SUBST1_TAC
           THEN POP_ASSUM (fun th -> REWRITE_TAC[SYM th])
           THEN EXISTS_TAC `g:num->A`
           THEN EXISTS_TAC `(k:num) - 1`
           THEN USE_THEN "B8" (fun th -> REWRITE_TAC[th]); ALL_TAC]
      THEN POP_ASSUM MP_TAC
      THEN REWRITE_TAC[ADD1]
      THEN REWRITE_TAC[GSYM node_map_inverse_representation]
      THEN DISCH_THEN (LABEL_TAC "C4" o GSYM)
      THEN USE_THEN "F15" (fun th -> MP_TAC (MATCH_MP (ARITH_RULE `m:num < k:num ==> 0 < k`) th))
      THEN USE_THEN "F7" (fun th1 -> (DISCH_THEN (fun th2 -> (USE_THEN "C4" (fun th3 -> (MP_TAC (MATCH_MP lemma_face_walkup_second_segment_contour (CONJ th1 (CONJ th2 th3)))))))))
      THEN REWRITE_TAC[ADD]
      THEN DISCH_THEN (LABEL_TAC "C5")
      THEN ABBREV_TAC `G = face_walkup (H:(A)hypermap) ((p:num->A) 0)`
      THEN POP_ASSUM (LABEL_TAC "C6")
      THEN ABBREV_TAC `g = shift_path (p:num->A) 1`
      THEN POP_ASSUM (LABEL_TAC "C7")
      THEN SUBGOAL_THEN `is_Moebius_contour (G:(A)hypermap) (g:num->A) ((k:num) - 1)` (LABEL_TAC "C8")
      THENL[REWRITE_TAC[is_Moebius_contour]
	 THEN USE_THEN "C5" (fun th -> REWRITE_TAC[th])
	 THEN  EXISTS_TAC `(m:num) - 1`
	 THEN  EXISTS_TAC `(m:num) - 1`
	 THEN USE_THEN "B2" (fun th -> REWRITE_TAC[MATCH_MP (ARITH_RULE `2 <= m:num ==> 0 < m - 1`) th; LE_REFL])
	 THEN USE_THEN "F12" (fun th1 -> (USE_THEN "F15" (fun th2 -> REWRITE_TAC[MP (ARITH_RULE `0 < m:num /\ m < k:num ==> m - 1 < k - 1`) (CONJ th1 th2)])))
	 THEN EXPAND_TAC "g"
	 THEN REWRITE_TAC[lemma_shift_path_evaluation]
	 THEN REWRITE_TAC[ADD_SYM; GSYM ADD]
	 THEN USE_THEN "F12" (fun th -> REWRITE_TAC[MP (ARITH_RULE `0 < m:num ==> m - 1 + 1 = m`) th])
	 THEN USE_THEN "B3" (fun th -> REWRITE_TAC[MP (ARITH_RULE `2 < k:num ==> k - 1 + 1 = k`) th])
	 THEN REWRITE_TAC[ARITH_RULE `1+0 = 1`]
	 THEN POP_ASSUM (LABEL_TAC "C9")
	 THEN EXPAND_TAC "G"
	 THEN STRIP_TAC
	 THENL[USE_THEN "C4" (MP_TAC o SYM)
            THEN REWRITE_TAC[ADD]
	    THEN GEN_REWRITE_TAC (LAND_CONV o TOP_DEPTH_CONV) [node_map_inverse_representation]
	    THEN DISCH_THEN (SUBST1_TAC)
	    THEN REWRITE_TAC[node_map_face_walkup]
	    THEN USE_THEN "F16" (fun th -> REWRITE_TAC[th]); ALL_TAC]
	 THEN USE_THEN "F10" (MP_TAC o SPECL[`m:num`; `0`])
	 THEN USE_THEN "F12" (fun th -> REWRITE_TAC[th])
	 THEN USE_THEN "F15" (fun th -> REWRITE_TAC[MATCH_MP LT_IMP_LE th])
	 THEN DISCH_THEN (ASSUME_TAC o GSYM)
	 THEN SUBGOAL_THEN `~((p:num->A) (m:num) = inverse(node_map (H:(A)hypermap)) ((p:num->A) 0))` ASSUME_TAC
	 THENL[REWRITE_TAC[GSYM node_map_inverse_representation]
            THEN USE_THEN "F16k" (SUBST1_TAC o SYM)
	    THEN USE_THEN "F10" (MP_TAC o SPECL[`k:num`; `0`])
	    THEN USE_THEN "B3" (fun th -> (REWRITE_TAC[MATCH_MP (ARITH_RULE `2 < k:num ==> 0 < k`) th; LE_REFL])); ALL_TAC]
	 THEN MP_TAC (CONJUNCT2(CONJUNCT2 (SPECL[`H:(A)hypermap`; `(p:num->A) 0`; `(p:num->A) (m:num)`] node_map_face_walkup)))
	 THEN REPLICATE_TAC 2 (POP_ASSUM (fun th -> REWRITE_TAC[th]))
	 THEN USE_THEN "F16k" (fun th -> REWRITE_TAC[th])
	 THEN REWRITE_TAC[EQ_SYM]; ALL_TAC]
      THEN SUBGOAL_THEN `(p:num->A) 0 IN dart (H:(A)hypermap)` (LABEL_TAC "C10")
      THENL[USE_THEN "F11" (SUBST1_TAC o SYM)
	 THEN REWRITE_TAC[IN_ELIM_THM; LE_0]
	 THEN EXISTS_TAC `0`
	 THEN REWRITE_TAC[LE_0]; ALL_TAC]
      THEN USE_THEN "C10" (MP_TAC o MATCH_MP lemma_card_face_walkup_dart)
      THEN USE_THEN "C6" SUBST1_TAC
      THEN  USE_THEN "F1" SUBST1_TAC
      THEN  REWRITE_TAC[GSYM ADD1; EQ_SUC]
      THEN  DISCH_THEN (LABEL_TAC "C11" o GSYM)
      THEN  USE_THEN "FI" (MP_TAC o SPEC `face_walkup (H:(A)hypermap) ((p:num->A) 0)`)
      THEN  USE_THEN "C10" (fun th1 -> (USE_THEN "F2" (fun th2 -> REWRITE_TAC[MATCH_MP lemmaSGCOSXK (CONJ th1 th2)])))
      THEN  USE_THEN "C6" SUBST1_TAC
      THEN  POP_ASSUM (fun th -> REWRITE_TAC[SYM th])
      THEN  EXISTS_TAC `g:num->A`
      THEN  EXISTS_TAC `(k:num) - 1`
      THEN USE_THEN "C8" (fun th -> REWRITE_TAC[th]); ALL_TAC]
   THEN POP_ASSUM (fun th1 -> (REMOVE_THEN "F12" (fun th2 -> ASSUME_TAC (MATCH_MP (ARITH_RULE `0 < m:num /\ ~(1 < m) ==> m = 1`) (CONJ th2 th1)))))
   THEN POP_ASSUM SUBST_ALL_TAC
   THEN ASM_CASES_TAC `2 < k:num`
   THENL[POP_ASSUM (LABEL_TAC "F18")
       THEN USE_THEN "F15" MP_TAC
       THEN REWRITE_TAC[LT_EXISTS]
       THEN DISCH_THEN (X_CHOOSE_THEN `d:num` MP_TAC)
       THEN GEN_REWRITE_TAC (LAND_CONV o ONCE_DEPTH_CONV) [ADD_SYM]
       THEN ABBREV_TAC `s = SUC (d:num)`
       THEN DISCH_THEN SUBST_ALL_TAC
       THEN USE_THEN "F18" (fun th -> (LABEL_TAC "F19" (MATCH_MP (ARITH_RULE `2 < (s:num) + 1 ==> 2 <= s`) th)))
       THEN USE_THEN "F17" (MP_TAC o SPEC `s:num`)
       THEN REWRITE_TAC[ARITH_RULE `(s:num) < s + 1`]
       THEN REWRITE_TAC[ADD1]
       THEN REWRITE_TAC[one_step_contour]
       THEN STRIP_TAC
       THENL[POP_ASSUM (LABEL_TAC "X1")
	   THEN MP_TAC (ARITH_RULE `s:num < s + 1`)
	   THEN USE_THEN "F19" (fun th -> MP_TAC (MP (ARITH_RULE `2 <= s:num ==> 0 < s`) th))
	   THEN USE_THEN "F7" (fun th1 -> (DISCH_THEN (fun th2 -> (DISCH_THEN (fun th3 -> (USE_THEN "X1" (fun th4 -> (MP_TAC (MATCH_MP lemma_node_walkup_eliminate_dart_on_Moebius_contour (CONJ th1 (CONJ th2 (CONJ th3 th4))))))))))))
	   THEN REWRITE_TAC[lemma_sub_two_numbers; SUB_REFL]
	   THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "X4") (CONJUNCTS_THEN2 (LABEL_TAC "X5") (LABEL_TAC "X6")))
	   THEN ABBREV_TAC `G = node_walkup (H:(A)hypermap) ((p:num->A) (s:num))`
	   THEN POP_ASSUM (LABEL_TAC "X7")
           THEN SUBGOAL_THEN `one_step_contour (G:(A)hypermap) ((p:num->A) ((s:num)-1)) ((shift_path (p:num->A) ((s:num)+1)) 0)` ASSUME_TAC
	   THENL[REWRITE_TAC[lemma_shift_path_evaluation]
		THEN REWRITE_TAC[ADD_0]
		THEN REMOVE_THEN "X6" (fun th -> REWRITE_TAC[th]); ALL_TAC]
	   THEN SUBGOAL_THEN `(!i:num j:num. i <= (s:num-1) /\ j <= 0 ==> ~(shift_path (p:num->A) (s+1) j = p i))` ASSUME_TAC
	   THENL[REWRITE_TAC[LE]
	        THEN REPEAT GEN_TAC
		THEN DISCH_THEN (CONJUNCTS_THEN2 (ASSUME_TAC) (SUBST1_TAC))
		THEN REWRITE_TAC[lemma_shift_path_evaluation; GSYM ADD_ASSOC; ADD_0]
		THEN USE_THEN "F10" (MP_TAC o SPECL[`(s:num) + 1 `; `i:num`])
		THEN POP_ASSUM (fun th -> REWRITE_TAC[MP (ARITH_RULE `i:num  <= (s:num) - 1 ==> i < s + 1`) th; LE_REFL])
		THEN MESON_TAC[]; ALL_TAC]
	   THEN REMOVE_THEN "X4" (fun th1 -> (REMOVE_THEN "X5" (fun th2 -> (POP_ASSUM (fun th4-> (POP_ASSUM (fun th3 -> MP_TAC (MATCH_MP concatenate_two_disjoint_contours (CONJ th1 (CONJ th2 (CONJ th3 th4)))))))))))
	   THEN REWRITE_TAC[lemma_shift_path_evaluation]
	   THEN REWRITE_TAC[ADD_0]
	   THEN USE_THEN "F19" (fun th -> REWRITE_TAC[MP (ARITH_RULE `2 <= s:num ==> s-1+0+1 = s`) th])
	   THEN DISCH_THEN (X_CHOOSE_THEN `g:num->A` (CONJUNCTS_THEN2 (LABEL_TAC "X10") (CONJUNCTS_THEN2 (LABEL_TAC "X11") (CONJUNCTS_THEN2 (LABEL_TAC "X12") (LABEL_TAC "X14" o CONJUNCT1)))))	   
           THEN SUBGOAL_THEN `is_Moebius_contour (G:(A)hypermap) (g:num->A) (s:num)` (LABEL_TAC "X15")
	   THENL[REWRITE_TAC[is_Moebius_contour]
	       THEN USE_THEN "X12" (fun th -> REWRITE_TAC[th])
	       THEN EXISTS_TAC `1:num`
	       THEN EXISTS_TAC `1:num`
	       THEN USE_THEN "F19" (fun th -> REWRITE_TAC[MATCH_MP (ARITH_RULE `2 <= s:num ==> 1 < s`) th; ARITH_RULE `0 < 1 /\ 1 <= 1`])
	       THEN REMOVE_THEN "X10" SUBST1_TAC
	       THEN REMOVE_THEN "X11" SUBST1_TAC
	       THEN POP_ASSUM (MP_TAC o SPEC `1`)
	       THEN USE_THEN "F19" (fun th -> REWRITE_TAC[MATCH_MP (ARITH_RULE `2 <= s:num ==> 1 <= s - 1`) th])
	       THEN DISCH_THEN SUBST1_TAC
	       THEN EXPAND_TAC "G"
	       THEN STRIP_TAC
	       THENL[USE_THEN "F10" (MP_TAC o SPECL[`s:num`; `0`])
                   THEN USE_THEN "F19" (fun th ->  REWRITE_TAC[MP (ARITH_RULE `2 <= s:num ==> 0 < s`) th; ARITH_RULE `s:num <= s + 1`])
		   THEN DISCH_TAC
		   THEN SUBGOAL_THEN `~((p:num->A) 0 = face_map (H:(A)hypermap) ((p:num->A) (s:num)))` ASSUME_TAC
		   THENL[USE_THEN "X1" (SUBST1_TAC o SYM)
		       THEN USE_THEN "F10" (MP_TAC o SPECL[`(s:num) + 1`; `0`])
		       THEN REWRITE_TAC[ARITH_RULE `0 < (s:num) + 1`; LE_REFL]; ALL_TAC]
		   THEN SUBGOAL_THEN `~((p:num->A) 0 = inverse (node_map (H:(A)hypermap)) ((p:num->A) (s:num)))` (ASSUME_TAC)
		   THENL[REWRITE_TAC[GSYM node_map_inverse_representation]
		       THEN USE_THEN "F16" (SUBST1_TAC o SYM)
		       THEN USE_THEN "F10" (MP_TAC o SPECL[`(s:num)`; `1`])
		       THEN USE_THEN "F19" (fun th ->  REWRITE_TAC[MP (ARITH_RULE `2 <= (s:num) ==> 1 < s`) th; ARITH_RULE `s:num <= s + 1`])
		       THEN MESON_TAC[]; ALL_TAC]
		   THEN MP_TAC (CONJUNCT2(CONJUNCT2(CONJUNCT2(SPECL[`H:(A)hypermap`; `(p:num->A) (s:num)`; `(p:num->A) (0:num)`] node_map_node_walkup))))
		   THEN REPLICATE_TAC 3 (POP_ASSUM (fun th -> REWRITE_TAC[th]))
		   THEN USE_THEN "F16" (fun th -> REWRITE_TAC[th])
		   THEN REWRITE_TAC[EQ_SYM]; ALL_TAC]
	       THEN USE_THEN "F10" (MP_TAC o SPECL[`s:num`; `1`])
	       THEN USE_THEN "F19" (fun th ->  REWRITE_TAC[MP (ARITH_RULE `2 <= s:num ==> 1 < s`) th; ARITH_RULE `s:num <= s + 1`])
	       THEN DISCH_TAC
	       THEN SUBGOAL_THEN `~((p:num->A) 1 = face_map (H:(A)hypermap) ((p:num->A) (s:num)))` ASSUME_TAC
	       THENL[USE_THEN "X1" (SUBST1_TAC o SYM)
		   THEN USE_THEN "F10" (MP_TAC o SPECL[`(s:num) + 1`; `1`])
		   THEN USE_THEN "F19" (fun th -> REWRITE_TAC[MP (ARITH_RULE `2 <= s:num ==> 1 < s + 1`) th; ARITH_RULE `0 < (s:num) + 1`; LE_REFL]); 
                   ALL_TAC]
	       THEN SUBGOAL_THEN `~((p:num->A) 1 = inverse (node_map (H:(A)hypermap)) ((p:num->A) (s:num)))` (ASSUME_TAC)
	       THENL[REWRITE_TAC[GSYM node_map_inverse_representation]
		   THEN USE_THEN "F16k" (SUBST1_TAC o SYM)
		   THEN USE_THEN "F10" (MP_TAC o SPECL[`(s:num)+1`; `s:num`])
		   THEN USE_THEN "F19" (fun th ->  REWRITE_TAC[ARITH_RULE `s:num < s + 1`; LE_REFL]); ALL_TAC]
	       THEN MP_TAC (CONJUNCT2(CONJUNCT2(CONJUNCT2(SPECL[`H:(A)hypermap`; `(p:num->A) (s:num)`; `(p:num->A) (1:num)`] node_map_node_walkup))))
	       THEN REPLICATE_TAC 3 (POP_ASSUM (fun th -> REWRITE_TAC[th]))
	       THEN USE_THEN "F16k" (fun th -> REWRITE_TAC[th])
	       THEN REWRITE_TAC[EQ_SYM]; ALL_TAC]	  
           THEN SUBGOAL_THEN `(p:num->A) (s:num) IN dart (H:(A)hypermap)` (LABEL_TAC "X20")
	   THENL[ USE_THEN "F11" (SUBST1_TAC o SYM)
	       THEN REWRITE_TAC[IN_ELIM_THM; LE_0]
	       THEN EXISTS_TAC `s:num`
	       THEN REWRITE_TAC[ARITH_RULE `s:num <= s + 1`]; ALL_TAC]
	   THEN USE_THEN "X20" (MP_TAC o MATCH_MP lemma_card_node_walkup_dart)
	   THEN USE_THEN "X7" SUBST1_TAC
	   THEN USE_THEN "F1" SUBST1_TAC
	   THEN REWRITE_TAC[GSYM ADD1; EQ_SUC]
	   THEN DISCH_THEN (LABEL_TAC "X21")
	   THEN USE_THEN "FI" (MP_TAC o SPEC `node_walkup (H:(A)hypermap) ((p:num->A) (s:num))`)
	   THEN USE_THEN "X20" (fun th1 -> (USE_THEN "F2" (fun th2 -> REWRITE_TAC[MATCH_MP lemmaSGCOSXK (CONJ th1 th2)])))
	   THEN USE_THEN "X7" SUBST1_TAC
	   THEN POP_ASSUM (fun th -> REWRITE_TAC[th])
	   THEN EXISTS_TAC `g:num->A`
	   THEN EXISTS_TAC `s:num`	
	   THEN USE_THEN "X15" (fun th -> REWRITE_TAC[th]); ALL_TAC]
       THEN POP_ASSUM MP_TAC
       THEN REWRITE_TAC[GSYM node_map_inverse_representation]
       THEN DISCH_THEN (LABEL_TAC "Y1")
       THEN MP_TAC (ARITH_RULE `s:num < s + 1`)
       THEN USE_THEN "F19" (fun th -> MP_TAC (MP (ARITH_RULE `2 <= s:num ==> 0 < s`) th))
       THEN USE_THEN "F7" (fun th1 -> (DISCH_THEN (fun th2 -> (DISCH_THEN (fun th3 -> (USE_THEN "Y1" (fun th4 -> (MP_TAC (MATCH_MP lemma_face_walkup_eliminate_dart_on_Moebius_contour (CONJ th1 (CONJ th2 (CONJ th3 (SYM th4)))))))))))))
       THEN REWRITE_TAC[lemma_sub_two_numbers; SUB_REFL]
       THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "Y4") (CONJUNCTS_THEN2 (LABEL_TAC "Y5") (LABEL_TAC "Y6")))
       THEN ABBREV_TAC `G = face_walkup (H:(A)hypermap) ((p:num->A) (s:num))`
       THEN POP_ASSUM (LABEL_TAC "Y7")
       THEN SUBGOAL_THEN `one_step_contour (G:(A)hypermap) ((p:num->A) ((s:num)-1)) ((shift_path (p:num->A) ((s:num)+1)) 0)` ASSUME_TAC
       THEN REWRITE_TAC[lemma_shift_path_evaluation]
       THEN REWRITE_TAC[ADD_0]
       THEN REMOVE_THEN "Y6" (fun th -> REWRITE_TAC[th])
       THEN SUBGOAL_THEN `(!i:num j:num. i <= (s:num-1) /\ j <= 0 ==> ~(shift_path (p:num->A) (s+1) j = p i))` ASSUME_TAC
       THENL[REWRITE_TAC[LE]
	  THEN REPEAT GEN_TAC
	  THEN DISCH_THEN (CONJUNCTS_THEN2 (ASSUME_TAC) (SUBST1_TAC))
	  THEN REWRITE_TAC[lemma_shift_path_evaluation; GSYM ADD_ASSOC; ADD_0]
	  THEN USE_THEN "F10" (MP_TAC o SPECL[`(s:num) + 1 `; `i:num`])
	  THEN POP_ASSUM (fun th -> REWRITE_TAC[MP (ARITH_RULE `i:num  <= (s:num) - 1 ==> i < s + 1`) th; LE_REFL])
	  THEN MESON_TAC[]; ALL_TAC]
       THEN REMOVE_THEN "Y4" (fun th1 -> (REMOVE_THEN "Y5" (fun th2 -> (POP_ASSUM (fun th4-> (POP_ASSUM (fun th3 -> MP_TAC (MATCH_MP concatenate_two_disjoint_contours (CONJ th1 (CONJ th2 (CONJ th3 th4)))))))))))
       THEN REWRITE_TAC[lemma_shift_path_evaluation]
       THEN REWRITE_TAC[ADD_0]
       THEN USE_THEN "F19" (fun th -> REWRITE_TAC[MP (ARITH_RULE `2 <= s:num ==> s-1+0+1 = s`) th])
       THEN DISCH_THEN (X_CHOOSE_THEN `g:num->A` (CONJUNCTS_THEN2 (LABEL_TAC "Y10") (CONJUNCTS_THEN2 (LABEL_TAC "Y11") (CONJUNCTS_THEN2 (LABEL_TAC "Y12") (LABEL_TAC "Y14" o CONJUNCT1)))))
       THEN SUBGOAL_THEN `is_Moebius_contour (G:(A)hypermap) (g:num->A) (s:num)` (LABEL_TAC "Y15")
       THENL[REWRITE_TAC[is_Moebius_contour]
	   THEN USE_THEN "Y12" (fun th -> REWRITE_TAC[th])
	   THEN EXISTS_TAC `1:num`
	   THEN EXISTS_TAC `1:num`
	   THEN USE_THEN "F19" (fun th -> REWRITE_TAC[MATCH_MP (ARITH_RULE `2 <= s:num ==> 1 < s`) th; ARITH_RULE `0 < 1 /\ 1 <= 1`])
	   THEN REMOVE_THEN "Y10" SUBST1_TAC
	   THEN REMOVE_THEN "Y11" SUBST1_TAC
	   THEN POP_ASSUM (MP_TAC o SPEC `1`)
	   THEN USE_THEN "F19" (fun th -> REWRITE_TAC[MATCH_MP (ARITH_RULE `2 <= s:num ==> 1 <= s - 1`) th])
	   THEN DISCH_THEN SUBST1_TAC
	   THEN EXPAND_TAC "G"
	   THEN STRIP_TAC
	   THENL[USE_THEN "F10" (MP_TAC o SPECL[`s:num`; `0`])
              THEN USE_THEN "F19" (fun th ->  REWRITE_TAC[MP (ARITH_RULE `2 <= s:num ==> 0 < s`) th; ARITH_RULE `s:num <= s + 1`])
	      THEN DISCH_TAC
	      THEN SUBGOAL_THEN `~((p:num->A) 0 = inverse (node_map (H:(A)hypermap)) ((p:num->A) (s:num)))` (ASSUME_TAC)
	      THENL[REWRITE_TAC[GSYM node_map_inverse_representation]
		 THEN USE_THEN "F16" (SUBST1_TAC o SYM)
		 THEN USE_THEN "F10" (MP_TAC o SPECL[`(s:num)`; `1`])
		 THEN USE_THEN "F19" (fun th ->  REWRITE_TAC[MP (ARITH_RULE `2 <= (s:num) ==> 1 < s`) th; ARITH_RULE `s:num <= s + 1`])
		 THEN MESON_TAC[]; ALL_TAC]
	      THEN MP_TAC (CONJUNCT2(CONJUNCT2(SPECL[`H:(A)hypermap`; `(p:num->A) (s:num)`; `(p:num->A) (0:num)`] node_map_face_walkup)))
	      THEN REPLICATE_TAC 2 (POP_ASSUM (fun th -> REWRITE_TAC[th]))
	      THEN USE_THEN "F16" (fun th -> REWRITE_TAC[th])
	      THEN REWRITE_TAC[EQ_SYM]; ALL_TAC]
	   THEN USE_THEN "F10" (MP_TAC o SPECL[`s:num`; `1`])
	   THEN USE_THEN "F19" (fun th ->  REWRITE_TAC[MP (ARITH_RULE `2 <= s:num ==> 1 < s`) th; ARITH_RULE `s:num <= s + 1`])
	   THEN DISCH_TAC
	   THEN SUBGOAL_THEN `~((p:num->A) 1 = inverse (node_map (H:(A)hypermap)) ((p:num->A) (s:num)))` (ASSUME_TAC)
	   THENL[REWRITE_TAC[GSYM node_map_inverse_representation]
	       THEN USE_THEN "F16k" (SUBST1_TAC o SYM)
	       THEN USE_THEN "F10" (MP_TAC o SPECL[`(s:num)+1`; `s:num`])
	       THEN USE_THEN "F19" (fun th ->  REWRITE_TAC[ARITH_RULE `s:num < s + 1`; LE_REFL]); ALL_TAC]
	   THEN MP_TAC (CONJUNCT2(CONJUNCT2(SPECL[`H:(A)hypermap`; `(p:num->A) (s:num)`; `(p:num->A) (1:num)`] node_map_face_walkup)))
	   THEN REPLICATE_TAC 2 (POP_ASSUM (fun th -> REWRITE_TAC[th]))
	   THEN USE_THEN "F16k" (fun th -> REWRITE_TAC[th])
	   THEN REWRITE_TAC[EQ_SYM]; ALL_TAC]
       THEN SUBGOAL_THEN `(p:num->A) (s:num) IN dart (H:(A)hypermap)` (LABEL_TAC "Y20")
       THENL[USE_THEN "F11" (SUBST1_TAC o SYM)
	   THEN REWRITE_TAC[IN_ELIM_THM; LE_0]
	   THEN EXISTS_TAC `s:num`
	   THEN REWRITE_TAC[ARITH_RULE `s:num <= s + 1`]; ALL_TAC]
       THEN USE_THEN "Y20" (MP_TAC o MATCH_MP lemma_card_face_walkup_dart)
       THEN USE_THEN "Y7" SUBST1_TAC
       THEN  USE_THEN "F1" SUBST1_TAC
       THEN  REWRITE_TAC[GSYM ADD1; EQ_SUC]
       THEN  DISCH_THEN (LABEL_TAC "Y21")
       THEN  USE_THEN "FI" (MP_TAC o SPEC `face_walkup (H:(A)hypermap) ((p:num->A) (s:num))`)
       THEN  USE_THEN "Y20" (fun th1 -> (USE_THEN "F2" (fun th2 -> REWRITE_TAC[MATCH_MP lemmaSGCOSXK (CONJ th1 th2)])))
       THEN  USE_THEN "Y7" SUBST1_TAC
       THEN POP_ASSUM (fun th -> REWRITE_TAC[th])
       THEN EXISTS_TAC `g:num->A`
       THEN EXISTS_TAC `s:num`
       THEN USE_THEN "Y15" (fun th -> REWRITE_TAC[th]); ALL_TAC]
   THEN POP_ASSUM (fun th1 -> (REMOVE_THEN "F15" (fun th2 -> (MP_TAC (MP (ARITH_RULE `~(2 < k:num) /\ 1 < k ==> k =2`) (CONJ th1 th2))))))
   THEN DISCH_THEN (SUBST_ALL_TAC)
   THEN REMOVE_THEN "F5" MP_TAC
   THEN USE_THEN "F11" SUBST1_TAC
   THEN REWRITE_TAC[ARITH_RULE `SUC 2 = 3`]
   THEN DISCH_TAC
   THEN MP_TAC (SPEC `H:(A)hypermap` lemma_minimum_Moebius_hypermap)
   THEN POP_ASSUM (fun th -> REWRITE_TAC[th]) 
   THEN REWRITE_TAC[NOT_IMP]
   THEN USE_THEN "F2" (fun th -> REWRITE_TAC[th])
   THEN EXISTS_TAC `p:num->A`
   THEN EXISTS_TAC `2`
   THEN USE_THEN "F3" (fun th -> REWRITE_TAC[th]));;

(* HERE I DEFINITE THE NOTION OF THE LOOP. THIS DEFINITION DOES NOT DEPEND ON THE ORDER OF ITS VERTICES *)

let exist_loop = prove(`?L:(A->bool)#(A->A). FINITE (FST L) /\ SND L permutes FST L /\ ?x:A. x IN FST L /\ orbit_map (SND L) x = FST L`,
   MP_TAC(SPEC `UNIV:A->bool` MEMBER_NOT_EMPTY)
   THEN REWRITE_TAC[UNIV_NOT_EMPTY]
   THEN DISCH_THEN (X_CHOOSE_THEN `x:A` (ASSUME_TAC))
   THEN EXISTS_TAC `({x:A}, I:A->A)`
   THEN REWRITE_TAC[FST; SND]
   THEN REWRITE_TAC[FINITE_SINGLETON; PERMUTES_I; I_O_ID]
   THEN EXISTS_TAC `x:A`
   THEN REWRITE_TAC[IN_SING; GSYM orbit_one_point; I_THM]);;

let loop_tybij = new_type_definition "loop"("loop", "tuple_loop") exist_loop;;

let dart_of = new_definition `!L:(A)loop. dart_of L = FST (tuple_loop L)`;;

let next = new_definition `!L:(A)loop. next L = SND (tuple_loop L)`;;

let back = new_definition `!L:(A)loop. back L = inverse (SND (tuple_loop L))`;;

let inside = new_definition `!(L:(A)loop) x:A. x inside L <=> x IN (dart_of L)`;;

let size = new_definition `size (L:(A)loop) = CARD (dart_of L)`;;

let top = new_definition `top (L:(A)loop) = PRE (CARD (dart_of L))`;;

let is_loop = new_definition `!(H:(A)hypermap) (L:(A)loop). is_loop H L <=> (!x:A. x inside L ==> one_step_contour H x (next L x))`;;

let contour_of = new_definition `!(L:(A)loop) x:A k:num. contour_of L x k = ((next L) POWER k) x`;;

let loop_lemma = prove(`!L:(A)loop. FINITE (dart_of L) /\(next L) permutes (dart_of L) /\ (?x:A. x inside L /\ orbit_map (next L) x = dart_of L)`,
   GEN_TAC THEN REWRITE_TAC[inside; loop_tybij; dart_of; next] THEN MESON_TAC[loop_tybij]);;

let lemma_loop_representation = prove(`!s:A->bool p:A->A x:A. FINITE s /\ p permutes s /\ orbit_map p x = s ==> dart_of (loop (s, p)) = s /\ next (loop (s,p)) = p`,
 REPEAT GEN_TAC  THEN STRIP_TAC
   THEN MP_TAC (SPECL[`p:A->A`; `x:A`] orbit_reflect)
   THEN ASM_REWRITE_TAC[]
   THEN POP_ASSUM MP_TAC
   THEN REWRITE_TAC[IMP_IMP]
   THEN ONCE_REWRITE_TAC[CONJ_SYM]
   THEN DISCH_THEN (ASSUME_TAC o SIMPLE_EXISTS `x:A`)
   THEN MP_TAC (SPEC `(s:A->bool, p:A->A)` (CONJUNCT2 loop_tybij))
   THEN REWRITE_TAC[FST; SND; next; dart_of]
   THEN ASM_REWRITE_TAC[]
   THEN DISCH_THEN SUBST1_TAC
   THEN REWRITE_TAC[FST; SND]);;

let lemma_loop_identity = prove(`!(L:(A)loop) (L':(A)loop). L = L' <=> (dart_of L = dart_of L' /\ next L = next L')`,
 REPEAT GEN_TAC
   THEN EQ_TAC
   THENL[MESON_TAC[]; ALL_TAC]
   THEN REWRITE_TAC[dart_of; next]
   THEN STRIP_TAC
   THEN SUBGOAL_THEN `tuple_loop (L:(A)loop) = tuple_loop (L':(A)loop)` ASSUME_TAC
   THENL[SUBGOAL_THEN `tuple_loop (L:(A)loop) = FST (tuple_loop (L:(A)loop)), SND (tuple_loop (L:(A)loop))` ASSUME_TAC
       THENL[MESON_TAC[PAIR]; ALL_TAC]
       THEN SUBGOAL_THEN `tuple_loop (L':(A)loop) = FST (tuple_loop (L':(A)loop)), SND (tuple_loop (L':(A)loop))` ASSUME_TAC
       THENL[MESON_TAC[PAIR]; ALL_TAC]
       THEN REPLICATE_TAC 2 (POP_ASSUM SUBST1_TAC); ALL_TAC]
   THEN ASM_REWRITE_TAC[PAIR_EQ]
   THEN POP_ASSUM (fun th -> MESON_TAC[CONJUNCT1 loop_tybij; th]));;

let lemma_permute_loop = prove(`!L:(A)loop. next L permutes dart_of L /\ back L permutes dart_of L`,
   GEN_TAC
   THEN REWRITE_TAC[loop_lemma]
   THEN REWRITE_TAC[back; GSYM next]
   THEN MATCH_MP_TAC PERMUTES_INVERSE
   THEN REWRITE_TAC[loop_lemma]);;

let lemma_transitive_permutation = prove(`!(L:(A)loop) x:A. x inside L ==> dart_of L = orbit_map (next L) x`,
 REPEAT GEN_TAC
   THEN MP_TAC (SPEC `L:(A)loop` loop_lemma)
   THEN REWRITE_TAC[inside]
   THEN DISCH_THEN(CONJUNCTS_THEN2 ASSUME_TAC(CONJUNCTS_THEN2 ASSUME_TAC (X_CHOOSE_THEN `y:A`(CONJUNCTS_THEN2 ASSUME_TAC(SUBST1_TAC o SYM)))))
   THEN REPEAT STRIP_TAC   
   THEN MATCH_MP_TAC lemma_orbit_identity
   THEN EXISTS_TAC `dart_of (L:(A)loop)`
   THEN ASM_REWRITE_TAC[]);;

let lemma_size = prove(`!(L:(A)loop). ~(dart_of L = {}) /\ 0 < size L /\ size L = SUC(top L)`,
    REPEAT GEN_TAC
    THEN MP_TAC (SPEC `L:(A)loop` loop_lemma)
    THEN DISCH_THEN(CONJUNCTS_THEN2(LABEL_TAC "F1")(CONJUNCTS_THEN2 (LABEL_TAC "F2")(X_CHOOSE_THEN `y:A`(ASSUME_TAC o REWRITE_RULE[inside] o CONJUNCT1))))
    THEN SUBGOAL_THEN `~(dart_of (L:(A)loop) = {})` (fun th-> REWRITE_TAC[th])
    THENL[REWRITE_TAC[GSYM MEMBER_NOT_EMPTY]
       THEN EXISTS_TAC `y:A` THEN ASM_REWRITE_TAC[]; ALL_TAC]
    THEN SUBGOAL_THEN `0 < size (L:(A)loop)` ASSUME_TAC
    THENL[ REWRITE_TAC[size]
       THEN USE_THEN "F1"(fun th -> (POP_ASSUM(fun th1-> (MP_TAC (MATCH_MP CARD_ATLEAST_1 (CONJ th th1))))))
       THEN DISCH_THEN (fun th -> REWRITE_TAC[REWRITE_RULE[LT1_NZ] th])
       THEN REWRITE_TAC[FUN_EQ_THM; I_THM]; ALL_TAC]   
    THEN ASM_REWRITE_TAC[]
    THEN REWRITE_TAC[top; GSYM size]
    THEN MATCH_MP_TAC LT_SUC_PRE
    THEN ASM_REWRITE_TAC[]);;

let lemma_order_next = prove(`!L:(A)loop. (next L) POWER (size L) = I`,
 REPEAT GEN_TAC
   THEN MP_TAC (SPEC `L:(A)loop` loop_lemma)
   THEN DISCH_THEN(CONJUNCTS_THEN2(LABEL_TAC "F1")(LABEL_TAC "F2" o CONJUNCT1))
   THEN REWRITE_TAC[FUN_EQ_THM; I_THM; size]
   THEN GEN_TAC
   THEN ASM_CASES_TAC `~((x:A) IN dart_of (L:(A)loop))`
   THENL[USE_THEN "F2" (fun th->(POP_ASSUM(fun th1->REWRITE_TAC[MATCH_MP power_permutation_outside_domain (CONJ th th1)]))); ALL_TAC]
   THEN POP_ASSUM (ASSUME_TAC o REWRITE_RULE[GSYM inside])
   THEN MP_TAC (SPECL[`L:(A)loop`; `x:A`] lemma_transitive_permutation)
   THEN POP_ASSUM(fun th -> REWRITE_TAC[th])
   THEN DISCH_THEN SUBST1_TAC 
   THEN REMOVE_THEN "F1"(fun th -> (POP_ASSUM(fun th1-> (MESON_TAC[MATCH_MP lemma_cycle_orbit (CONJ th th1)])))));;

let lemma_back_and_next_outside_loop = prove(`!L:(A)loop  x:A. ~(x inside L) ==> back L x = x /\ next L x = x`,
    REPEAT GEN_TAC
    THEN REWRITE_TAC[inside]
    THEN DISCH_THEN (LABEL_TAC "F1")
    THEN ASSUME_TAC ((CONJUNCT1(CONJUNCT2(SPEC `L:(A)loop` loop_lemma))))
    THEN USE_THEN "F1"(fun th->(POP_ASSUM (MP_TAC o REWRITE_RULE[th] o SPEC `x:A` o MATCH_MP map_permutes_outside_domain)))
    THEN DISCH_THEN (fun th-> REWRITE_TAC[th])
    THEN ASSUME_TAC ((CONJUNCT2(SPEC `L:(A)loop` lemma_permute_loop)))
    THEN REMOVE_THEN "F1"(fun th->(POP_ASSUM (MP_TAC o REWRITE_RULE[th] o SPEC `x:A` o MATCH_MP map_permutes_outside_domain)))
    THEN DISCH_THEN (fun th-> REWRITE_TAC[th])
    THEN SIMP_TAC[]);;

let lemma_power_back_and_next_outside_loop = prove(`!L:(A)loop x:A m:num. ~(x inside L) ==> ((back L) POWER m) x = x /\ ((next L) POWER m) x = x`,
 REPEAT GEN_TAC
   THEN REWRITE_TAC[inside]
   THEN DISCH_THEN (LABEL_TAC "F1")
   THEN ASSUME_TAC ((CONJUNCT1(CONJUNCT2(SPEC `L:(A)loop` loop_lemma))))
   THEN USE_THEN "F1"(fun th1->(POP_ASSUM (fun th -> REWRITE_TAC[MATCH_MP power_permutation_outside_domain (CONJ th th1)])))
   THEN ASSUME_TAC ((CONJUNCT2(SPEC `L:(A)loop` lemma_permute_loop)))
   THEN REMOVE_THEN "F1"(fun th1->(POP_ASSUM (fun th -> REWRITE_TAC[MATCH_MP power_permutation_outside_domain (CONJ th th1)]))));;

let lemma_inverse_on_loop = prove(`!L:(A)loop. next L = inverse (back L) /\ back L = inverse (next L)`,
    STRIP_TAC
    THEN REWRITE_TAC[ back; GSYM next]
    THEN CONV_TAC SYM_CONV
    THEN ASSUME_TAC ((CONJUNCT1(CONJUNCT2(SPEC `L:(A)loop` loop_lemma))))
    THEN POP_ASSUM(fun th-> REWRITE_TAC[MATCH_MP PERMUTES_INVERSE_INVERSE th]));;
 
let lemma_inverse_evaluation = prove(`!L:(A)loop x:A. back L (next L x) = x /\ next L (back L x) = x`,
   REPEAT GEN_TAC
   THEN REWRITE_TAC[CONJUNCT2(SPEC `L:(A)loop` lemma_inverse_on_loop)]
   THEN REWRITE_TAC[MATCH_MP PERMUTES_INVERSES (CONJUNCT1(SPEC `L:(A)loop` lemma_permute_loop))]);;

let lemma_second_inverse_on_loop = prove(`!L:(A)loop m:num. next L POWER m = inverse ((back L) POWER m) /\ back L POWER m = inverse ((next L) POWER m)`,
   REPEAT GEN_TAC
   THEN (MP_TAC(CONJUNCT1(SPEC `L:(A)loop`lemma_permute_loop)))
   THEN DISCH_THEN (MP_TAC o SPEC `m:num` o MATCH_MP lemma_power_inverse)
   THEN REWRITE_TAC[GSYM lemma_inverse_on_loop]
    THEN MESON_TAC[]);;

let lemma_second_inverse_evaluation = prove(`
  !L:(A)loop (x:A) (m:num).(next L POWER m) ((back L POWER m) x) = x /\ (back L POWER m) ((next L POWER m) x) = x`, 
 REPEAT GEN_TAC
   THEN LABEL_TAC "F1" (CONJUNCT1(SPEC `L:(A)loop` lemma_permute_loop))
   THEN REWRITE_TAC[CONJUNCT2(SPECL[`L:(A)loop`; `m:num`] lemma_second_inverse_on_loop)]
   THEN POP_ASSUM (MP_TAC o  SPEC `m:num` o MATCH_MP power_permutation)
   THEN DISCH_THEN (fun th-> REWRITE_TAC[MATCH_MP PERMUTES_INVERSES th]));;

let lemma_next_power_representation = prove(`!L:(A)loop (x:A) (y:A). x inside L /\ y inside L ==> ?k:num. k <= top L /\ y = ((next L) POWER k) x`,
  REPEAT GEN_TAC
   THEN DISCH_THEN (CONJUNCTS_THEN2 ASSUME_TAC (MP_TAC o REWRITE_RULE[inside]))
   THEN POP_ASSUM (fun th -> REWRITE_TAC[MATCH_MP lemma_transitive_permutation th])
    THEN REWRITE_TAC[GSYM LT_SUC_LE]
    THEN STRIP_ASSUME_TAC(CONJUNCT2(SPEC `L:(A)loop` lemma_size))
    THEN POP_ASSUM (SUBST1_TAC o SYM)
    THEN ASSUME_TAC (SPEC `L:(A)loop` lemma_order_next)
    THEN  POP_ASSUM (fun th-> MP_TAC (REWRITE_RULE[I_THM](AP_THM th `x:A`)))
    THEN POP_ASSUM (MP_TAC o REWRITE_RULE[LT_NZ])
    THEN DISCH_THEN(fun th-> DISCH_THEN(fun th1-> REWRITE_TAC[MATCH_MP orbit_cyclic (CONJ th th1)]))
    THEN REWRITE_TAC[IN_ELIM_THM]);;

let lemma_power_next_in_loop = prove(`!L:(A)loop x:A k:num. x inside L ==> ((next L POWER k) x) inside L`,
   REPEAT GEN_TAC
   THEN REWRITE_TAC[inside]
   THEN STRIP_TAC
   THEN MP_TAC(SPECL[`k:num`; `x:A`] (MATCH_MP iterate_orbit (CONJUNCT1(SPEC `L:(A)loop` lemma_permute_loop))))
   THEN ASM_REWRITE_TAC[]);;

let lemma_power_back_in_loop = prove(`!L:(A)loop x:A k:num. x inside L ==> ((back L POWER k) x) inside L`,
   REPEAT GEN_TAC
   THEN REWRITE_TAC[inside]
   THEN STRIP_TAC
   THEN MP_TAC(SPECL[`k:num`; `x:A`] (MATCH_MP iterate_orbit (CONJUNCT2(SPEC `L:(A)loop` lemma_permute_loop))))
   THEN ASM_REWRITE_TAC[]);;

let support_loop_sub_dart = prove(`!(H:(A)hypermap) (L:(A)loop) (x:A). is_loop H L /\ x IN dart H /\ x inside L ==> dart_of L SUBSET dart H`,
 REPEAT GEN_TAC
   THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F1") (CONJUNCTS_THEN2 (LABEL_TAC "F2") (LABEL_TAC "F3")))
   THEN USE_THEN "F3" (fun th -> REWRITE_TAC[MATCH_MP lemma_transitive_permutation th])
   THEN SUBGOAL_THEN `!j:num. ((next (L:(A)loop)) POWER j) (x:A) IN dart (H:(A)hypermap)` ASSUME_TAC
   THENL[INDUCT_TAC THENL[ASM_REWRITE_TAC[POWER_0; I_THM] THEN REWRITE_TAC[COM_POWER; o_THM]; ALL_TAC]
      THEN REWRITE_TAC[COM_POWER; o_THM]
      THEN REMOVE_THEN "F3" (fun th -> ASSUME_TAC(SPEC `j:num` (MATCH_MP lemma_power_next_in_loop th)))
      THEN ABBREV_TAC `y = (next (L:(A)loop) POWER (j:num)) (x:A)`
      THEN REMOVE_THEN "F1" (MP_TAC o SPEC `y:A` o REWRITE_RULE[is_loop])
      THEN ASM_REWRITE_TAC[]
      THEN REWRITE_TAC[one_step_contour]
      THEN STRIP_TAC
      THENL[POP_ASSUM SUBST1_TAC
	 THEN UNDISCH_THEN `y:A IN dart (H:(A)hypermap)` (fun th -> REWRITE_TAC[MATCH_MP lemma_dart_invariant th]); ALL_TAC]
      THEN POP_ASSUM SUBST1_TAC
      THEN UNDISCH_THEN `y:A IN dart (H:(A)hypermap)` (fun th -> REWRITE_TAC[MATCH_MP lemma_dart_inveriant_under_inverse_maps th]); ALL_TAC]
   THEN REWRITE_TAC[orbit_map; SUBSET; IN_ELIM_THM]
   THEN GEN_TAC
   THEN DISCH_THEN (X_CHOOSE_THEN `m:num` (SUBST1_TAC o CONJUNCT2))
   THEN POP_ASSUM (fun th -> REWRITE_TAC[th]));;

let let_order_for_loop = prove(`!(H:(A)hypermap) (L:(A)loop) (x:A). is_loop H L /\ x inside L 
   ==> is_inj_contour H (contour_of L x) (top L) /\ one_step_contour H (contour_of L x (top L)) (contour_of L x 0)`,
 REPEAT GEN_TAC
   THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F1") (LABEL_TAC "F2"))
   THEN STRIP_TAC
   THENL[REWRITE_TAC[lemma_def_inj_contour]
      THEN STRIP_TAC
      THENL[REWRITE_TAC[lemma_def_contour]
	 THEN REPEAT STRIP_TAC
	 THEN REWRITE_TAC[contour_of]
	 THEN REWRITE_TAC[COM_POWER; o_THM]
	 THEN USE_THEN "F1"(MP_TAC o REWRITE_RULE[is_loop])
	 THEN USE_THEN "F2" (MP_TAC o SPEC `i:num` o MATCH_MP lemma_power_next_in_loop)
	 THEN MESON_TAC[]; ALL_TAC]
      THEN REWRITE_TAC[contour_of]
      THEN ONCE_REWRITE_TAC[MESON[] `~(A=B) <=> ~(B=A)`]
      THEN REWRITE_TAC[GSYM lemma_def_inj_orbit]
      THEN MP_TAC (SPEC `L:(A)loop` loop_lemma)
      THEN REWRITE_TAC[CONJ_ASSOC]
      THEN DISCH_THEN (MP_TAC o SPECL[`x:A`; `top (L:(A)loop)`] o MATCH_MP lemma_segment_orbit o CONJUNCT1)
      THEN USE_THEN "F2"(fun th->REWRITE_TAC[SYM(MATCH_MP lemma_transitive_permutation th)])
      THEN REWRITE_TAC[GSYM size; lemma_size; LT_PLUS]; ALL_TAC]
   THEN REWRITE_TAC[contour_of; POWER_0; I_THM]
   THEN USE_THEN "F1"(MP_TAC o SPEC `(next (L:(A)loop) POWER  top L) x` o  REWRITE_RULE[is_loop])
   THEN REWRITE_TAC[iterate_map_valuation; GSYM lemma_size; lemma_order_next; I_THM]
   THEN USE_THEN "F2" (MP_TAC o SPEC `top (L:(A)loop)` o MATCH_MP lemma_power_next_in_loop)
   THEN MESON_TAC[]);;

(*********************************************************************************************************************)

let set_dart_of = new_definition `set_dart_of (p:num->A) (n:num) = {p (i:num) | i <= n}`;;

let lemma_number_darts_of_inj_contour = prove(`!(H:(A)hypermap) (p:num->A) (n:num). is_inj_contour H p n ==> CARD (set_dart_of p n) = SUC n`,
   REPEAT GEN_TAC
   THEN REWRITE_TAC[lemma_def_inj_contour; set_dart_of]
   THEN CONV_TAC ((LAND_CONV o ONCE_DEPTH_CONV) SYM_CONV)
   THEN REWRITE_TAC[GSYM LT_SUC_LE]
   THEN DISCH_THEN (fun th -> REWRITE_TAC[MATCH_MP CARD_FINITE_SERIES_EQ (CONJUNCT2 th)]));;

let lemma_inj_contour_inside_darts = prove(`!(H:(A)hypermap) (p:num->A) (n:num). 0 < n /\ is_inj_contour H p n ==> set_dart_of p n  SUBSET dart H`,
     REPEAT GEN_TAC
     THEN DISCH_THEN (fun th -> (MP_TAC (MATCH_MP lemma_first_dart_on_inj_contour th) THEN ASSUME_TAC (CONJUNCT2 th)))
     THEN POP_ASSUM (MP_TAC o CONJUNCT1 o REWRITE_RULE[lemma_def_inj_contour])
     THEN REWRITE_TAC[IMP_IMP; CONJ_SYM]
     THEN DISCH_THEN (fun th -> REWRITE_TAC[MATCH_MP lemma_darts_in_contour th; set_dart_of]));;

let lemma_path_finite = prove(`!(p:num->A) (n:num). FINITE (set_dart_of p n)`,
   REWRITE_TAC[set_dart_of; GSYM LT_SUC_LE; FINITE_SERIES]);;

let in_path = new_definition `in_path (p:num->A) (n:num) (x:A) <=>  x IN set_dart_of p n`;;

let lemma_in_path = prove(`!p:num->A n:num x:A. in_path p n x <=> ?j:num. j <= n /\ x = p j`,
   REWRITE_TAC[in_path; set_dart_of; IN_ELIM_THM]);;

let lemma_in_path2 = prove(`!p:num->A n:num x:A j:num. j <= n /\ x = p j ==> in_path p n x`, MESON_TAC[lemma_in_path]);;

let lemma_not_in_path = prove(`!p:num->A n:num x:A. ~(in_path p n x) <=> !j:num. j <= n ==> ~(x = p j)`,
   REPEAT GEN_TAC THEN REWRITE_TAC[lemma_in_path] THEN MESON_TAC[]);;

let lemma_dart_loop_via_path = prove(`!L:(A)loop x:A. x inside L ==> dart_of L = set_dart_of (contour_of L x) (top L)`,
 REPEAT STRIP_TAC
   THEN POP_ASSUM (fun th -> REWRITE_TAC[MATCH_MP lemma_transitive_permutation th])
   THEN MP_TAC (AP_THM (SPEC `L:(A)loop` lemma_order_next) `x:A`)
   THEN REWRITE_TAC[I_THM]
   THEN MP_TAC(CONJUNCT1(CONJUNCT2(SPEC `L:(A)loop` lemma_size)))
   THEN REWRITE_TAC[LT_NZ; IMP_IMP; set_dart_of; contour_of]
   THEN DISCH_THEN (MP_TAC o MATCH_MP orbit_cyclic)
   THEN REWRITE_TAC[lemma_size; GSYM LT_SUC_LE]);;

let lemma_inside = prove(`!L:(A)loop x:A. x inside L ==> (!y:A. y inside L <=> in_path (contour_of L x) (top L) y)`,
   REPEAT STRIP_TAC
   THEN REWRITE_TAC[inside]
   THEN POP_ASSUM (fun th -> REWRITE_TAC[MATCH_MP lemma_dart_loop_via_path th])
   THEN REWRITE_TAC[in_path]);;

let lemmaILTXRQD =prove(`!(H:(A)hypermap) (L:(A)loop) (p:num->A) (k:num).((is_loop H L) /\ (is_inj_contour H p k) /\ (2 <= k) /\ ((p 0) inside L) /\ (p k) inside L /\ (!i:num. 0 < i /\ i < k ==> ~((p i) inside L)) /\ (!q:num->A m:num. ~(is_Moebius_contour H q m))) ==>
(p 1 = inverse (node_map H) (p 0) ==> ~(p k = face_map H (p (PRE k)))) /\ (p 1 = face_map H (p 0) ==>  ~(p k = inverse (node_map H) (p (PRE k))))`,
   REPEAT GEN_TAC
   THEN DISCH_THEN(CONJUNCTS_THEN2 (LABEL_TAC "F1") (CONJUNCTS_THEN2 (LABEL_TAC "F2") (CONJUNCTS_THEN2 (LABEL_TAC "F3") (CONJUNCTS_THEN2 (LABEL_TAC "F4") (CONJUNCTS_THEN2 (LABEL_TAC "F5") (CONJUNCTS_THEN2 (LABEL_TAC "F6") (LABEL_TAC "F7")))))))
   THEN USE_THEN "F2" MP_TAC
   THEN REWRITE_TAC[lemma_def_inj_contour]
   THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "FC") (LABEL_TAC "F8"))
   THEN USE_THEN "F8" (MP_TAC o SPECL[`k:num`; `0`])
   THEN USE_THEN "F3" (fun th -> REWRITE_TAC[MATCH_MP (ARITH_RULE `2 <= k:num ==> 0 < k`) th; LE_REFL])
   THEN DISCH_THEN (LABEL_TAC "F9")
   THEN SUBGOAL_THEN `1 <= top (L:(A)loop)` (LABEL_TAC "F10")
   THENL[ ONCE_REWRITE_TAC[GSYM LE_SUC]
      THEN REWRITE_TAC[GSYM TWO]
      THEN REWRITE_TAC[GSYM lemma_size; size]
      THEN MATCH_MP_TAC CARD_ATLEAST_2
      THEN EXISTS_TAC `(p:num->A) 0`
      THEN EXISTS_TAC `(p:num->A) (k:num)`
      THEN REWRITE_TAC[GSYM inside]
      THEN ASM_REWRITE_TAC[loop_lemma]; ALL_TAC]
   THEN USE_THEN "F3" (MP_TAC o MATCH_MP (ARITH_RULE `2 <= k:num ==> 0 < PRE k /\ 0 < k /\ PRE k < k`))
   THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "K1") (CONJUNCTS_THEN2 (LABEL_TAC "K2") (LABEL_TAC "K3")))
   THEN STRIP_TAC
   THENL[REWRITE_TAC[GSYM node_map_inverse_representation]
       THEN DISCH_THEN (LABEL_TAC "G10")
       THEN DISCH_THEN (LABEL_TAC "G12")
       THEN REMOVE_THEN "F7" MP_TAC
       THEN REWRITE_TAC[NOT_FORALL_THM]
       THEN REMOVE_THEN "F4" MP_TAC
       THEN USE_THEN "F5" (fun th-> REWRITE_TAC[MATCH_MP lemma_inside th])
       THEN DISCH_THEN (LABEL_TAC "G4")
       THEN REMOVE_THEN "F6" MP_TAC
       THEN USE_THEN "F5" (fun th-> REWRITE_TAC[MATCH_MP lemma_inside th])
       THEN DISCH_THEN (LABEL_TAC "G6")
       THEN MP_TAC (SPECL[`L:(A)loop`; `(p:num->A) (k:num)`; `0`] contour_of)
       THEN REWRITE_TAC[POWER_0; I_THM]
       THEN DISCH_THEN (LABEL_TAC "G15")
       THEN USE_THEN "F1" (fun th-> (REMOVE_THEN "F5" (fun th1-> (MP_TAC (MATCH_MP let_order_for_loop (CONJ th th1))))))
       THEN ABBREV_TAC `ploop = contour_of (L:(A)loop) ((p:num->A) (k:num))`
       THEN ABBREV_TAC `n = top (L:(A)loop)`
       THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "G16") (MP_TAC))
       THEN REWRITE_TAC[one_step_contour]
       THEN USE_THEN "G15" SUBST1_TAC
       THEN STRIP_TAC
       THENL[POP_ASSUM MP_TAC
          THEN USE_THEN "G12" SUBST1_TAC
          THEN REWRITE_TAC[face_map_injective]
          THEN DISCH_THEN (fun th-> (ASSUME_TAC (MATCH_MP lemma_in_path2 (CONJ (SPEC `n:num` LE_REFL) th))))
          THEN USE_THEN "G6" (MP_TAC o SPEC `PRE k`)
          THEN USE_THEN "K1" (fun th -> REWRITE_TAC[th])
          THEN USE_THEN "K3" (fun th -> REWRITE_TAC[th])
          THEN POP_ASSUM (fun th -> REWRITE_TAC[th]); ALL_TAC]
      THEN POP_ASSUM MP_TAC
      THEN REWRITE_TAC[GSYM node_map_inverse_representation]
      THEN DISCH_THEN (LABEL_TAC "G17")
      THEN USE_THEN "K2" MP_TAC
      THEN REWRITE_TAC[LT0_LE1]
      THEN USE_THEN "F2" (fun th1 -> (DISCH_THEN (fun th2 -> (MP_TAC (MATCH_MP lemma_shift_inj_contour (CONJ th1 th2))))))
      THEN USE_THEN "K2" (fun th -> REWRITE_TAC[MATCH_MP (ARITH_RULE `0 < k:num ==> k-1 = PRE k`) th])
      THEN DISCH_THEN (LABEL_TAC "G18")
      THEN USE_THEN "K2" (fun th -> REWRITE_TAC[MATCH_MP (ARITH_RULE `0 < k:num ==> k - 1 = PRE k`) th])
      THEN MP_TAC(SPECL[`p:num->A`; `1`; `PRE k`] lemma_shift_path_evaluation)
      THEN ONCE_REWRITE_TAC[GSYM ADD_SYM]
      THEN USE_THEN "K2" (fun th -> REWRITE_TAC[SYM(MATCH_MP LT_PRE th)])
      THEN DISCH_THEN (fun th -> LABEL_TAC "G19" th THEN MP_TAC th)
      THEN USE_THEN "G15" (SUBST1_TAC o SYM)
      THEN DISCH_THEN (LABEL_TAC "G20")
      THEN SUBGOAL_THEN `!j:num. 0 < j /\ j <= n:num ==> (!i:num. i <= PRE k ==> ~((ploop:num->A) j = shift_path (p:num->A) 1 i))` ASSUME_TAC
      THENL[REWRITE_TAC[shift_path]
	  THEN ONCE_REWRITE_TAC[ADD_SYM]
	  THEN GEN_TAC
	  THEN REPLICATE_TAC 2 STRIP_TAC
	  THEN ASM_CASES_TAC `i:num = PRE k`
	  THENL[POP_ASSUM SUBST1_TAC
              THEN USE_THEN "K2" (fun th -> REWRITE_TAC[SYM(MATCH_MP LT_PRE th); LE_REFL])
	      THEN USE_THEN "G15" (SUBST1_TAC o SYM)
	      THEN USE_THEN "G16" MP_TAC
	      THEN REWRITE_TAC[lemma_def_inj_contour]
	      THEN DISCH_THEN (MP_TAC o SPECL[`j:num`; `0`] o CONJUNCT2)
	      THEN REPLICATE_TAC 2 (POP_ASSUM (fun th -> REWRITE_TAC[th]))
	      THEN MESON_TAC[]; ALL_TAC]
	  THEN POP_ASSUM MP_TAC
	  THEN REWRITE_TAC[IMP_IMP]
	  THEN ONCE_REWRITE_TAC[CONJ_SYM]
	  THEN REWRITE_TAC[GSYM LT_LE]
	  THEN REWRITE_TAC[GSYM ADD1]
	  THEN ONCE_REWRITE_TAC[GSYM LT_SUC]
	  THEN USE_THEN "K2" (fun th -> REWRITE_TAC[SYM(MATCH_MP LT_SUC_PRE th)])
	  THEN DISCH_TAC
	  THEN DISCH_THEN (ASSUME_TAC o SYM)
	  THEN MP_TAC (SPECL[`ploop:num->A`; `n:num`; `(p:num->A) (SUC i)`; `j:num`] lemma_in_path2)
	  THEN POP_ASSUM (fun th -> GEN_REWRITE_TAC (LAND_CONV o LAND_CONV o DEPTH_CONV) [th])
	  THEN USE_THEN "G6" (MP_TAC o SPEC `SUC i`)
	  THEN REPLICATE_TAC 2 (POP_ASSUM (fun th -> REWRITE_TAC[th]))
	  THEN REWRITE_TAC[LT_0]; ALL_TAC]
      THEN REMOVE_THEN "G18" (fun th1 -> (REMOVE_THEN "G16" (fun th2 -> (REMOVE_THEN "G20" (fun th3 -> (POP_ASSUM (fun th4 -> (MP_TAC (MATCH_MP concatenate_two_contours (CONJ th1 (CONJ th2 (CONJ th3 th4))))))))))))
      THEN DISCH_THEN (X_CHOOSE_THEN `g:num->A` (CONJUNCTS_THEN2 (LABEL_TAC "G21") (CONJUNCTS_THEN2 (LABEL_TAC "G22") (CONJUNCTS_THEN2 (LABEL_TAC "G23") (CONJUNCTS_THEN2 (LABEL_TAC "G24") (LABEL_TAC "G25"))))))
      THEN USE_THEN "G24" (MP_TAC o SPEC `PRE k`)
      THEN REWRITE_TAC[LE_REFL; shift_path]
      THEN ONCE_REWRITE_TAC[ADD_SYM]
      THEN USE_THEN "K2" (fun th -> (REWRITE_TAC[SYM(MATCH_MP LT_PRE th)]))
      THEN DISCH_THEN (LABEL_TAC "G26")
      THEN REMOVE_THEN "G4" MP_TAC
      THEN REWRITE_TAC[lemma_in_path]
      THEN DISCH_THEN (X_CHOOSE_THEN `j:num` (CONJUNCTS_THEN2 (LABEL_TAC "G27") (LABEL_TAC "G28")))
      THEN SUBGOAL_THEN `j:num < n:num` (LABEL_TAC "G30")
      THENL[REWRITE_TAC[LT_LE]
	  THEN USE_THEN "G27" (fun th -> REWRITE_TAC[th])
	  THEN USE_THEN "F9" MP_TAC
	  THEN REWRITE_TAC[CONTRAPOS_THM]
	  THEN DISCH_TAC
	  THEN USE_THEN "G28" MP_TAC
	  THEN POP_ASSUM SUBST1_TAC
	  THEN USE_THEN "G17" SUBST1_TAC
	  THEN USE_THEN "G10" SUBST1_TAC
	  THEN REWRITE_TAC[node_map_injective]
	  THEN USE_THEN "F8" (MP_TAC o SPECL[`k:num`; `1`])
	  THEN USE_THEN "F3" (fun th -> REWRITE_TAC[MATCH_MP (ARITH_RULE `2 <=k ==> 1 < k`) th; LE_REFL])
	  THEN MESON_TAC[]; ALL_TAC]
      THEN REMOVE_THEN "G21" MP_TAC
      THEN REWRITE_TAC[shift_path]
      THEN REWRITE_TAC[ADD_0]
      THEN DISCH_THEN (LABEL_TAC "G31")
      THEN REMOVE_THEN "G25" (MP_TAC o SPEC `j:num`)
      THEN USE_THEN "G30" (fun th -> REWRITE_TAC[MATCH_MP LT_IMP_LE th])
      THEN REMOVE_THEN "G28" (SUBST1_TAC o SYM)
      THEN DISCH_THEN (LABEL_TAC "G31")
      THEN EXISTS_TAC `g:num->A`
      THEN EXISTS_TAC `PRE k + (n:num)`
      THEN REWRITE_TAC[is_Moebius_contour]
      THEN USE_THEN "G23" (fun th -> REWRITE_TAC[th])
      THEN EXISTS_TAC `PRE k`
      THEN EXISTS_TAC `PRE k + (j:num)`
      THEN USE_THEN "K1" (fun th -> REWRITE_TAC[th])
      THEN REWRITE_TAC[LE_ADD]
      THEN ONCE_REWRITE_TAC[LT_ADD_LCANCEL]
      THEN USE_THEN "G30" (fun th -> REWRITE_TAC[th])
      THEN REPLICATE_TAC 2 (POP_ASSUM SUBST1_TAC)
      THEN USE_THEN "G10" (fun th -> REWRITE_TAC[th])
      THEN USE_THEN "G26" SUBST1_TAC
      THEN USE_THEN "G22" SUBST1_TAC
      THEN USE_THEN "G17" (fun th -> REWRITE_TAC[th]); ALL_TAC]
   THEN REMOVE_THEN "F4" (LABEL_TAC "TP" o REWRITE_RULE[POWER_1] o SPEC `1` o  MATCH_MP lemma_power_next_in_loop)
   THEN REMOVE_THEN "F1" (fun th->(USE_THEN "TP"(fun th1-> (LABEL_TAC "F1" (MATCH_MP let_order_for_loop (CONJ th th1))))))
   THEN MP_TAC (SPECL[`L:(A)loop`; `next (L:(A)loop) ((p:num->A) 0)`; `top (L:(A)loop)`] contour_of)
   THEN REWRITE_TAC[iterate_map_valuation2; GSYM lemma_size; lemma_order_next; I_THM]
   THEN DISCH_THEN (LABEL_TAC "F4" o SYM)
   THEN REMOVE_THEN "F5" MP_TAC
   THEN USE_THEN "TP" (fun th -> REWRITE_TAC[MATCH_MP lemma_inside th])
   THEN DISCH_THEN (LABEL_TAC "F5")
   THEN REMOVE_THEN "F6" MP_TAC
   THEN REMOVE_THEN "TP" (fun th -> REWRITE_TAC[MATCH_MP lemma_inside th])
   THEN DISCH_THEN (LABEL_TAC "F6")
   THEN ABBREV_TAC `ploop = contour_of (L:(A)loop) (next L ((p:num->A) 0))`
   THEN ABBREV_TAC `n = top (L:(A)loop)`
   THEN REWRITE_TAC[GSYM node_map_inverse_representation]
   THEN DISCH_THEN (LABEL_TAC "G10")
   THEN DISCH_THEN (LABEL_TAC "G12")
   THEN REMOVE_THEN "F7" MP_TAC
   THEN REWRITE_TAC[NOT_FORALL_THM]
   THEN USE_THEN "F1" (CONJUNCTS_THEN2 (LABEL_TAC "G16") (MP_TAC))
   THEN REWRITE_TAC[one_step_contour]
   THEN USE_THEN "F4" (SUBST1_TAC o SYM)
   THEN STRIP_TAC
   THENL[POP_ASSUM MP_TAC
      THEN USE_THEN "G10" (SUBST1_TAC o SYM)
      THEN DISCH_THEN (fun th-> (ASSUME_TAC (MATCH_MP lemma_in_path2 (CONJ (SPEC `n:num` LE_0) (SYM th)))))
      THEN USE_THEN "F6" (MP_TAC o SPEC `1`)
      THEN USE_THEN "F3" (fun th -> REWRITE_TAC[MATCH_MP (ARITH_RULE `2 <= k:num ==> 1 < k`) th])
      THEN REWRITE_TAC[ARITH_RULE `0 < 1`]
      THEN POP_ASSUM (fun th -> REWRITE_TAC[th]); ALL_TAC]
   THEN POP_ASSUM MP_TAC
   THEN REWRITE_TAC[GSYM node_map_inverse_representation]
   THEN DISCH_THEN (LABEL_TAC "G17")
   THEN REMOVE_THEN "F2" (MP_TAC o SPEC `PRE k` o  MATCH_MP lemma_sub_inj_contour)
   THEN USE_THEN "K3" (fun th -> REWRITE_TAC[MATCH_MP LT_IMP_LE th])
   THEN DISCH_THEN (LABEL_TAC "G18")
   THEN SUBGOAL_THEN `!j:num. 0 < j /\ j <= PRE k ==> (!i:num. i <= (n:num) ==> ~((p:num->A) j = (ploop:num->A) i))` ASSUME_TAC
   THENL[REPEAT STRIP_TAC
       THEN MP_TAC (SPECL[`ploop:num->A`; `n:num`; `(p:num->A) (j:num)`; `i:num`] lemma_in_path2)
       THEN REPLICATE_TAC 2 (POP_ASSUM (fun th -> GEN_REWRITE_TAC (LAND_CONV o LAND_CONV o DEPTH_CONV) [th]))
       THEN REWRITE_TAC[]
       THEN USE_THEN "F6" (MP_TAC o SPEC `j:num`)
       THEN POP_ASSUM (fun th -> (USE_THEN "K2" (fun th2 -> REWRITE_TAC[MATCH_MP (ARITH_RULE `0 < k:num /\ j:num <= PRE k ==> j < k`) (CONJ th2 th)])))
       THEN POP_ASSUM (fun th -> REWRITE_TAC[th]); ALL_TAC]
   THEN REMOVE_THEN "G16" (fun th1 -> (REMOVE_THEN "G18" (fun th2 -> (USE_THEN "F4" (fun th3 -> (POP_ASSUM (fun th4 -> (MP_TAC (MATCH_MP concatenate_two_contours (CONJ th1 (CONJ th2 (CONJ (SYM th3) th4))))))))))))
   THEN DISCH_THEN (X_CHOOSE_THEN `g:num->A` (CONJUNCTS_THEN2 (LABEL_TAC "G21") (CONJUNCTS_THEN2 (LABEL_TAC "G22") (CONJUNCTS_THEN2 (LABEL_TAC "G23") (CONJUNCTS_THEN2 (LABEL_TAC "G24") (LABEL_TAC "G25"))))))
   THEN USE_THEN "G24" (MP_TAC o SPEC `n:num`)
   THEN REWRITE_TAC[LE_REFL]
   THEN DISCH_THEN (LABEL_TAC "G26")
   THEN REMOVE_THEN "F5" MP_TAC
   THEN REWRITE_TAC[lemma_in_path]
   THEN DISCH_THEN (X_CHOOSE_THEN `j:num` (CONJUNCTS_THEN2 (LABEL_TAC "G27") (LABEL_TAC "G28")))
   THEN SUBGOAL_THEN `~(j:num = 0)` MP_TAC
   THENL[USE_THEN "F9" MP_TAC
       THEN REWRITE_TAC[CONTRAPOS_THM]
       THEN DISCH_TAC
       THEN USE_THEN "G28" MP_TAC
       THEN POP_ASSUM SUBST1_TAC
       THEN GEN_REWRITE_TAC (LAND_CONV o ONCE_DEPTH_CONV) [GSYM (SPEC `H:(A)hypermap` node_map_injective)]
       THEN USE_THEN "G12" (SUBST1_TAC o SYM)
       THEN USE_THEN "G17" (SUBST1_TAC o SYM)
       THEN USE_THEN "F8" (MP_TAC o SPECL[`PRE k`; `0`])
       THEN USE_THEN "K3" (fun th -> REWRITE_TAC[MATCH_MP LT_IMP_LE th])
       THEN USE_THEN "K1" (fun th -> REWRITE_TAC[th])
       THEN MESON_TAC[]; ALL_TAC]
   THEN REWRITE_TAC[GSYM LT_NZ]
   THEN DISCH_THEN (LABEL_TAC "G29")
   THEN EXISTS_TAC `g:num->A`
   THEN EXISTS_TAC `(n:num) + PRE k`
   THEN REWRITE_TAC[is_Moebius_contour]
   THEN USE_THEN "G23" (fun th -> REWRITE_TAC[th])
   THEN EXISTS_TAC `j:num`
   THEN EXISTS_TAC `n:num`
   THEN USE_THEN "G29" (fun th -> REWRITE_TAC[th])
   THEN USE_THEN "G27" (fun th -> REWRITE_TAC[th])
   THEN ONCE_REWRITE_TAC[LT_ADD]
   THEN USE_THEN "K1" (fun th -> REWRITE_TAC[th])
   THEN USE_THEN "G26" SUBST1_TAC
   THEN USE_THEN "G21" SUBST1_TAC
   THEN USE_THEN "G22" SUBST1_TAC
   THEN USE_THEN "G24" (MP_TAC o SPEC `j:num`)
   THEN USE_THEN "G27" (fun th -> REWRITE_TAC[th])
   THEN DISCH_THEN SUBST1_TAC
   THEN USE_THEN "G28" (SUBST1_TAC o SYM)
   THEN USE_THEN "F4" (SUBST1_TAC o SYM)
   THEN USE_THEN "G12" (fun th -> REWRITE_TAC[th])
   THEN USE_THEN "G17" (fun th -> REWRITE_TAC[th]));;


(* Some facts about face_loop, node_loop and their injective contours *)

let inj_orbit_imp_inj_face_contour = prove(`!(H:(A)hypermap) (x:A) (k:num). inj_orbit (face_map H) x k ==> is_inj_contour H (face_contour H x) k`,
   REPEAT GEN_TAC
   THEN REWRITE_TAC[lemma_def_inj_contour]
   THEN REWRITE_TAC[lemma_face_contour; face_contour]
   THEN REWRITE_TAC[lemma_def_inj_orbit]
   THEN MESON_TAC[]);;

let lemma_inj_face_contour = prove(`!(H:(A)hypermap) x:A k:num. k < CARD(face H x) ==> is_inj_contour H (face_contour H x) k`,
   REWRITE_TAC[face]
   THEN REPEAT STRIP_TAC
   THEN MP_TAC(SPECL[`x:A`; `k:num`](MATCH_MP lemma_segment_orbit (SPEC `H:(A)hypermap` face_map_and_darts)))
   THEN ASM_REWRITE_TAC[inj_orbit_imp_inj_face_contour]);;

let lemma_face_cycle = prove(`!(H:(A)hypermap) (x:A). ((face_map H) POWER (CARD (face H x))) x = x`, 
   REWRITE_TAC[face] THEN MESON_TAC[face_map_and_darts; lemma_cycle_orbit]);;


let lemma_card_inverse_map_eq = prove(`!s:A->bool p:A->A x:A. FINITE s /\ p permutes s ==> orbit_map (inverse p) x = orbit_map p x`,
 REPEAT GEN_TAC
   THEN DISCH_THEN (LABEL_TAC "F1")
   THEN REWRITE_TAC[orbit_map;GE; LE_0; EXTENSION; IN_ELIM_THM]
   THEN GEN_TAC
   THEN EQ_TAC
   THENL[STRIP_TAC
       THEN REMOVE_THEN "F1" (MP_TAC o SPEC `n:num` o MATCH_MP power_inverse_element_lemma)
       THEN DISCH_THEN (X_CHOOSE_THEN `j:num` SUBST_ALL_TAC)
       THEN EXISTS_TAC `j:num`
       THEN ASM_REWRITE_TAC[]; ALL_TAC]
   THEN POP_ASSUM (MP_TAC o MATCH_MP lemma_permutation_via_its_inverse)
   THEN DISCH_THEN (X_CHOOSE_THEN `j:num` MP_TAC)
   THEN DISCH_THEN (fun th -> GEN_REWRITE_TAC (LAND_CONV o ONCE_DEPTH_CONV) [th])
   THEN REWRITE_TAC[GSYM multiplication_exponents]
   THEN MESON_TAC[]);;

let inj_orbit_imp_inj_node_contour = prove(
  `!(H:(A)hypermap) (x:A) (k:num). inj_orbit (inverse (node_map H)) x k ==> is_inj_contour H (node_contour H x) k`,
   REPEAT GEN_TAC
   THEN REWRITE_TAC[lemma_def_inj_contour]
   THEN REWRITE_TAC[lemma_node_contour; node_contour]
   THEN REWRITE_TAC[lemma_def_inj_orbit]
   THEN MESON_TAC[]);;
                                                                  
let lemma_inj_node_contour = prove(`!(H:(A)hypermap) x:A k:num. k < CARD(node H x) ==> is_inj_contour H (node_contour H x) k`,
   REPEAT GEN_TAC
   THEN REWRITE_TAC[node]
   THEN MP_TAC (SPEC `H:(A)hypermap` node_map_and_darts)
   THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F1") (LABEL_TAC "F2"))
   THEN USE_THEN "F2"  (LABEL_TAC "F3" o MATCH_MP PERMUTES_INVERSE)
   THEN USE_THEN "F1" (fun th1-> (USE_THEN "F3" (fun th2 ->(MP_TAC(SPECL[`x:A`; `k:num`](MATCH_MP lemma_segment_orbit (CONJ th1 th2)))))))
   THEN USE_THEN "F1" (fun th1-> (USE_THEN "F2" (fun th2 ->(REWRITE_TAC[SYM((SPEC `x:A` (MATCH_MP lemma_card_inverse_map_eq (CONJ th1 th2))))]))))
   THEN MESON_TAC[inj_orbit_imp_inj_node_contour]);;

let lemma_node_cycle = prove(`!(H:(A)hypermap) (x:A). ((node_map H) POWER (CARD (node H x))) x = x`, 
   REWRITE_TAC[node] THEN MESON_TAC[hypermap_lemma; lemma_cycle_orbit]);;

let lemma_edge_cycle = prove(`!(H:(A)hypermap) (x:A). ((edge_map H) POWER (CARD (edge H x))) x = x`, 
   REWRITE_TAC[edge] THEN MESON_TAC[hypermap_lemma; lemma_cycle_orbit]);;

let lemma_node_inverse_cycle = prove(`!(H:(A)hypermap) (x:A). ((inverse (node_map H)) POWER (CARD (node H x))) x = x`, 
   REPEAT GEN_TAC
   THEN ASSUME_TAC (CONJUNCT2(SPEC `H:(A)hypermap` node_map_and_darts))
   THEN CONV_TAC SYM_CONV
   THEN POP_ASSUM (fun th -> REWRITE_TAC[GSYM(MATCH_MP inverse_power_function th)])
   THEN CONV_TAC SYM_CONV
   THEN REWRITE_TAC[lemma_node_cycle]);;
 
(* Two darts lie in the same node can connect by an injective contour node - a trivial fact - a technical lemma *)

let lemma_node_contour_connection = prove(`!(H:(A)hypermap) (x:A) (y:A). y IN node H x 
   ==> (?k:num. k  < CARD(node H x) /\ node_contour H x 0 = x /\ node_contour H x k = y /\ is_inj_contour H (node_contour H x) k)`,
 REPEAT GEN_TAC
   THEN DISCH_THEN (LABEL_TAC "F1")
   THEN MP_TAC (SPECL[`H:(A)hypermap`; `x:A`] lemma_node_inverse_cycle)
   THEN MP_TAC (SPECL[`H:(A)hypermap`; `x:A`] NODE_NOT_EMPTY)
   THEN REWRITE_TAC[LT1_NZ; LT_NZ; IMP_IMP]
   THEN MP_TAC (SPEC`x:A` (MATCH_MP lemma_card_inverse_map_eq (SPEC `H:(A)hypermap` node_map_and_darts)))
   THEN REWRITE_TAC[GSYM node]
   THEN DISCH_THEN (fun th -> (ASSUME_TAC th THEN GEN_REWRITE_TAC (LAND_CONV o DEPTH_CONV)[SYM th]))
   THEN DISCH_THEN (MP_TAC o MATCH_MP orbit_cyclic)
   THEN POP_ASSUM SUBST1_TAC
   THEN DISCH_TAC
   THEN REMOVE_THEN "F1" MP_TAC
   THEN POP_ASSUM (fun th -> GEN_REWRITE_TAC (LAND_CONV o RAND_CONV) [th])
   THEN REWRITE_TAC[IN_ELIM_THM]
   THEN REWRITE_TAC[GSYM node_contour]
   THEN STRIP_TAC
   THEN EXISTS_TAC `k:num`
   THEN ASM_REWRITE_TAC[]
   THEN FIRST_ASSUM (fun th -> REWRITE_TAC[MATCH_MP lemma_inj_node_contour th])
   THEN REWRITE_TAC[node_contour; POWER_0; I_THM]);;

let lemmaICJHAOQ = prove(`!(H:(A)hypermap) L:(A)loop. is_loop H L /\ (!g:num->A m:num. ~(is_Moebius_contour H g m)) 
==> ~(?p:num->A k:num. 1 <= k /\ is_contour H p k /\ (p 0) inside L /\ (!i:num. 0 < i /\ i <= k ==> ~((p i) inside L)) /\ p 1 = face_map H (p 0) /\ ~(node H (p 0) = node H (p k)) /\ (?y:A. y IN node H (p k) /\ y inside L))`,
  REPEAT GEN_TAC   
   THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F1") MP_TAC)
   THEN ONCE_REWRITE_TAC[GSYM CONTRAPOS_THM]
   THEN REWRITE_TAC[NOT_FORALL_THM]
   THEN DISCH_THEN (X_CHOOSE_THEN `p:num->A` (X_CHOOSE_THEN `k:num` (CONJUNCTS_THEN2 (LABEL_TAC "F2") (CONJUNCTS_THEN2 (LABEL_TAC "F3") (CONJUNCTS_THEN2 (LABEL_TAC "F4") (CONJUNCTS_THEN2 (LABEL_TAC "F5") (CONJUNCTS_THEN2 (LABEL_TAC "F6") (CONJUNCTS_THEN2 (LABEL_TAC "F7") (LABEL_TAC "F8")))))))))
   THEN SUBGOAL_THEN `?s:num. s <= k /\(p:num->A) s IN node (H:(A)hypermap) (p (k:num))` MP_TAC
   THENL[EXISTS_TAC `k:num` THEN REWRITE_TAC[node; orbit_reflect; LE_REFL]; ALL_TAC]
   THEN GEN_REWRITE_TAC (LAND_CONV) [num_WOP]
   THEN DISCH_THEN (X_CHOOSE_THEN `s:num` (CONJUNCTS_THEN2 (CONJUNCTS_THEN2 (LABEL_TAC "F9") (LABEL_TAC "F10")) (LABEL_TAC "F11")))
   THEN REMOVE_THEN "F10" (SUBST_ALL_TAC o MATCH_MP lemma_node_identity)
   THEN SUBGOAL_THEN `~((p:num->A) 0 = p (s:num))` (LABEL_TAC "F12")
   THENL[USE_THEN "F7" MP_TAC
       THEN REWRITE_TAC[CONTRAPOS_THM]
       THEN MESON_TAC[lemma_node_identity]; ALL_TAC]
   THEN SUBGOAL_THEN `0 < s:num` (LABEL_TAC "F14")
   THENL[ASM_CASES_TAC `s:num = 0`
       THENL[USE_THEN "F12" MP_TAC
	   THEN POP_ASSUM SUBST1_TAC
	   THEN MESON_TAC[]; ALL_TAC]
       THEN REWRITE_TAC[LT_NZ]
       THEN POP_ASSUM (fun th -> REWRITE_TAC[th]); ALL_TAC]
   THEN REMOVE_THEN "F3" (MP_TAC o SPEC `s:num` o MATCH_MP lemma_subcontour)
   THEN USE_THEN "F9" (fun th -> REWRITE_TAC[th])
   THEN DISCH_THEN (LABEL_TAC "F16")
   THEN USE_THEN "F5" (MP_TAC o SPEC `s:num`)
   THEN USE_THEN "F14" (fun th -> REWRITE_TAC[th])
   THEN USE_THEN "F9" (fun th -> REWRITE_TAC[th])
   THEN DISCH_THEN (LABEL_TAC "F17")
   THEN SUBGOAL_THEN `?u:num. u < CARD(node (H:(A)hypermap) ((p:num->A) (s:num))) /\ (node_contour H (p s) u) inside (L:(A)loop)` MP_TAC
   THENL[USE_THEN "F8" (X_CHOOSE_THEN `y:A` (CONJUNCTS_THEN2 (MP_TAC o MATCH_MP lemma_node_contour_connection) ASSUME_TAC))
       THEN DISCH_THEN (X_CHOOSE_THEN `u:num` (CONJUNCTS_THEN2 (ASSUME_TAC) (ASSUME_TAC o CONJUNCT1 o CONJUNCT2)))
       THEN EXISTS_TAC `u:num`
       THEN POP_ASSUM SUBST1_TAC
       THEN REPLICATE_TAC 2 (POP_ASSUM (fun th -> (REWRITE_TAC[th]))); ALL_TAC]
   THEN GEN_REWRITE_TAC (LAND_CONV) [num_WOP]
   THEN DISCH_THEN (X_CHOOSE_THEN `t:num` (CONJUNCTS_THEN2 (CONJUNCTS_THEN2 (LABEL_TAC "F18") (LABEL_TAC "F19")) (LABEL_TAC "F20")))
   THEN SUBGOAL_THEN `0 < t:num` (LABEL_TAC "F21")
   THENL[ASM_CASES_TAC `t:num = 0`
       THENL[USE_THEN "F19" MP_TAC
	   THEN POP_ASSUM SUBST1_TAC
	   THEN REWRITE_TAC[node_contour; POWER_0; I_THM]
	   THEN USE_THEN "F17" (fun th -> REWRITE_TAC[th]); ALL_TAC]
       THEN REWRITE_TAC[LT_NZ]
       THEN POP_ASSUM (fun th -> REWRITE_TAC[th]); ALL_TAC]
   THEN USE_THEN "F16" (MP_TAC o MATCH_MP lemma4dot11)
   THEN DISCH_THEN (X_CHOOSE_THEN `w:num->A` (X_CHOOSE_THEN `d:num` (CONJUNCTS_THEN2 (LABEL_TAC "FC") (CONJUNCTS_THEN2 (LABEL_TAC "F22") (CONJUNCTS_THEN2 (LABEL_TAC "F23") (CONJUNCTS_THEN2 (LABEL_TAC "F24") (LABEL_TAC "F25")))))))
   THEN SUBGOAL_THEN `0 < d:num` (LABEL_TAC "F26")
   THENL[ASM_CASES_TAC `d:num = 0`
       THENL[USE_THEN "F23" MP_TAC
           THEN POP_ASSUM SUBST1_TAC
           THEN USE_THEN "F22" SUBST1_TAC
           THEN USE_THEN "F12" (fun th -> REWRITE_TAC[th]); ALL_TAC]
       THEN REWRITE_TAC[LT_NZ]
       THEN POP_ASSUM (fun th -> REWRITE_TAC[th]); ALL_TAC]
   THEN REMOVE_THEN "F22" (SUBST_ALL_TAC o SYM)
   THEN REMOVE_THEN "F23" (SUBST_ALL_TAC o SYM)
   THEN SUBGOAL_THEN `!i:num. 0 < i /\ i <= d:num ==> ~(((w:num->A) i) inside (L:(A)loop) )` (LABEL_TAC "F27")
   THENL[REPEAT GEN_TAC
       THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "G4") MP_TAC)
       THEN REWRITE_TAC[LE_LT]
       THEN STRIP_TAC
       THENL[POP_ASSUM (LABEL_TAC "G5")
	   THEN USE_THEN "F25" (MP_TAC o SPEC `i:num`)
	   THEN USE_THEN "G5" (fun th -> REWRITE_TAC[th])
	   THEN DISCH_THEN (X_CHOOSE_THEN `j:num` (CONJUNCTS_THEN2 (LABEL_TAC "G6") (CONJUNCTS_THEN2 (LABEL_TAC "G7") (SUBST1_TAC o CONJUNCT1))))
	   THEN USE_THEN "G4" (fun th1 -> (USE_THEN "G6" (fun th2 -> (ASSUME_TAC (MATCH_MP LTE_TRANS (CONJ th1 th2))))))
	   THEN USE_THEN "G7" (fun th1 -> (USE_THEN "F9" (fun th2 -> (ASSUME_TAC (MATCH_MP LTE_TRANS (CONJ th1 th2))))))
	   THEN USE_THEN "F5" (MP_TAC o SPEC `j:num`)
	   THEN POP_ASSUM (fun th -> REWRITE_TAC[MATCH_MP LT_IMP_LE th])
	   THEN POP_ASSUM (fun th -> REWRITE_TAC[th]); ALL_TAC]
       THEN POP_ASSUM SUBST1_TAC
       THEN USE_THEN "F17" (fun th -> REWRITE_TAC[th]); ALL_TAC]
   THEN SUBGOAL_THEN `(w:num->A) 1 = face_map (H:(A)hypermap) (w 0)` (LABEL_TAC "F28")
   THENL[USE_THEN "F4" (LABEL_TAC "G7" o REWRITE_RULE[POWER_1] o SPEC `1` o  MATCH_MP lemma_power_next_in_loop)
       THEN USE_THEN "F1"(MP_TAC o SPEC `(w:num->A) 0` o REWRITE_RULE[is_loop])
       THEN USE_THEN "F4" (fun th-> REWRITE_TAC[th])
       THEN REWRITE_TAC[one_step_contour]
       THEN STRIP_TAC
       THENL[REMOVE_THEN "G7" MP_TAC
	   THEN POP_ASSUM SUBST1_TAC
	   THEN USE_THEN "F6" (fun th -> GEN_REWRITE_TAC (LAND_CONV o ONCE_DEPTH_CONV) [GSYM th])
	   THEN USE_THEN "F5" (MP_TAC o SPEC `1`)
	   THEN USE_THEN "F2" (fun th-> REWRITE_TAC[th; ARITH_RULE `0 < 1`])
	   THEN MESON_TAC[]; ALL_TAC]
       THEN USE_THEN "F24" (MP_TAC o SPEC `0` o  REWRITE_RULE[lemma_def_contour] o CONJUNCT1 o REWRITE_RULE[lemma_def_inj_contour])
       THEN USE_THEN "F26" (fun th-> REWRITE_TAC[th; one_step_contour; GSYM ONE])
       THEN STRIP_TAC
       THEN POP_ASSUM MP_TAC
       THEN POP_ASSUM (SUBST1_TAC o SYM)
       THEN DISCH_TAC
       THEN REMOVE_THEN "G7" MP_TAC
       THEN POP_ASSUM (SUBST1_TAC o SYM)
       THEN POP_ASSUM (MP_TAC o SPEC `1`)
       THEN POP_ASSUM (ASSUME_TAC o REWRITE_RULE[GSYM LT1_NZ])
       THEN POP_ASSUM (fun th-> REWRITE_TAC[ th; ARITH_RULE `0 < 1`])
       THEN MESON_TAC[]; ALL_TAC]
   THEN USE_THEN "F18" (LABEL_TAC "F29" o MATCH_MP lemma_inj_node_contour)
   THEN MP_TAC(SPECL[`H:(A)hypermap`; `(w:num->A) (d:num)`; `0`] node_contour)
   THEN REWRITE_TAC[POWER_0; I_THM]
   THEN DISCH_THEN (LABEL_TAC "F30")
   THEN SUBGOAL_THEN `!j:num. 0 < j /\ j <= t:num ==> (!i:num. i <= d ==> ~(node_contour (H:(A)hypermap) ((w:num->A) (d:num)) j = w i))` ASSUME_TAC
   THENL[GEN_TAC
      THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "G20") (LABEL_TAC "G21"))
      THEN GEN_TAC
      THEN DISCH_THEN (LABEL_TAC "G22")
      THEN ASM_CASES_TAC `i:num = d:num`
      THENL[POP_ASSUM SUBST1_TAC
	 THEN USE_THEN "F30" (fun th -> GEN_REWRITE_TAC (RAND_CONV o RAND_CONV) [SYM th])
	 THEN (USE_THEN "F29" (MP_TAC o SPECL[`j:num`; `0`] o CONJUNCT2 o  REWRITE_RULE[lemma_def_inj_contour; lemma_def_contour]))
	 THEN USE_THEN "G20" (fun th -> REWRITE_TAC[th])
	 THEN USE_THEN "G21" (fun th -> REWRITE_TAC[th])
	 THEN MESON_TAC[]; ALL_TAC]
      THEN REPLICATE_TAC 2 (POP_ASSUM MP_TAC)
      THEN REWRITE_TAC[IMP_IMP; GSYM LT_LE]
      THEN DISCH_THEN (LABEL_TAC "G25")
      THEN REWRITE_TAC[node_contour]
      THEN MP_TAC (SPEC `j:num` (MATCH_MP power_inverse_element_lemma (SPEC `H:(A)hypermap` node_map_and_darts)))
      THEN DISCH_THEN (X_CHOOSE_THEN `v:num` SUBST1_TAC)
      THEN REWRITE_TAC[GSYM node]
      THEN DISCH_THEN (fun th -> (MP_TAC (MATCH_MP in_orbit_lemma (SYM th))))
      THEN USE_THEN "G25" (fun th -> REWRITE_TAC[th])
      THEN USE_THEN "F25" (MP_TAC o SPEC `i:num`)
      THEN USE_THEN "G25" (fun th -> REWRITE_TAC[th])
      THEN DISCH_THEN (X_CHOOSE_THEN `u:num` (fun th -> (LABEL_TAC "G26" (CONJUNCT1(CONJUNCT2 th)) THEN LABEL_TAC "G27" (CONJUNCT1(CONJUNCT2(CONJUNCT2 th))))))
      THEN USE_THEN "F11" (MP_TAC o SPEC `u:num`)
      THEN USE_THEN "G26" (fun th-> REWRITE_TAC[th])
      THEN REWRITE_TAC[CONTRAPOS_THM]
      THEN USE_THEN "F9" (fun th -> (USE_THEN "G26" (fun th1 -> MP_TAC(MATCH_MP LTE_TRANS (CONJ th1 th)))))
      THEN DISCH_THEN (fun th -> REWRITE_TAC[MATCH_MP LT_IMP_LE th])
      THEN REWRITE_TAC[GSYM node]     
      THEN POP_ASSUM (fun th -> REWRITE_TAC[th]); ALL_TAC]
   THEN USE_THEN "F24" (fun th1 -> (USE_THEN "F29" (fun th2 -> (USE_THEN "F30" (fun th3 -> (POP_ASSUM (fun th4 ->MP_TAC (MATCH_MP concatenate_two_contours (CONJ th1 (CONJ th2 (CONJ (SYM th3) th4)))))))))))
   THEN DISCH_THEN (X_CHOOSE_THEN `g:num->A` (CONJUNCTS_THEN2 (LABEL_TAC "M1") (CONJUNCTS_THEN2 (LABEL_TAC "M2") (CONJUNCTS_THEN2 (LABEL_TAC "M3") (CONJUNCTS_THEN2 (LABEL_TAC "M4") (LABEL_TAC "M5"))))))
   THEN SUBGOAL_THEN `!i:num. 0 < i /\ i < (d:num) + (t:num) ==> ~((g:num->A) i inside (L:(A)loop))` (LABEL_TAC "M6")
   THENL[GEN_TAC
       THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "G30") (LABEL_TAC "G31"))
       THEN ASM_CASES_TAC `i:num <= d:num`
       THENL[POP_ASSUM (LABEL_TAC "G32")
	  THEN USE_THEN "M4" (MP_TAC o SPEC `i:num`)
	  THEN USE_THEN "G32" (fun th -> REWRITE_TAC[th])
	  THEN DISCH_THEN SUBST1_TAC
	  THEN USE_THEN "F27" (MP_TAC o SPEC `i:num`)
	  THEN USE_THEN "G30" (fun th -> REWRITE_TAC[th])
	  THEN USE_THEN "G32" (fun th -> REWRITE_TAC[th]); ALL_TAC]
       THEN POP_ASSUM (MP_TAC o REWRITE_RULE[NOT_LE])
       THEN REWRITE_TAC[LT_EXISTS]
       THEN DISCH_THEN (X_CHOOSE_THEN `l:num` ASSUME_TAC)
       THEN USE_THEN "G31" MP_TAC
       THEN POP_ASSUM (SUBST1_TAC)
       THEN REWRITE_TAC[LT_ADD_LCANCEL]
       THEN DISCH_THEN (LABEL_TAC "G34")
       THEN USE_THEN "M5" (MP_TAC o SPEC `SUC l`)
       THEN USE_THEN "G34" (fun th-> (REWRITE_TAC[MATCH_MP LT_IMP_LE th]))
       THEN DISCH_THEN SUBST1_TAC
       THEN USE_THEN "F20" (MP_TAC o SPEC `SUC l`)
       THEN USE_THEN "G34" (fun th -> REWRITE_TAC[th; CONTRAPOS_THM])
       THEN DISCH_THEN(fun th -> SIMP_TAC[th])
       THEN USE_THEN "G34" (fun th1 -> (USE_THEN "F18" (fun th -> REWRITE_TAC[MATCH_MP LT_TRANS (CONJ th1 th)]))); ALL_TAC]
   THEN REMOVE_THEN "F19" (MP_TAC)
   THEN USE_THEN "M2" (SUBST1_TAC o SYM)
   THEN DISCH_THEN (LABEL_TAC "F19")
   THEN REMOVE_THEN "M1" (SUBST_ALL_TAC o SYM)
   THEN REMOVE_THEN "F28" MP_TAC
   THEN USE_THEN "M4" (MP_TAC o SPEC `1`)
   THEN USE_THEN "F26" (MP_TAC o REWRITE_RULE[GSYM LT1_NZ])
   THEN DISCH_THEN(fun th -> REWRITE_TAC[th])
   THEN DISCH_THEN (SUBST1_TAC o SYM)
   THEN DISCH_THEN (LABEL_TAC "F28")
   THEN USE_THEN "M5" (MP_TAC o SPEC `PRE t`)
   THEN REWRITE_TAC[ARITH_RULE `PRE (t:num) <= t`]
   THEN REWRITE_TAC[node_contour]
   THEN DISCH_TAC
   THEN REMOVE_THEN "M2"  MP_TAC
   THEN REWRITE_TAC[node_contour]
   THEN USE_THEN "F21" (fun th -> (GEN_REWRITE_TAC (LAND_CONV o RAND_CONV o ONCE_DEPTH_CONV) [MATCH_MP LT_SUC_PRE th]))
   THEN REWRITE_TAC[COM_POWER; o_THM]
   THEN POP_ASSUM (SUBST1_TAC o SYM)
   THEN REWRITE_TAC[GSYM node_contour]
   THEN USE_THEN "F21" (fun th -> REWRITE_TAC[MATCH_MP (ARITH_RULE `0 < t:num ==> (d:num) + (PRE t) = PRE(d + t)`) th])
   THEN DISCH_THEN (LABEL_TAC "M2")
   THEN USE_THEN "F26"(fun th1 ->(USE_THEN "F21" (fun th2 -> (LABEL_TAC "F29" (MATCH_MP (ARITH_RULE `0 < d:num /\ 0 < t:num ==> 2 <= d + t`) (CONJ th1 th2))))))
   THEN ABBREV_TAC `m = (d:num) + (t:num)`
   THEN ONCE_REWRITE_TAC[TAUT `p <=> (~p ==> F)`]
   THEN DISCH_THEN ASSUME_TAC
   THEN MP_TAC(SPECL[`H:(A)hypermap`; `L:(A)loop`; `g:num->A`;`m:num`] lemmaILTXRQD)
   THEN ASM_REWRITE_TAC[]
   THEN USE_THEN "M2" (fun th -> REWRITE_TAC[SYM th])
   THEN USE_THEN "F19" (fun th -> REWRITE_TAC[th])
   THEN REWRITE_TAC[GSYM NOT_EXISTS_THM]
   THEN POP_ASSUM(fun th -> MESON_TAC[th]));;


let lemma4dot17 = prove(`!(H:(A)hypermap) (L:(A)loop). is_loop H L /\ (!x:A. x IN dart H ==> 3 <= CARD (face H x)) /\ (?x:A y:A. ~(node H x = node H y) /\ x inside L /\ y inside L) ==> 3 <= size L`,
 REPEAT GEN_TAC
   THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F1") (CONJUNCTS_THEN2 (LABEL_TAC "F2") (X_CHOOSE_THEN `x:A` (X_CHOOSE_THEN `y:A` (CONJUNCTS_THEN2 (LABEL_TAC "F3") (CONJUNCTS_THEN2 (LABEL_TAC "F4") (LABEL_TAC "F5")))))))
   THEN USE_THEN "F4" (MP_TAC o REWRITE_RULE[lemma_in_path])
   THEN STRIP_TAC
   THEN REWRITE_TAC[THREE; lemma_size; LE_SUC]
   THEN USE_THEN "F1" (fun th-> (USE_THEN "F4" (fun th1 -> MP_TAC (MATCH_MP let_order_for_loop (CONJ th th1)))))
   THEN REWRITE_TAC[POWER_0; I_THM]
   THEN MP_TAC (SPECL[`L:(A)loop`; `x:A`; `0`]  contour_of)
   THEN REWRITE_TAC[POWER_0; I_THM]
   THEN DISCH_THEN (fun th -> (LABEL_TAC "F6" th THEN SUBST1_TAC th))
   THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "H1") (LABEL_TAC "H2"))
   THEN REMOVE_THEN "F5" MP_TAC
   THEN USE_THEN "F4"(fun th -> REWRITE_TAC[MATCH_MP lemma_inside th])
   THEN DISCH_THEN (LABEL_TAC "F5")
   THEN USE_THEN "F4" MP_TAC
   THEN REMOVE_THEN "F4"(fun th -> REWRITE_TAC[MATCH_MP lemma_inside th])
   THEN DISCH_THEN (LABEL_TAC "F4")
   THEN ABBREV_TAC `ploop = contour_of (L:(A)loop) (x:A)`
   THEN ABBREV_TAC `n = top (L:(A)loop)`
   THEN SUBGOAL_THEN `~(x:A = y:A)` (LABEL_TAC "F7") 
   THENL[FIRST_X_ASSUM (MP_TAC o check (is_neg o concl)) THEN MESON_TAC[]; ALL_TAC]
   THEN MP_TAC(SPECL[`set_dart_of (ploop:num->A) (n:num)`; `x:A`; `y:A`] CARD_ATLEAST_2)
   THEN REWRITE_TAC[GSYM in_path]
   THEN ASM_REWRITE_TAC[lemma_path_finite]
   THEN USE_THEN "H1" (fun th -> (MP_TAC (MATCH_MP lemma_number_darts_of_inj_contour th) THEN ASSUME_TAC th))
   THEN DISCH_THEN SUBST1_TAC
   THEN GEN_REWRITE_TAC (LAND_CONV o DEPTH_CONV) [TWO; LE_SUC; LE_LT]
   THEN STRIP_TAC THENL[POP_ASSUM MP_TAC THEN ARITH_TAC; ALL_TAC]
   THEN POP_ASSUM (SUBST_ALL_TAC o SYM)
   THEN USE_THEN "F5" (MP_TAC o REWRITE_RULE[lemma_in_path])
   THEN DISCH_THEN (X_CHOOSE_THEN `m:num` (CONJUNCTS_THEN2 MP_TAC ASSUME_TAC))
   THEN REWRITE_TAC[ARITH_RULE `m:num <= 1 <=> m = 0 \/ m = 1`]
   THEN STRIP_TAC
   THENL[POP_ASSUM SUBST_ALL_TAC
      THEN FIRST_X_ASSUM (MP_TAC o check (is_neg o concl))
      THEN ASM_REWRITE_TAC[]; ALL_TAC]
   THEN POP_ASSUM SUBST_ALL_TAC
   THEN POP_ASSUM SUBST_ALL_TAC
   THEN REMOVE_THEN "F6" (SUBST_ALL_TAC o SYM)
   THEN USE_THEN "H2" (MP_TAC o REWRITE_RULE[one_step_contour])
   THEN ONCE_REWRITE_TAC[DISJ_SYM]
   THEN STRIP_TAC
   THENL[POP_ASSUM (MP_TAC o ONCE_REWRITE_RULE[GSYM node_map_inverse_representation])
      THEN DISCH_TAC
      THEN MP_TAC (SPECL[`node_map (H:(A)hypermap)`; `(ploop:num->A) 0`] in_orbit_map1)
      THEN POP_ASSUM (fun th -> REWRITE_TAC[GSYM node; SYM th])
      THEN DISCH_THEN (MP_TAC o MATCH_MP lemma_node_identity)
      THEN USE_THEN "F3" (fun th -> REWRITE_TAC[th]); ALL_TAC]
  THEN POP_ASSUM (LABEL_TAC "F8")  
   THEN USE_THEN "H1" (MP_TAC o SPEC `0` o  CONJUNCT1 o  REWRITE_RULE[lemma_def_inj_contour; lemma_def_contour])
   THEN REWRITE_TAC[ZR_LT_1; GSYM ONE; one_step_contour]
   THEN ONCE_REWRITE_TAC[DISJ_SYM]
   THEN STRIP_TAC
   THENL[POP_ASSUM (MP_TAC o ONCE_REWRITE_RULE[GSYM node_map_inverse_representation])
      THEN DISCH_TAC
      THEN  MP_TAC (SPECL[`node_map (H:(A)hypermap)`; `(ploop:num->A) 1`] in_orbit_map1)
      THEN POP_ASSUM (fun th -> REWRITE_TAC[GSYM node; SYM th])
      THEN DISCH_THEN (MP_TAC o SYM o MATCH_MP lemma_node_identity)
      THEN USE_THEN "F3" (fun th -> REWRITE_TAC[th]); ALL_TAC]
   THEN REMOVE_THEN  "F8" (MP_TAC o SYM)
   THEN POP_ASSUM SUBST1_TAC 
    THEN GEN_REWRITE_TAC (LAND_CONV o LAND_CONV o ONCE_DEPTH_CONV) [GSYM o_THM]
   THEN REWRITE_TAC[GSYM POWER_2]
   THEN MP_TAC (ARITH_RULE `~(2 = 0)`)
   THEN REWRITE_TAC[IMP_IMP]
   THEN DISCH_THEN (ASSUME_TAC o REWRITE_RULE[GSYM face] o  MATCH_MP card_orbit_le)
   THEN UNDISCH_TAC `is_inj_contour (H:(A)hypermap) (ploop:num->A) 1`
   THEN DISCH_THEN ( fun th -> (ASSUME_TAC (MATCH_MP lemma_first_dart_on_inj_contour (CONJ ZR_LT_1 th))))
   THEN USE_THEN "F2" (MP_TAC o SPEC `(ploop:num->A) 0`)
   THEN POP_ASSUM (fun th -> REWRITE_TAC[th])
   THEN POP_ASSUM MP_TAC
   THEN ARITH_TAC);;


(************ GENERATION PART *****************)


let is_node_going = new_definition `!(H:(A)hypermap) (L:(A)loop) x:A y:A. is_node_going H L x y 
    <=> ?k:num. y = ((next L) POWER k) x /\ (!i:num. i <= k ==> ((next L) POWER i) x = ((inverse (node_map H)) POWER i) x)`;;

let atom = new_definition `!(H:(A)hypermap) (L:(A)loop) x:A. atom H L x = {y:A | is_node_going H L x y \/ is_node_going H L y x}`;;

(* Intuitively, a loop is partitioned by atoms *)

let atom_reflect = prove(`!(H:(A)hypermap) (L:(A)loop) (x:A). x IN atom H L x`,
  REPEAT GEN_TAC
  THEN REWRITE_TAC[atom; IN_ELIM_THM; is_node_going]
  THEN EXISTS_TAC `0`
  THEN REWRITE_TAC[LE_0; LE; POWER_0; I_THM]
  THEN GEN_TAC
  THEN DISCH_THEN SUBST1_TAC
  THEN REWRITE_TAC[POWER_0; I_THM]);;

let atom_sym = prove(`!(H:(A)hypermap) (L:(A)loop) (x:A) (y:A). y IN atom H L x ==> x IN atom H L y`,
   REWRITE_TAC[atom; IN_ELIM_THM]
   THEN MESON_TAC[]);;

let lemma_transitive_going = prove(`!(H:(A)hypermap) (L: (A)loop) (x:A) (y:A) (z:A). is_node_going H L x y /\ is_node_going H L y z ==> is_node_going H L x z`,  
   REPEAT GEN_TAC
   THEN REWRITE_TAC[is_node_going]
   THEN DISCH_THEN (CONJUNCTS_THEN2 (X_CHOOSE_THEN `m:num` (CONJUNCTS_THEN2 (LABEL_TAC "F1") (LABEL_TAC "F2")))
(X_CHOOSE_THEN `k:num` (CONJUNCTS_THEN2 (LABEL_TAC "F3") (LABEL_TAC "F4"))))
   THEN EXISTS_TAC `(k:num) + (m:num)`
   THEN REWRITE_TAC[addition_exponents; o_THM]
   THEN USE_THEN "F1" (SUBST1_TAC o SYM)
   THEN USE_THEN "F3" (fun th -> REWRITE_TAC[th])
   THEN GEN_TAC
   THEN DISCH_THEN (LABEL_TAC "F5")
   THEN ASM_CASES_TAC `i:num <= m:num`
   THENL[POP_ASSUM (fun th -> (USE_THEN "F2" (fun thm-> REWRITE_TAC[MATCH_MP (SPEC `i:num` thm) th]))); ALL_TAC]
   THEN POP_ASSUM (MP_TAC o REWRITE_RULE[NOT_LE; LT_EXISTS])
   THEN DISCH_THEN (X_CHOOSE_THEN `d:num` MP_TAC)
   THEN ABBREV_TAC `j = SUC d`
   THEN DISCH_THEN SUBST_ALL_TAC
   THEN ONCE_REWRITE_TAC[ADD_SYM]
   THEN REWRITE_TAC[addition_exponents; o_THM]
   THEN REMOVE_THEN "F2" (MP_TAC o REWRITE_RULE[LE_REFL] o SPEC `m:num`)
   THEN REMOVE_THEN "F1" (SUBST1_TAC o SYM)
   THEN DISCH_THEN (SUBST1_TAC o SYM)
   THEN REMOVE_THEN "F5" MP_TAC
   THEN GEN_REWRITE_TAC (LAND_CONV o RAND_CONV o ONCE_DEPTH_CONV) [ADD_SYM]
   THEN REWRITE_TAC[LE_ADD_LCANCEL]
   THEN DISCH_THEN (fun th -> (REMOVE_THEN "F4" (fun thm -> REWRITE_TAC[MATCH_MP (SPEC `j:num` thm) th]))));;

let lemma_on_way_going = prove(`!(H:(A)hypermap) (L:(A)loop) (x:A) (y:A) (z:A). is_node_going H L x y /\ is_node_going H L x z ==> is_node_going H L y z \/ is_node_going H L z y `,
   REPEAT GEN_TAC
   THEN REWRITE_TAC[is_node_going]
   THEN DISCH_THEN (CONJUNCTS_THEN2 (X_CHOOSE_THEN `m:num` (CONJUNCTS_THEN2 (LABEL_TAC "F1") (LABEL_TAC "F2"))) (X_CHOOSE_THEN `k:num` (CONJUNCTS_THEN2 (LABEL_TAC "F3") (LABEL_TAC "F4"))))
   THEN ASM_CASES_TAC `m:num <= k:num`
   THENL[DISJ1_TAC
      THEN POP_ASSUM (MP_TAC o REWRITE_RULE[LE_EXISTS])
      THEN DISCH_THEN (X_CHOOSE_THEN `d:num` SUBST_ALL_TAC)
      THEN EXISTS_TAC `d:num`
      THEN USE_THEN "F3" (MP_TAC o ONCE_REWRITE_RULE[ADD_SYM])
      THEN REWRITE_TAC[addition_exponents; o_THM]
      THEN USE_THEN "F1" (SUBST1_TAC o SYM)
      THEN DISCH_THEN (fun th -> REWRITE_TAC[th])
      THEN GEN_TAC
      THEN DISCH_THEN (LABEL_TAC "F5")
      THEN USE_THEN "F4" (MP_TAC o SPEC `(m:num) + (i:num)`)
      THEN REWRITE_TAC[LE_ADD_LCANCEL]
      THEN USE_THEN "F5" (fun th -> REWRITE_TAC[th])
      THEN ONCE_REWRITE_TAC[ADD_SYM]
      THEN REWRITE_TAC[addition_exponents; o_THM]
      THEN USE_THEN "F2" (MP_TAC o REWRITE_RULE[LE_REFL] o SPEC `m:num`)
      THEN REMOVE_THEN "F1" (SUBST1_TAC o SYM)
      THEN DISCH_THEN (SUBST1_TAC o SYM)
      THEN SIMP_TAC[]; ALL_TAC]
   THEN DISJ2_TAC
   THEN POP_ASSUM (MP_TAC o REWRITE_RULE[NOT_LE; LT_EXISTS])
   THEN DISCH_THEN (X_CHOOSE_THEN `d1:num` SUBST_ALL_TAC)
   THEN ABBREV_TAC `d = SUC d1`
   THEN EXISTS_TAC `d:num`
   THEN USE_THEN "F1" (MP_TAC o ONCE_REWRITE_RULE[ADD_SYM])
   THEN REWRITE_TAC[addition_exponents; o_THM]
   THEN USE_THEN "F3" (SUBST1_TAC o SYM)
   THEN DISCH_THEN (fun th -> REWRITE_TAC[th])
   THEN GEN_TAC
   THEN DISCH_THEN (LABEL_TAC "F5")
   THEN USE_THEN "F2" (MP_TAC o SPEC `(k:num) + (i:num)`)
   THEN REWRITE_TAC[LE_ADD_LCANCEL]
   THEN USE_THEN "F5" (fun th -> REWRITE_TAC[th])
   THEN ONCE_REWRITE_TAC[ADD_SYM]
   THEN REWRITE_TAC[addition_exponents; o_THM]
   THEN USE_THEN "F4" (MP_TAC o REWRITE_RULE[LE_REFL] o SPEC `k:num`)
   THEN REMOVE_THEN "F3" (SUBST1_TAC o SYM)
   THEN DISCH_THEN (SUBST1_TAC o SYM)
   THEN SIMP_TAC[]);;

let lemma_second_on_way_going = prove(`!(H:(A)hypermap) (L:(A)loop) (x:A) (y:A) (z:A). is_node_going H L x z  /\ is_node_going H L y z ==> is_node_going H L x y \/ is_node_going H L y x`,
   REPEAT GEN_TAC
   THEN DISCH_THEN (MP_TAC o REWRITE_RULE[is_node_going])
   THEN DISCH_THEN (CONJUNCTS_THEN2 (X_CHOOSE_THEN `m:num` (CONJUNCTS_THEN2 (LABEL_TAC "F3") (LABEL_TAC "F4"))) (X_CHOOSE_THEN `k:num`(CONJUNCTS_THEN2 (LABEL_TAC "F5") (LABEL_TAC "F6"))))
   THEN ASM_CASES_TAC `m:num <= k:num`
   THENL[DISJ2_TAC
      THEN POP_ASSUM (MP_TAC o REWRITE_RULE[LE_EXISTS])
      THEN DISCH_THEN (X_CHOOSE_THEN `d:num` SUBST_ALL_TAC)
      THEN REWRITE_TAC[is_node_going]
      THEN EXISTS_TAC `d:num`
      THEN USE_THEN "F3" (MP_TAC o SYM)
      THEN USE_THEN "F5" (SUBST1_TAC)
      THEN REWRITE_TAC[addition_exponents; o_THM]
      THEN DISCH_THEN (MP_TAC o REWRITE_RULE[o_THM; I_THM] o AP_TERM `(back (L:(A)loop)) POWER (m:num)`)
      THEN REWRITE_TAC[lemma_second_inverse_evaluation]
      THEN DISCH_THEN (fun th -> REWRITE_TAC[th])
      THEN GEN_TAC
      THEN DISCH_THEN (LABEL_TAC "F9")
      THEN USE_THEN "F6" (MP_TAC o SPEC `i:num`)
      THEN POP_ASSUM (fun th -> REWRITE_TAC[MATCH_MP (ARITH_RULE `i:num <= d:num ==> i <= (m:num) + d`) th]); ALL_TAC]
   THEN POP_ASSUM (MP_TAC o REWRITE_RULE[NOT_LE; LT_EXISTS])
   THEN DISCH_THEN (X_CHOOSE_THEN `d1:num` (SUBST_ALL_TAC))
   THEN ABBREV_TAC `d = SUC d1`
   THEN DISJ1_TAC
   THEN REWRITE_TAC[is_node_going]
   THEN EXISTS_TAC `d:num`
   THEN USE_THEN "F3" (MP_TAC o SYM)
   THEN USE_THEN "F5" (SUBST1_TAC)
   THEN REWRITE_TAC[addition_exponents; o_THM]
   THEN DISCH_THEN (MP_TAC o REWRITE_RULE[o_THM; I_THM] o AP_TERM `(back (L:(A)loop)) POWER (k:num)`)
   THEN REWRITE_TAC[lemma_second_inverse_evaluation]
   THEN DISCH_THEN (fun th -> REWRITE_TAC[SYM th])
   THEN GEN_TAC
   THEN DISCH_THEN (LABEL_TAC "F9")
   THEN USE_THEN "F4" (MP_TAC o SPEC `i:num`)
   THEN POP_ASSUM (fun th -> REWRITE_TAC[MATCH_MP (ARITH_RULE `i:num <= d:num ==> i <= (k:num) + d`) th]));;

let atom_trans = prove(`!(H:(A)hypermap) (L:(A)loop) (x:A) (y:A) (z:A). x IN atom H L y /\ y IN atom H L z ==> x IN atom H L z`,
   REPEAT GEN_TAC
   THEN REWRITE_TAC[atom; IN_ELIM_THM]
   THEN STRIP_TAC
   THENL[POP_ASSUM (fun th1 -> (POP_ASSUM (fun th2 -> REWRITE_TAC[MATCH_MP lemma_transitive_going (CONJ th1 th2)])));
      POP_ASSUM (fun th1 -> (POP_ASSUM (fun th2 -> REWRITE_TAC[MATCH_MP lemma_on_way_going (CONJ th1 th2)])));
      POP_ASSUM (fun th1 -> (POP_ASSUM (fun th2 -> REWRITE_TAC[MATCH_MP lemma_second_on_way_going (CONJ th1 th2)])));
      POP_ASSUM (fun th1 -> (POP_ASSUM (fun th2 -> REWRITE_TAC[MATCH_MP lemma_transitive_going (CONJ th2 th1)])))]);;

let lemma_atom_sub_loop = prove(`!(H:(A)hypermap) (L:(A)loop) (x:A). x inside L ==> atom H L x SUBSET dart_of L`,
   REPEAT STRIP_TAC
   THEN REWRITE_TAC[atom; SUBSET; IN_ELIM_THM; GSYM inside]
   THEN REPEAT STRIP_TAC
   THENL[POP_ASSUM ((X_CHOOSE_THEN `k:num` (SUBST1_TAC o CONJUNCT1)) o REWRITE_RULE[is_node_going])
       THEN POP_ASSUM(fun th -> REWRITE_TAC[MATCH_MP lemma_power_next_in_loop th]); ALL_TAC]
   THEN POP_ASSUM ((X_CHOOSE_THEN `k:num` (MP_TAC o CONJUNCT1)) o REWRITE_RULE[is_node_going])
   THEN ASM_CASES_TAC `~((x':A) inside (L:(A)loop))`
   THENL[POP_ASSUM(fun th -> (REWRITE_TAC[MATCH_MP lemma_power_back_and_next_outside_loop th]))
       THEN DISCH_THEN (SUBST1_TAC o SYM)
       THEN ASM_REWRITE_TAC[]; ALL_TAC]
   THEN POP_ASSUM (fun th -> MESON_TAC[th]));;

let lemma_atom_out_side_loop = prove(`!(H:(A)hypermap) (L:(A)loop) (x:A). ~(x inside L) ==> atom H L x = {x}`,
   REPEAT STRIP_TAC
   THEN MATCH_MP_TAC SUBSET_ANTISYM
   THEN STRIP_TAC
   THENL[REWRITE_TAC[atom; SUBSET; IN_ELIM_THM; IN_SING]
      THEN GEN_TAC
      THEN STRIP_TAC
      THENL[POP_ASSUM ((X_CHOOSE_THEN `k:num` (SUBST1_TAC o CONJUNCT1)) o REWRITE_RULE[is_node_going])
	  THEN POP_ASSUM (fun th -> REWRITE_TAC[MATCH_MP lemma_power_back_and_next_outside_loop th]); ALL_TAC]
      THEN POP_ASSUM ((X_CHOOSE_THEN `k:num` (MP_TAC o CONJUNCT1)) o REWRITE_RULE[is_node_going])
      THEN DISCH_THEN (MP_TAC o REWRITE_RULE[o_THM] o AP_TERM `(back (L:(A)loop)) POWER (k:num)`)
      THEN REWRITE_TAC[lemma_second_inverse_evaluation]
      THEN POP_ASSUM (fun th -> REWRITE_TAC[MATCH_MP lemma_power_back_and_next_outside_loop th])
      THEN REWRITE_TAC[EQ_SYM]; ALL_TAC]
   THEN REWRITE_TAC[SUBSET; IN_SING]
   THEN GEN_TAC
   THEN DISCH_THEN SUBST1_TAC
   THEN REWRITE_TAC[atom_reflect]);;

let lemma_atom_sub_node = prove(`!(H:(A)hypermap) (L:(A)loop) (x:A). (atom H L x) SUBSET  (node H x)`,
 REPEAT GEN_TAC
   THEN REWRITE_TAC[atom; SUBSET; IN_ELIM_THM]
   THEN GEN_TAC
   THEN STRIP_TAC
   THENL[POP_ASSUM (MP_TAC o REWRITE_RULE[is_node_going])
      THEN DISCH_THEN (X_CHOOSE_THEN `k:num` (CONJUNCTS_THEN2 SUBST1_TAC (LABEL_TAC "F1")))
      THEN POP_ASSUM (SUBST1_TAC o REWRITE_RULE[LE_REFL] o SPEC `k:num`)
      THEN MP_TAC (SPEC `k:num` (MATCH_MP  power_inverse_element_lemma (SPEC `H:(A)hypermap` node_map_and_darts)))
      THEN DISCH_THEN (X_CHOOSE_THEN `j:num` SUBST1_TAC)
      THEN REWRITE_TAC[node; lemma_in_orbit]; ALL_TAC]
   THEN POP_ASSUM (MP_TAC o REWRITE_RULE[is_node_going])
   THEN DISCH_THEN (X_CHOOSE_THEN `k:num` (CONJUNCTS_THEN2 (ASSUME_TAC) (MP_TAC o REWRITE_RULE[LE_REFL] o SPEC `k:num`)))
   THEN POP_ASSUM (SUBST1_TAC o SYM)
   THEN REWRITE_TAC[GSYM(MATCH_MP inverse_power_function (CONJUNCT2 (SPEC `H:(A)hypermap` node_map_and_darts)))]
   THEN DISCH_THEN SUBST1_TAC
   THEN REWRITE_TAC[node; lemma_in_orbit]);;

let lemma_atom_sub_dart_set = prove(`!(H:(A)hypermap) (L:(A)loop) (x:A). x IN dart H ==> atom H L x SUBSET dart H`,
  REPEAT STRIP_TAC
    THEN MATCH_MP_TAC SUBSET_TRANS
    THEN EXISTS_TAC `node (H:(A)hypermap) (x:A)`
    THEN REWRITE_TAC[lemma_atom_sub_node; node]
    THEN MP_TAC (SPEC `x:A` (MATCH_MP orbit_subset (CONJUNCT2(SPEC `H:(A)hypermap` node_map_and_darts))))
    THEN ASM_REWRITE_TAC[]);;

let lemma_atom_finite = prove(`!(H:(A)hypermap) (L:(A)loop) (x:A). FINITE (atom H L x) /\ 1 <= CARD (atom H L x)`,
   REPEAT GEN_TAC
   THEN SUBGOAL_THEN `FINITE (atom (H:(A)hypermap) (L:(A)loop) (x:A))` ASSUME_TAC
   THENL[MATCH_MP_TAC FINITE_SUBSET
      THEN EXISTS_TAC `node (H:(A)hypermap) (x:A)`
      THEN REWRITE_TAC[NODE_FINITE; lemma_atom_sub_node]; ALL_TAC]
   THEN ASM_REWRITE_TAC[]
   THEN MATCH_MP_TAC CARD_ATLEAST_1
   THEN EXISTS_TAC `x:A`
   THEN ASM_REWRITE_TAC[atom_reflect]);;

let lemma_identity_atom = prove(`!(H:(A)hypermap) (L:(A)loop) (x:A) (y:A). y IN (atom H L x) ==> atom H L x = atom H L y`,
 REPEAT STRIP_TAC
   THEN MATCH_MP_TAC SUBSET_ANTISYM
   THEN STRIP_TAC
   THENL[REWRITE_TAC[SUBSET; IN_ELIM_THM]
      THEN GEN_TAC
      THEN POP_ASSUM (MP_TAC o MATCH_MP atom_sym)
      THEN REWRITE_TAC[IMP_IMP]
      THEN ONCE_REWRITE_TAC[CONJ_SYM]
      THEN DISCH_THEN (fun th -> REWRITE_TAC[MATCH_MP atom_trans  th]); ALL_TAC]
   THEN REWRITE_TAC[SUBSET; IN_ELIM_THM]
   THEN GEN_TAC
   THEN POP_ASSUM MP_TAC
   THEN REWRITE_TAC[IMP_IMP]
   THEN ONCE_REWRITE_TAC[CONJ_SYM]
   THEN DISCH_THEN (fun th2 -> REWRITE_TAC[MATCH_MP atom_trans th2]));;

let lemma_atom_absorb_quark = prove(`!(H:(A)hypermap) (L:(A)loop) (x:A) (y:A). y IN (atom H L x) /\ next L y = inverse (node_map H) y 
    ==> (next L y)  IN (atom H L x)`,
   REPEAT GEN_TAC
   THEN DISCH_THEN (CONJUNCTS_THEN2 MP_TAC ASSUME_TAC)
   THEN DISCH_THEN (fun th -> REWRITE_TAC[MATCH_MP lemma_identity_atom th])
   THEN REWRITE_TAC[atom; IN_ELIM_THM]
   THEN DISJ1_TAC
   THEN REWRITE_TAC[is_node_going]
   THEN EXISTS_TAC `1`
   THEN REWRITE_TAC[POWER_1]
   THEN REPEAT STRIP_TAC
   THEN ASM_CASES_TAC `i:num = 1`
   THENL[POP_ASSUM SUBST1_TAC
       THEN ASM_REWRITE_TAC[POWER_1]; ALL_TAC]
   THEN REPLICATE_TAC 2 (POP_ASSUM MP_TAC)
   THEN REWRITE_TAC[IMP_IMP; GSYM LT_LE]
   THEN REWRITE_TAC[ARITH_RULE `!i:num. i < 1 <=> i = 0`]
   THEN DISCH_THEN SUBST1_TAC
   THEN REWRITE_TAC[POWER_0]);;
 
let lemma_second_absorb_quark = prove(`!(H:(A)hypermap) (L:(A)loop) (x:A) (y:A). y IN (atom H L x) /\ y = inverse (node_map H) (back L y)  ==> (back L y)  IN (atom H L x)`,
   REPEAT GEN_TAC
   THEN DISCH_THEN (CONJUNCTS_THEN2 MP_TAC ASSUME_TAC)
   THEN DISCH_THEN (fun th -> REWRITE_TAC[MATCH_MP lemma_identity_atom th])
   THEN REWRITE_TAC[atom; IN_ELIM_THM]
   THEN DISJ2_TAC
   THEN REWRITE_TAC[is_node_going]
   THEN EXISTS_TAC `1`
   THEN REWRITE_TAC[POWER_1]
   THEN REWRITE_TAC[lemma_inverse_evaluation]
   THEN REPEAT STRIP_TAC
   THEN ASM_CASES_TAC `i:num = 1`
   THENL[POP_ASSUM SUBST1_TAC
       THEN REWRITE_TAC[POWER_1]
       THEN REWRITE_TAC[lemma_inverse_evaluation] 
       THEN ASM_MESON_TAC[]; ALL_TAC]
   THEN REPLICATE_TAC 2 (POP_ASSUM MP_TAC)
   THEN REWRITE_TAC[IMP_IMP; GSYM LT_LE]
   THEN REWRITE_TAC[ARITH_RULE `!i:num. i < 1 <=> i = 0`]
   THEN DISCH_THEN SUBST1_TAC
   THEN REWRITE_TAC[POWER_0] );;

let lemma_in_subset = prove(`!s t x. s SUBSET t /\ x IN s ==> x IN t`, SET_TAC[]);;

let next_and_loop_darts = prove(`!L:(A)loop. FINITE(dart_of L) /\ (next L permutes dart_of L)`, MESON_TAC[loop_lemma]);;

let back_and_loop_darts = prove(`!L:(A)loop. FINITE(dart_of L) /\ (back L permutes dart_of L)`, MESON_TAC[loop_lemma; lemma_permute_loop]);;

let lemma_border_of_atom = prove(`!(H:(A)hypermap) (L:(A)loop).(?h:A->A t:A->A.(!x:A. (x inside L /\ (?y:A z:A. y inside L /\ z inside L /\ ~(node H y = node H z))) ==> (h x) IN (atom H L x) /\ (t x) IN (atom H L x) /\ ~((next L (h x)) = (inverse (node_map H)) (h x)) /\ ~(t x = (inverse (node_map H)) (back L (t x)))))`,
   REPEAT GEN_TAC
   THEN REWRITE_TAC [GSYM SKOLEM_THM]
   THEN GEN_TAC
   THEN REWRITE_TAC[RIGHT_EXISTS_IMP_THM]
   THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F2") (X_CHOOSE_THEN `y:A` (X_CHOOSE_THEN `z:A` (CONJUNCTS_THEN2 (LABEL_TAC "F3") (CONJUNCTS_THEN2(LABEL_TAC "F4") (LABEL_TAC "F5"))))))
   THEN SUBGOAL_THEN `?a:A. a IN (atom (H:(A)hypermap) (L:(A)loop) (x:A)) /\ ~(next L a = (inverse (node_map H)) a)` (LABEL_TAC "F4")
   THENL[ONCE_REWRITE_TAC[TAUT `A <=> (~A ==> F)`]
       THEN GEN_REWRITE_TAC (LAND_CONV o ONCE_DEPTH_CONV) [NOT_EXISTS_THM]
       THEN GEN_REWRITE_TAC (LAND_CONV o TOP_DEPTH_CONV) [DE_MORGAN_THM; TAUT `~ ~A = A`; TAUT `(~A \/ B) <=> (A==>B)`]
       THEN DISCH_THEN (LABEL_TAC "G1")
       THEN REMOVE_THEN "F5" MP_TAC
       THEN REWRITE_TAC[]
       THEN SUBGOAL_THEN `dart_of (L:(A)loop) = atom (H:(A)hypermap) L (x:A)` (LABEL_TAC "G2")
       THENL[SUBGOAL_THEN `!k:num. ((next (L:(A)loop)) POWER k) (x:A) IN (atom (H:(A)hypermap) L x)` ASSUME_TAC
	  THENL[INDUCT_TAC
	      THENL[REWRITE_TAC[POWER_0; I_THM; node; atom_reflect]; ALL_TAC]
  	      THEN POP_ASSUM (LABEL_TAC "G2")
	      THEN REWRITE_TAC[COM_POWER; o_THM]
	      THEN USE_THEN "G2" (fun th1 -> (USE_THEN "G1" (fun th2 -> (MP_TAC(MATCH_MP th2 th1)))))
	      THEN (USE_THEN "G2" (fun th2-> (DISCH_THEN (fun th3 -> (REWRITE_TAC[MATCH_MP lemma_atom_absorb_quark (CONJ th2 th3)]))))); ALL_TAC]
	  THEN MATCH_MP_TAC SUBSET_ANTISYM
	  THEN USE_THEN "F2" (fun th2 -> REWRITE_TAC[MATCH_MP lemma_atom_sub_loop th2])
	  THEN REWRITE_TAC[SUBSET; GSYM inside]
	  THEN GEN_TAC
	  THEN USE_THEN "F2" (fun th2-> (DISCH_THEN (fun th3-> (MP_TAC (MATCH_MP lemma_next_power_representation (CONJ th2 th3))))))
	  THEN DISCH_THEN (X_CHOOSE_THEN `k:num` (SUBST1_TAC o CONJUNCT2))
	  THEN POP_ASSUM (fun th -> REWRITE_TAC[SPEC `k:num` th]); ALL_TAC]
       THEN REMOVE_THEN "F3" (LABEL_TAC "F3" o REWRITE_RULE[inside])
       THEN REMOVE_THEN "F4" (LABEL_TAC "F4" o REWRITE_RULE[inside])
       THEN REMOVE_THEN "G2" SUBST_ALL_TAC
       THEN LABEL_TAC "G3" (SPECL[`H:(A)hypermap`; `L:(A)loop`; `x:A`] lemma_atom_sub_node)
       THEN USE_THEN "F3" (fun th1 -> (USE_THEN "G3" (fun th2 -> (MP_TAC(MATCH_MP lemma_in_subset (CONJ th2 th1))))))
       THEN DISCH_THEN (fun th -> REWRITE_TAC[SYM(MATCH_MP lemma_node_identity th)])
       THEN USE_THEN "F4" (fun th1 -> (USE_THEN "G3" (fun th2 -> (MP_TAC(MATCH_MP lemma_in_subset (CONJ th2 th1))))))
       THEN DISCH_THEN (fun th -> REWRITE_TAC[SYM(MATCH_MP lemma_node_identity th)]); ALL_TAC]
   THEN POP_ASSUM (X_CHOOSE_THEN `h:A` ASSUME_TAC)
   THEN EXISTS_TAC `h:A`
   THEN POP_ASSUM (fun th -> SIMP_TAC[th])
   THEN ONCE_REWRITE_TAC[TAUT `A <=> (~A ==> F)`]
   THEN GEN_REWRITE_TAC (LAND_CONV o ONCE_DEPTH_CONV) [NOT_EXISTS_THM]
   THEN GEN_REWRITE_TAC (LAND_CONV o TOP_DEPTH_CONV) [DE_MORGAN_THM; TAUT `~ ~A = A`; TAUT `(~A \/ B) <=> (A==>B)`]
   THEN DISCH_THEN (LABEL_TAC "G1")
   THEN REMOVE_THEN "F5" MP_TAC
   THEN REWRITE_TAC[]
   THEN SUBGOAL_THEN `dart_of (L:(A)loop) = atom (H:(A)hypermap) L (x:A)` (LABEL_TAC "G2")
   THENL[SUBGOAL_THEN `!k:num. ((back (L:(A)loop)) POWER k) (x:A) IN (atom (H:(A)hypermap) L x)` ASSUME_TAC
      THENL[INDUCT_TAC
	  THENL[REWRITE_TAC[POWER_0; I_THM; node; atom_reflect]; ALL_TAC]
	  THEN POP_ASSUM (LABEL_TAC "G2")
	  THEN REWRITE_TAC[COM_POWER; o_THM]
	  THEN USE_THEN "G2" (fun th1 -> (USE_THEN "G1" (fun th2 -> (MP_TAC(MATCH_MP th2 th1)))))
	  THEN (USE_THEN "G2" (fun th2-> (DISCH_THEN (fun th3 -> (REWRITE_TAC[MATCH_MP lemma_second_absorb_quark (CONJ th2 th3)]))))); ALL_TAC]
      THEN MATCH_MP_TAC SUBSET_ANTISYM
      THEN USE_THEN "F2" (fun th2 -> REWRITE_TAC[MATCH_MP lemma_atom_sub_loop th2])
      THEN REWRITE_TAC[SUBSET; GSYM inside]
      THEN GEN_TAC
      THEN USE_THEN "F2" (fun th2-> (DISCH_THEN (fun th3-> (MP_TAC (MATCH_MP lemma_next_power_representation (CONJ th2 th3) )))))
      THEN DISCH_THEN (X_CHOOSE_THEN `k:num` (MP_TAC o CONJUNCT2))
      THEN ONCE_REWRITE_TAC[lemma_inverse_on_loop]
      THEN MP_TAC (SPEC `k:num` (MATCH_MP power_inverse_element_lemma (SPEC `L:(A)loop` back_and_loop_darts)))
      THEN DISCH_THEN (X_CHOOSE_THEN `j:num` SUBST1_TAC)
      THEN DISCH_THEN SUBST1_TAC
      THEN POP_ASSUM (fun th -> REWRITE_TAC[SPEC `j:num` th]); ALL_TAC]
   THEN REMOVE_THEN "F3" (LABEL_TAC "F3" o REWRITE_RULE[inside])
   THEN REMOVE_THEN "F4" (LABEL_TAC "F4" o REWRITE_RULE[inside])
   THEN REMOVE_THEN "G2" SUBST_ALL_TAC
   THEN LABEL_TAC "G3" (SPECL[`H:(A)hypermap`; `L:(A)loop`; `x:A`] lemma_atom_sub_node)
   THEN USE_THEN "F3" (fun th1 -> (USE_THEN "G3" (fun th2 -> (MP_TAC(MATCH_MP lemma_in_subset (CONJ th2 th1))))))
   THEN DISCH_THEN (fun th -> REWRITE_TAC[SYM(MATCH_MP lemma_node_identity th)])
   THEN USE_THEN "F4" (fun th1 -> (USE_THEN "G3" (fun th2 -> (MP_TAC(MATCH_MP lemma_in_subset (CONJ th2 th1))))))
   THEN DISCH_THEN (fun th -> REWRITE_TAC[SYM(MATCH_MP lemma_node_identity th)]));;

(* The definition of quotient hypermaps *)

let is_normal = new_definition `!(H:(A)hypermap) (NF:(A)loop -> bool). is_normal H NF 
<=> (!(L:(A)loop). L IN NF ==> ((is_loop H L) /\ (?x:A. x IN dart H /\ x inside L))) /\
    (!(L:(A)loop). L IN NF ==> (?y:A z:A. y inside L /\ z inside L /\ ~(node H y = node H z ))) /\
    (!(L:(A)loop) (L':(A)loop) (x:A). L IN NF /\ L' IN NF /\ x inside L /\ x inside L' ==> L = L') /\
    (!(L:(A)loop) x:A y:A. L IN NF /\ x inside L /\ y IN node H x ==> ?L':(A)loop. L' IN NF /\ y inside L') `;;

let lemm_nornal_loop_sub_dart = prove(`!(H:(A)hypermap) (NF:(A)loop->bool) (L:(A)loop). is_normal H NF /\ L IN NF ==> (dart_of L) SUBSET dart H`,
   REPEAT GEN_TAC
   THEN DISCH_THEN (CONJUNCTS_THEN2 (MP_TAC o SPEC `L:(A)loop` o  CONJUNCT1 o REWRITE_RULE[is_normal]) ASSUME_TAC)
   THEN POP_ASSUM (fun th -> REWRITE_TAC[th])
   THEN DISCH_THEN (CONJUNCTS_THEN2 ASSUME_TAC (X_CHOOSE_THEN `x:A` MP_TAC))
   THEN POP_ASSUM (fun th1 -> (DISCH_THEN (fun th2-> REWRITE_TAC[MATCH_MP support_loop_sub_dart (CONJ th1 th2)]))));;


let quotient_darts = new_definition `!(H:(A)hypermap) (NF:(A)loop->bool). quotient_darts H NF = {atom H L x | (L:(A)loop) (x:A) | L IN NF /\ x inside L}`;;

let support_darts = new_definition `!(NF:(A)loop->bool). support_darts NF  = UNIONS {dart_of (L:(A)loop) | L IN NF}`;;

let lemma_in_loop = prove(`!(H:(A)hypermap) (L:(A)loop) (x:A) (y:A). x inside L /\ y IN atom H L x ==> y inside L`,
   REPEAT STRIP_TAC
   THEN REWRITE_TAC[inside]
   THEN MATCH_MP_TAC lemma_in_subset
   THEN EXISTS_TAC `atom (H:(A)hypermap) (L:(A)loop) (x:A)`
   THEN POP_ASSUM (fun th -> REWRITE_TAC[th])
   THEN MATCH_MP_TAC lemma_atom_sub_loop
   THEN ASM_REWRITE_TAC[]);;

let lemma_in_dart = prove(`!(H:(A)hypermap) (NF:(A)loop->bool) (L:(A)loop) (x:A). is_normal H NF /\ L IN NF /\ x inside L ==> x IN dart H`,
 REPEAT STRIP_TAC
   THEN MATCH_MP_TAC lemma_in_subset
   THEN EXISTS_TAC `dart_of (L:(A)loop)`
   THEN POP_ASSUM (fun th-> REWRITE_TAC[GSYM inside; th])
   THEN POP_ASSUM(fun th1->(POP_ASSUM(fun th -> REWRITE_TAC[MATCH_MP lemm_nornal_loop_sub_dart (CONJ th th1)]))));;

let lemma_support_and_atoms = prove(`!(H:(A)hypermap) (NF:(A)loop->bool). is_normal H NF ==>  support_darts NF = UNIONS (quotient_darts H NF)`,
   REPEAT GEN_TAC
   THEN DISCH_THEN (LABEL_TAC "F1")
   THEN CONV_TAC SYM_CONV
   THEN REWRITE_TAC[support_darts; quotient_darts]
   THEN MATCH_MP_TAC SUBSET_ANTISYM
   THEN STRIP_TAC
   THENL[REWRITE_TAC[SUBSET; IN_UNIONS; IN_ELIM_THM]
       THEN REPEAT STRIP_TAC
       THEN EXISTS_TAC `dart_of (L:(A)loop)`
       THEN STRIP_TAC
       THENL[EXISTS_TAC `L:(A)loop` THEN ASM_REWRITE_TAC[]; ALL_TAC]
       THEN UNDISCH_THEN `t:A->bool = atom (H:(A)hypermap) (L:(A)loop) (x':A)` SUBST_ALL_TAC
       THEN MATCH_MP_TAC lemma_in_subset
       THEN EXISTS_TAC `atom (H:(A)hypermap) (L:(A)loop) (x':A)`
       THEN POP_ASSUM (fun th-> REWRITE_TAC[th])
       THEN POP_ASSUM (fun th -> (REWRITE_TAC[MATCH_MP lemma_atom_sub_loop th])); ALL_TAC]
   THEN REWRITE_TAC[SUBSET; IN_UNIONS; IN_ELIM_THM]
   THEN REPEAT STRIP_TAC
   THEN EXISTS_TAC `atom (H:(A)hypermap) (L:(A)loop) (x:A)`
   THEN STRIP_TAC
   THENL[EXISTS_TAC `L:(A)loop`
      THEN EXISTS_TAC `x:A`
      THEN POP_ASSUM MP_TAC
      THEN POP_ASSUM SUBST1_TAC
      THEN ASM_REWRITE_TAC[GSYM inside]; ALL_TAC]
   THEN REWRITE_TAC[atom_reflect]);;

let lemma_finite_support = prove(`!(H:(A)hypermap) (NF:(A)loop->bool). is_normal H NF ==>  support_darts NF SUBSET dart H /\ FINITE (support_darts NF)`,
   REPEAT GEN_TAC
   THEN DISCH_THEN (LABEL_TAC "F1")
   THEN SUBGOAL_THEN `support_darts (NF:(A)loop->bool) SUBSET dart H` ASSUME_TAC
   THENL[REWRITE_TAC[support_darts; SUBSET; IN_UNIONS; IN_ELIM_THM]
       THEN REPEAT STRIP_TAC
       THEN POP_ASSUM MP_TAC
       THEN POP_ASSUM SUBST1_TAC
       THEN POP_ASSUM (fun th2 -> (POP_ASSUM (fun th1 -> MP_TAC (MATCH_MP lemm_nornal_loop_sub_dart (CONJ th1 th2)))))
       THEN REWRITE_TAC[IMP_IMP]
       THEN REWRITE_TAC[lemma_in_subset]; ALL_TAC]
   THEN ASM_REWRITE_TAC[]
   THEN MATCH_MP_TAC FINITE_SUBSET
   THEN EXISTS_TAC `dart (H:(A)hypermap)`
   THEN ASM_REWRITE_TAC[hypermap_lemma]);;

let lemma_in_support2 = prove(`!(NF:(A)loop->bool) L:(A)loop (x:A). x inside L /\ L IN NF ==> x IN support_darts NF`,
   REWRITE_TAC[inside; support_darts] THEN SET_TAC[]);;

let lemma_in_support = prove(`!(NF:(A)loop->bool) (x:A). x IN support_darts NF <=> ?L:(A)loop. L IN NF /\ x inside L`,
   REPEAT GEN_TAC
   THEN EQ_TAC
   THENL[REWRITE_TAC[support_darts; IN_UNIONS; IN_ELIM_THM]
      THEN REPEAT STRIP_TAC
      THEN EXISTS_TAC `L:(A)loop`
      THEN POP_ASSUM MP_TAC
      THEN POP_ASSUM SUBST1_TAC
      THEN REWRITE_TAC[GSYM inside]
      THEN ASM_REWRITE_TAC[]; ALL_TAC]
   THEN MESON_TAC[lemma_in_support2]);;

let lemma_node_in_support2 = prove(`!(H:(A)hypermap) (NF:(A)loop->bool) x:A n:num. is_normal H NF /\ x IN support_darts NF ==> ((node_map H) POWER n) x IN support_darts NF`,
   REPEAT GEN_TAC
   THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F1") MP_TAC)
   THEN SPEC_TAC (`n:num`, `n:num`)
   THEN INDUCT_TAC
   THENL[REWRITE_TAC[POWER_0; I_THM] THEN SIMP_TAC[]; ALL_TAC]
   THEN DISCH_TAC
   THEN FIRST_X_ASSUM (MP_TAC o check (is_imp o concl))
   THEN POP_ASSUM (fun th -> REWRITE_TAC[th])
   THEN DISCH_THEN (LABEL_TAC "F2")
   THEN REWRITE_TAC[COM_POWER; o_THM]
   THEN ABBREV_TAC `y = ((node_map (H:(A)hypermap)) POWER (n:num)) (x:A)`
   THEN REMOVE_THEN "F2" (MP_TAC o REWRITE_RULE[lemma_in_support])
   THEN DISCH_THEN (X_CHOOSE_THEN `L:(A)loop` (CONJUNCTS_THEN2 (LABEL_TAC "F2") (LABEL_TAC "F3")))
   THEN MP_TAC (SPECL[`node_map (H:(A)hypermap)`; `1`; `y:A`] lemma_in_orbit)
   THEN REWRITE_TAC[POWER_1; GSYM node]
   THEN DISCH_TAC
   THEN USE_THEN "F1" (MP_TAC o SPECL[`L:(A)loop`; `y:A`; `node_map (H:(A)hypermap) (y:A)`] o CONJUNCT2 o CONJUNCT2 o CONJUNCT2 o  REWRITE_RULE[is_normal])
   THEN ASM_REWRITE_TAC[]
   THEN DISCH_THEN (X_CHOOSE_THEN `L':(A)loop` (MP_TAC o ONCE_REWRITE_RULE[CONJ_SYM]))
   THEN REWRITE_TAC[lemma_in_support2]);;

let lemma_loop_outside_node = prove(`!(H:(A)hypermap) (NF:(A)loop->bool) (L:(A)loop) (x:A). 
    is_normal H NF /\ L IN NF ==> ~(dart_of L SUBSET  node H x)`,
   REPEAT GEN_TAC
   THEN DISCH_THEN (CONJUNCTS_THEN2 (MP_TAC o SPEC `L:(A)loop` o CONJUNCT1 o CONJUNCT2 o REWRITE_RULE[is_normal]) (ASSUME_TAC))
   THEN ASM_REWRITE_TAC[]
   THEN ONCE_REWRITE_TAC[TAUT `(A ==> ~B) <=> (B ==> ~A)`]
   THEN REWRITE_TAC[NOT_EXISTS_THM; TAUT `~(A /\ B /\ ~C) <=> (A /\ B ==> C)`]
   THEN DISCH_TAC
   THEN REPEAT GEN_TAC
   THEN REWRITE_TAC[inside]
   THEN POP_ASSUM (fun th -> (DISCH_THEN (CONJUNCTS_THEN2 (fun th1 -> (ASSUME_TAC (MATCH_MP lemma_in_subset (CONJ th th1)))) (fun th2 -> (ASSUME_TAC (MATCH_MP lemma_in_subset (CONJ th th2)))))))
   THEN REPLICATE_TAC 2 (POP_ASSUM (SUBST1_TAC o SYM o MATCH_MP lemma_node_identity))
   THEN SIMP_TAC[]);;

let lemma_size_of_normal_loop = prove(`!(H:(A)hypermap) (NF:(A)loop->bool) (L:(A)loop). is_normal H NF /\ L IN NF ==> 2 <= size L`,
 REPEAT GEN_TAC
   THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F1") (LABEL_TAC "F2"))
   THEN USE_THEN "F2" (fun th -> (USE_THEN "F1" (MP_TAC o REWRITE_RULE[th] o  SPEC `L:(A)loop` o  CONJUNCT1 o REWRITE_RULE[is_normal])))
   THEN DISCH_THEN (LABEL_TAC "F3" o CONJUNCT1)
   THEN USE_THEN "F1" (MP_TAC o SPEC `L:(A)loop` o CONJUNCT1 o CONJUNCT2 o REWRITE_RULE[is_normal])
   THEN ASM_REWRITE_TAC[inside]
   THEN DISCH_THEN (X_CHOOSE_THEN `x:A` (X_CHOOSE_THEN `y:A` STRIP_ASSUME_TAC))
   THEN SUBGOAL_THEN `~(x:A = y:A)` ASSUME_TAC
   THENL[POP_ASSUM MP_TAC
       THEN REWRITE_TAC[CONTRAPOS_THM]
       THEN MESON_TAC[]; ALL_TAC]
   THEN REWRITE_TAC[size]
   THEN MATCH_MP_TAC CARD_ATLEAST_2
   THEN EXISTS_TAC `x:A` THEN EXISTS_TAC `y:A`
   THEN ASM_REWRITE_TAC[loop_lemma]);;

let disjoint_loops = prove(`!(H:(A)hypermap) (NF:(A)loop->bool) (L:(A)loop) (L':(A)loop) (x:A). 
    is_normal H NF /\ L IN NF /\ L' IN NF /\ x inside L /\ x inside L' ==> L = L'`,
   REPEAT GEN_TAC
   THEN DISCH_THEN (CONJUNCTS_THEN2 (ASSUME_TAC) MP_TAC)
   THEN POP_ASSUM (fun th-> MESON_TAC[CONJUNCT1(CONJUNCT2(CONJUNCT2(REWRITE_RULE[is_normal] th)))]));;

let lemma_choice_function = prove(`!(H:(A)hypermap) (NF:(A)loop->bool).  ?choice_function: A->(A->bool). !x:A. is_normal H NF ==> ((~(x IN support_darts NF) ==> choice_function x = {x}) /\ (x IN support_darts NF ==> (?L:(A)loop. L IN NF /\ x inside L /\ choice_function x = atom H L x)))`,
 REPEAT GEN_TAC
   THEN REWRITE_TAC[GSYM SKOLEM_THM]
   THEN GEN_TAC
   THEN REWRITE_TAC[RIGHT_EXISTS_IMP_THM]
   THEN DISCH_THEN (LABEL_TAC "F1")
   THEN USE_THEN "F1" (fun th -> REWRITE_TAC[MATCH_MP lemma_support_and_atoms th])
   THEN ASM_CASES_TAC `~(x:A IN UNIONS (quotient_darts (H:(A)hypermap) (NF:(A)loop->bool)))`
   THENL[EXISTS_TAC `{x:A}`
       THEN POP_ASSUM(fun th -> SIMP_TAC[th]); ALL_TAC]
   THEN POP_ASSUM (ASSUME_TAC o REWRITE_RULE[])  
   THEN ASM_REWRITE_TAC[]
   THEN POP_ASSUM (MP_TAC o REWRITE_RULE[quotient_darts; IN_UNIONS; IN_ELIM_THM])
   THEN DISCH_THEN (X_CHOOSE_THEN `t:A->bool` (CONJUNCTS_THEN2 MP_TAC (LABEL_TAC "F2" )))
   THEN DISCH_THEN (X_CHOOSE_THEN `L:(A)loop` (X_CHOOSE_THEN `y:A` (CONJUNCTS_THEN2 (CONJUNCTS_THEN2 (LABEL_TAC "F3") (LABEL_TAC "F4")) (LABEL_TAC "F5"))))
   THEN ONCE_REWRITE_TAC[SWAP_EXISTS_THM]
   THEN EXISTS_TAC `L:(A)loop`
   THEN EXISTS_TAC `t:A->bool`
   THEN POP_ASSUM SUBST_ALL_TAC
   THEN USE_THEN "F3" (fun th -> REWRITE_TAC[th])
   THEN USE_THEN "F1" (fun th -> (MP_TAC (SPEC `L:(A)loop`(CONJUNCT1 (REWRITE_RULE[is_normal] th)))))
   THEN ASM_REWRITE_TAC[]
   THEN DISCH_THEN (LABEL_TAC "F5" o CONJUNCT1)
   THEN USE_THEN "F2" (fun th -> REWRITE_TAC[MATCH_MP lemma_identity_atom th])
   THEN MATCH_MP_TAC lemma_in_loop
   THEN ASM_MESON_TAC[]);;

let lemma_choice = new_specification ["choice"] (REWRITE_RULE[SKOLEM_THM] lemma_choice_function);;

let first_unique_choice = prove(`!(H:(A)hypermap) (NF:(A)loop->bool). is_normal H NF ==> (!x:A. ~(x IN support_darts NF) ==> choice H NF x = {x}) 
/\ (!L:(A)loop x:A. L IN NF /\ x inside L ==> choice H NF x = atom H L x)`,
 REPEAT GEN_TAC
   THEN DISCH_THEN (LABEL_TAC "F1")
   THEN STRIP_TAC
   THENL[POP_ASSUM (fun th -> REWRITE_TAC[MATCH_MP lemma_choice th]); ALL_TAC]
   THEN REPEAT GEN_TAC
   THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F2") (LABEL_TAC "F3"))
   THEN USE_THEN "F2"(fun th ->(USE_THEN "F3" (fun th1-> (ASSUME_TAC(MATCH_MP lemma_in_support2 (CONJ th1 th))))))
   THEN USE_THEN "F1" (fun th-> MP_TAC(CONJUNCT2(SPEC `x:A` (MATCH_MP lemma_choice th))))
   THEN POP_ASSUM (fun th-> REWRITE_TAC[th])
   THEN DISCH_THEN (X_CHOOSE_THEN `L':(A)loop` (CONJUNCTS_THEN2 (ASSUME_TAC) (CONJUNCTS_THEN2 (LABEL_TAC "F4") SUBST1_TAC)))
   THEN SUBGOAL_THEN `L' = L:(A)loop` SUBST_ALL_TAC
   THENL[MATCH_MP_TAC disjoint_loops THEN ASM_MESON_TAC[]; ALL_TAC]
   THEN SIMP_TAC[]);;

let unique_choice = prove(`!(H:(A)hypermap) (NF:(A)loop->bool) (L:(A)loop) (x:A). is_normal H NF /\ L IN NF /\ x inside L ==> choice H NF x = atom H L x`,
   REPEAT STRIP_TAC
   THEN UNDISCH_THEN `is_normal (H:(A)hypermap) (NF:(A)loop->bool)` (MP_TAC o SPECL[`L:(A)loop`; `x:A`] o CONJUNCT2 o MATCH_MP first_unique_choice)
   THEN ASM_REWRITE_TAC[]);;

let lemma_in_quotient = prove(`!(H:(A)hypermap) (NF:(A)loop->bool) (L:(A)loop) (x:A). L IN NF /\ x inside L ==> (atom H L x) IN (quotient_darts H NF)`,
 REPEAT STRIP_TAC
   THEN REWRITE_TAC[quotient_darts; IN_ELIM_THM]
   THEN EXISTS_TAC `L:(A)loop`
   THEN EXISTS_TAC `x:A`
   THEN ASM_REWRITE_TAC[]);;

let lemma_finite_quotient_darts = prove(`!(H:(A)hypermap) (NF:(A)loop->bool). is_normal H NF ==> FINITE (quotient_darts H NF)`,
   REPEAT GEN_TAC
   THEN DISCH_THEN (LABEL_TAC "F1")
   THEN SUBGOAL_THEN `IMAGE (choice (H:(A)hypermap) (NF:(A)loop->bool)) (support_darts NF) = quotient_darts H NF` ASSUME_TAC
   THENL[REWRITE_TAC[IMAGE; EXTENSION; IN_ELIM_THM]
      THEN GEN_TAC
      THEN REWRITE_TAC[GSYM EXTENSION]
      THEN EQ_TAC
      THENL[DISCH_THEN (X_CHOOSE_THEN `y:A` (CONJUNCTS_THEN2 (MP_TAC o REWRITE_RULE[lemma_in_support]) (SUBST1_TAC)))
          THEN DISCH_THEN (X_CHOOSE_THEN `L':(A)loop` (LABEL_TAC "F2"))
          THEN USE_THEN "F1" (ASSUME_TAC o CONJUNCT2 o MATCH_MP first_unique_choice)
          THEN POP_ASSUM (fun th-> (USE_THEN "F2" (fun th1-> REWRITE_TAC[MATCH_MP th th1])))
          THEN POP_ASSUM (fun th-> REWRITE_TAC[MATCH_MP lemma_in_quotient th]); ALL_TAC]
      THEN REWRITE_TAC[quotient_darts; IN_ELIM_THM]
      THEN DISCH_THEN (X_CHOOSE_THEN `L:(A)loop` (X_CHOOSE_THEN `y:A` (CONJUNCTS_THEN2 (CONJUNCTS_THEN2 (LABEL_TAC "G1") (LABEL_TAC "G2")) (SUBST1_TAC))))
      THEN USE_THEN "G1" (fun th-> (USE_THEN "G2" (fun th1-> (MP_TAC (MATCH_MP lemma_in_support2 (CONJ th1 th))))))
      THEN DISCH_TAC
      THEN EXISTS_TAC `y:A`
      THEN POP_ASSUM (fun th-> REWRITE_TAC[th])
      THEN USE_THEN "F1" (MP_TAC o SPECL[`L:(A)loop`; `y:A`] o CONJUNCT2 o MATCH_MP first_unique_choice)
      THEN ASM_REWRITE_TAC[EQ_SYM]; ALL_TAC]
   THEN POP_ASSUM (SUBST1_TAC o SYM)
   THEN MATCH_MP_TAC FINITE_IMAGE
   THEN USE_THEN "F1" (fun th -> REWRITE_TAC[MATCH_MP lemma_finite_support th]));;

let lemma_finite_normal_loops = prove(`!H:(A)hypermap NF:(A)loop->bool. is_normal H NF ==> FINITE NF`,
   REPEAT GEN_TAC
   THEN DISCH_THEN (LABEL_TAC "F1")
   THEN SUBGOAL_THEN `?f:A->(A)loop. !x:A. (x IN support_darts NF ==> ?L:(A)loop. L IN NF /\ x inside L /\ f x = L)` MP_TAC
   THENL[REWRITE_TAC[GSYM SKOLEM_THM]
      THEN GEN_TAC
      THEN REWRITE_TAC[GSYM RIGHT_IMP_EXISTS_THM]
      THEN REWRITE_TAC[lemma_in_support]
      THEN DISCH_THEN (X_CHOOSE_THEN `L:(A)loop` (CONJUNCTS_THEN2 (LABEL_TAC "G1") (LABEL_TAC "G2")))
      THEN REWRITE_TAC[SWAP_EXISTS_THM]
      THEN EXISTS_TAC `L:(A)loop`
      THEN EXISTS_TAC `L:(A)loop`
      THEN ASM_REWRITE_TAC[]; ALL_TAC]
   THEN DISCH_THEN (X_CHOOSE_THEN `f:A->(A)loop` (LABEL_TAC "F2"))
   THEN SUBGOAL_THEN `IMAGE (f:A->(A)loop) (support_darts (NF:(A)loop->bool)) = NF` (SUBST1_TAC o SYM)
   THENL[REWRITE_TAC[IMAGE; EXTENSION; IN_ELIM_THM]
     THEN GEN_TAC
     THEN EQ_TAC
     THENL[ DISCH_THEN (X_CHOOSE_THEN `y:A` (CONJUNCTS_THEN2 MP_TAC SUBST1_TAC))
        THEN DISCH_THEN (fun th-> (USE_THEN "F2" (fun thm -> MP_TAC(MATCH_MP thm th))))
        THEN DISCH_THEN (X_CHOOSE_THEN `L':(A)loop` (CONJUNCTS_THEN2 ASSUME_TAC (SUBST1_TAC o CONJUNCT2)))
        THEN ASM_REWRITE_TAC[]; ALL_TAC]
     THEN DISCH_THEN (LABEL_TAC "F3")
     THEN USE_THEN "F3" (fun th -> USE_THEN "F1" (MP_TAC o REWRITE_RULE[th] o  SPEC `x:(A)loop` o CONJUNCT1 o  REWRITE_RULE[is_normal]))
     THEN DISCH_THEN (MP_TAC o CONJUNCT2)
     THEN DISCH_THEN (X_CHOOSE_THEN `y:A` (CONJUNCTS_THEN2 (LABEL_TAC "F4") (LABEL_TAC "F5")))
     THEN EXISTS_TAC `y:A`
     THEN USE_THEN "F3" (fun th-> (USE_THEN "F5" (fun th1-> (ASSUME_TAC (MATCH_MP lemma_in_support2 (CONJ th1 th))))))
     THEN ASM_REWRITE_TAC[]
     THEN POP_ASSUM (fun th-> (USE_THEN "F2" (fun thm -> MP_TAC(MATCH_MP thm th))))
     THEN DISCH_THEN (X_CHOOSE_THEN `L:(A)loop` (CONJUNCTS_THEN2 ASSUME_TAC (CONJUNCTS_THEN2 ASSUME_TAC SUBST1_TAC)))
     THEN MATCH_MP_TAC disjoint_loops
     THEN EXISTS_TAC `H:(A)hypermap` THEN EXISTS_TAC `NF:(A)loop->bool` THEN EXISTS_TAC `y:A`
     THEN ASM_REWRITE_TAC[]; ALL_TAC]
   THEN MATCH_MP_TAC FINITE_IMAGE
   THEN USE_THEN "F1" (fun th -> REWRITE_TAC[MATCH_MP  lemma_finite_support th]));;

let lemma_border_of_atom2 = prove(`!(H:(A)hypermap) (NF:(A)loop->bool). ?(h:A->A) (t:A->A).(!x:A. is_normal H NF ==> (~(x IN support_darts NF) ==> h x = x /\ t x = x) /\ (x IN support_darts NF ==> (?L:(A)loop. L IN NF /\ x inside L /\ (h x) IN (atom H L x) /\ ~(next L (h x) = inverse (node_map H) (h x)) /\ (t x) IN (atom H L x) /\ ~(t x = inverse (node_map H) (back L (t x))))))`,
    REPEAT GEN_TAC
    THEN ONCE_REWRITE_TAC[RIGHT_FORALL_IMP_THM]
    THEN REPLICATE_TAC 2 (ONCE_REWRITE_TAC[RIGHT_EXISTS_IMP_THM])
    THEN DISCH_THEN (LABEL_TAC "F1")
    THEN REWRITE_TAC[GSYM SKOLEM_THM]
    THEN GEN_TAC
    THEN ASM_CASES_TAC `~(x:A IN support_darts (NF:(A)loop->bool))`
    THENL[EXISTS_TAC `x:A`
        THEN EXISTS_TAC `x:A`
	THEN ASM_REWRITE_TAC[]; ALL_TAC]
    THEN POP_ASSUM (ASSUME_TAC o REWRITE_RULE[])
    THEN POP_ASSUM (fun th -> (REWRITE_TAC[th] THEN MP_TAC (REWRITE_RULE[lemma_in_support] th)))
    THEN DISCH_THEN (X_CHOOSE_THEN `L:(A)loop` (CONJUNCTS_THEN2 (LABEL_TAC "F2") (LABEL_TAC "F3")))
    THEN MP_TAC(SPECL[`H:(A)hypermap`; `L:(A)loop`] lemma_border_of_atom)
    THEN DISCH_THEN (X_CHOOSE_THEN `h1:A->A` (X_CHOOSE_THEN `t1:A->A` (MP_TAC o SPEC `x:A`)))
    THEN ASM_REWRITE_TAC[]
    THEN USE_THEN "F1" (MP_TAC o SPEC `L:(A)loop` o  CONJUNCT1 o CONJUNCT2 o  REWRITE_RULE[is_normal])
    THEN ASM_REWRITE_TAC[]
    THEN DISCH_THEN (fun th -> SIMP_TAC[th])
    THEN USE_THEN "F1" (MP_TAC o SPEC `L:(A)loop` o  CONJUNCT1  o  REWRITE_RULE[is_normal])
    THEN ASM_REWRITE_TAC[]
    THEN DISCH_THEN (fun th -> SIMP_TAC[th])
    THEN REPEAT STRIP_TAC
    THEN EXISTS_TAC `(h1:A->A) (x:A)`
    THEN EXISTS_TAC `(t1:A->A) (x:A)`
    THEN EXISTS_TAC `L:(A)loop`
    THEN ASM_REWRITE_TAC[]);;

let lemma_head_tail = new_specification ["head"; "tail"] (REWRITE_RULE[SKOLEM_THM] lemma_border_of_atom2);;

let lemma_unique_head = prove(`!(H:(A)hypermap) (NF:(A)loop->bool) (L:(A)loop) (x:A) (y:A). is_normal H NF /\ L IN NF /\ x inside L /\ y IN atom H L x /\ ~(next L y = inverse (node_map H) y) ==> head H NF x = y`,
   REPEAT GEN_TAC
   THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F1") (CONJUNCTS_THEN2 (LABEL_TAC "F2") (CONJUNCTS_THEN2 (LABEL_TAC "F3") (CONJUNCTS_THEN2 (LABEL_TAC "F4")
(LABEL_TAC "F5")))))
   THEN USE_THEN "F1" (MP_TAC o SPEC `L:(A)loop` o CONJUNCT1 o REWRITE_RULE[is_normal])
   THEN USE_THEN "F2" (fun th -> REWRITE_TAC[th])
   THEN DISCH_THEN (LABEL_TAC "F6" o CONJUNCT1)
   THEN USE_THEN "F1" (MP_TAC o CONJUNCT2 o SPEC `x:A` o MATCH_MP lemma_head_tail)
   THEN USE_THEN "F3" (fun th1 -> (USE_THEN "F2" (fun th2 -> REWRITE_TAC[MATCH_MP lemma_in_support2 (CONJ th1 th2)])))
   THEN DISCH_THEN (X_CHOOSE_THEN `L':(A)loop` (CONJUNCTS_THEN2 (LABEL_TAC "F7") (CONJUNCTS_THEN2 (LABEL_TAC "F8") (CONJUNCTS_THEN2 (LABEL_TAC "F9")
(LABEL_TAC "F10" o CONJUNCT1)))))
   THEN USE_THEN "F1" (MP_TAC o SPECL[`L':(A)loop`; `L:(A)loop`; `x:A`] o CONJUNCT1 o CONJUNCT2 o CONJUNCT2 o  REWRITE_RULE[is_normal])
   THEN REMOVE_THEN "F8" (fun th -> REWRITE_TAC[th])
   THEN REMOVE_THEN "F7" (fun th -> REWRITE_TAC[th])
   THEN USE_THEN "F3" (fun th -> REWRITE_TAC[th])
   THEN USE_THEN "F2" (fun th -> REWRITE_TAC[th])
   THEN DISCH_THEN SUBST_ALL_TAC
   THEN ABBREV_TAC `z = head (H:(A)hypermap) (NF:(A)loop->bool) (x:A)`
   THEN REMOVE_THEN "F4" (fun th2 -> (MP_TAC (MATCH_MP lemma_identity_atom th2)))
   THEN DISCH_THEN SUBST_ALL_TAC
   THEN REMOVE_THEN "F9" (MP_TAC o REWRITE_RULE[atom; IN_ELIM_THM; is_node_going])
   THEN STRIP_TAC
   THENL[ASM_CASES_TAC `k:num = 0`
       THENL[UNDISCH_TAC `z:A = ((next (L:(A)loop)) POWER (k:num)) (y:A)`
	   THEN POP_ASSUM SUBST1_TAC
	   THEN REWRITE_TAC[POWER_0; I_THM]; ALL_TAC]
       THEN FIRST_X_ASSUM (MP_TAC o SPEC `1` o check (is_forall o concl))
       THEN POP_ASSUM (ASSUME_TAC o REWRITE_RULE[GSYM LT_NZ; GSYM LT1_NZ])
       THEN POP_ASSUM (fun th -> REWRITE_TAC[th; POWER_1])
       THEN USE_THEN "F5" (fun th -> SIMP_TAC[th]); ALL_TAC]  
   THEN ASM_CASES_TAC `k:num = 0`
   THENL[UNDISCH_TAC `y:A = ((next (L:(A)loop)) POWER (k:num)) (z:A)`
       THEN POP_ASSUM SUBST1_TAC
       THEN REWRITE_TAC[POWER_0; I_THM; EQ_SYM]; ALL_TAC]
   THEN FIRST_X_ASSUM (MP_TAC o SPEC `1` o check (is_forall o concl))
   THEN POP_ASSUM (ASSUME_TAC o REWRITE_RULE[GSYM LT_NZ; GSYM LT1_NZ])
   THEN POP_ASSUM (fun th -> REWRITE_TAC[th; POWER_1])
   THEN USE_THEN "F10" (fun th -> SIMP_TAC[th]));;

let lemma_unique_tail = prove(`!(H:(A)hypermap) (NF:(A)loop->bool) (L:(A)loop) (x:A) (y:A). is_normal H NF /\ L IN NF /\ x inside L /\ y IN atom H L x /\ ~(y = inverse (node_map H) (back L y)) ==> tail H NF x = y`,
   REPEAT GEN_TAC
   THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F1") (CONJUNCTS_THEN2 (LABEL_TAC "F2") (CONJUNCTS_THEN2 (LABEL_TAC "F3") (CONJUNCTS_THEN2 (LABEL_TAC "F4")
(LABEL_TAC "F5")))))
   THEN USE_THEN "F1" (MP_TAC o SPEC `L:(A)loop` o CONJUNCT1 o REWRITE_RULE[is_normal])
   THEN USE_THEN "F2" (fun th -> REWRITE_TAC[th])
   THEN DISCH_THEN (LABEL_TAC "F6" o CONJUNCT1)
   THEN USE_THEN "F1" (MP_TAC o CONJUNCT2 o SPEC `x:A` o MATCH_MP lemma_head_tail)
   THEN USE_THEN "F3" (fun th1 -> (USE_THEN "F2" (fun th2 -> REWRITE_TAC[MATCH_MP lemma_in_support2 (CONJ th1 th2)])))
   THEN DISCH_THEN (X_CHOOSE_THEN `L':(A)loop` (CONJUNCTS_THEN2 (LABEL_TAC "F7") (CONJUNCTS_THEN2 (LABEL_TAC "F8") (MP_TAC o CONJUNCT2 o CONJUNCT2))))
   THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F9") (LABEL_TAC "F10"))
   THEN USE_THEN "F1" (MP_TAC o SPECL[`L':(A)loop`; `L:(A)loop`; `x:A`] o CONJUNCT1 o CONJUNCT2 o CONJUNCT2 o  REWRITE_RULE[is_normal])
   THEN REMOVE_THEN "F8" (fun th -> REWRITE_TAC[th])
   THEN REMOVE_THEN "F7" (fun th -> REWRITE_TAC[th])
   THEN USE_THEN "F3" (fun th -> REWRITE_TAC[th])
   THEN USE_THEN "F2" (fun th -> REWRITE_TAC[th])
   THEN DISCH_THEN SUBST_ALL_TAC
   THEN ABBREV_TAC `z = tail (H:(A)hypermap) (NF:(A)loop->bool) (x:A)`
   THEN REMOVE_THEN "F4" (fun th2 -> (MP_TAC (MATCH_MP lemma_identity_atom th2)))
   THEN DISCH_THEN SUBST_ALL_TAC
   THEN REMOVE_THEN "F9" (MP_TAC o REWRITE_RULE[atom; IN_ELIM_THM; is_node_going])
   THEN STRIP_TAC
   THENL[ASM_CASES_TAC `k:num = 0`
       THENL[UNDISCH_TAC `z:A = ((next (L:(A)loop)) POWER (k:num)) (y:A)`
	   THEN POP_ASSUM SUBST1_TAC
	   THEN REWRITE_TAC[POWER_0; I_THM]; ALL_TAC]
       THEN FIND_ASSUM (MP_TAC o AP_TERM `back (L:(A)loop)`) `z:A = ((next (L:(A)loop)) POWER (k:num)) (y:A)`
       THEN POP_ASSUM (ASSUME_TAC o REWRITE_RULE[GSYM LT_NZ])
       THEN POP_ASSUM (fun th -> ONCE_REWRITE_TAC[MATCH_MP LT_SUC_PRE th] THEN ASSUME_TAC th)
       THEN REWRITE_TAC[COM_POWER; o_THM]
       THEN REWRITE_TAC[lemma_inverse_evaluation]
       THEN FIRST_ASSUM (MP_TAC o REWRITE_RULE[ARITH_RULE `PRE k <= k`] o SPEC `PRE k` o check (is_forall o concl))
       THEN DISCH_THEN (SUBST1_TAC)
       THEN DISCH_THEN (MP_TAC o AP_TERM `inverse (node_map (H:(A)hypermap))`)
       THEN REWRITE_TAC[iterate_map_valuation]
       THEN POP_ASSUM (fun th -> ONCE_REWRITE_TAC[SYM(MATCH_MP LT_SUC_PRE th)])
       THEN POP_ASSUM (MP_TAC o REWRITE_RULE[LE_REFL] o SPEC `k:num`)
       THEN DISCH_THEN (SUBST1_TAC o SYM)
       THEN POP_ASSUM (SUBST1_TAC o SYM)
       THEN USE_THEN "F10" (fun th -> REWRITE_TAC[GSYM th]); ALL_TAC]
   THEN ASM_CASES_TAC `k:num = 0`
   THENL[UNDISCH_TAC `y:A = ((next (L:(A)loop)) POWER (k:num)) (z:A)`
       THEN POP_ASSUM SUBST1_TAC
       THEN REWRITE_TAC[POWER_0; I_THM; EQ_SYM]; ALL_TAC]
   THEN FIND_ASSUM (MP_TAC o AP_TERM `back (L:(A)loop)`) `y:A = ((next (L:(A)loop)) POWER (k:num)) (z:A)`
   THEN POP_ASSUM (ASSUME_TAC o REWRITE_RULE[GSYM LT_NZ])
   THEN POP_ASSUM (fun th -> ONCE_REWRITE_TAC[MATCH_MP LT_SUC_PRE th] THEN ASSUME_TAC th)
   THEN REWRITE_TAC[COM_POWER; o_THM]
   THEN REWRITE_TAC[lemma_inverse_evaluation]
   THEN FIRST_ASSUM (MP_TAC o REWRITE_RULE[ARITH_RULE `PRE k <= k`] o SPEC `PRE k` o check (is_forall o concl))
   THEN DISCH_THEN (SUBST1_TAC)
   THEN DISCH_THEN (MP_TAC o AP_TERM `inverse (node_map (H:(A)hypermap))`)
   THEN REWRITE_TAC[iterate_map_valuation]
   THEN POP_ASSUM (fun th -> ONCE_REWRITE_TAC[SYM(MATCH_MP LT_SUC_PRE th)])
   THEN POP_ASSUM (MP_TAC o REWRITE_RULE[LE_REFL] o SPEC `k:num`)
   THEN DISCH_THEN (SUBST1_TAC o SYM)
   THEN POP_ASSUM (SUBST1_TAC o SYM)
   THEN USE_THEN "F5" (fun th -> REWRITE_TAC[GSYM th]));;

let head_on_loop = prove(`!(H:(A)hypermap) (NF:(A)loop->bool) (L:(A)loop) (x:A). is_normal H NF /\ L IN NF /\ x inside L 
   ==> head H NF x IN atom H L x /\ ~(next L (head H NF x) = inverse (node_map H) (head H NF x))`,
 REPEAT GEN_TAC
   THEN DISCH_THEN (LABEL_TAC "FC")
   THEN USE_THEN "FC" (CONJUNCTS_THEN2 (LABEL_TAC "F1") (CONJUNCTS_THEN2 (LABEL_TAC "F2") (LABEL_TAC "F3")))
   THEN USE_THEN "F2"(fun th -> (USE_THEN "F3"(fun th1-> ASSUME_TAC (MATCH_MP lemma_in_support2  (CONJ th1 th)))))
   THEN USE_THEN "F1"(fun th-> MP_TAC (CONJUNCT2(SPEC `x:A`(MATCH_MP lemma_head_tail th))))
   THEN POP_ASSUM (fun th -> REWRITE_TAC[th])
   THEN DISCH_THEN (X_CHOOSE_THEN `L':(A)loop` (CONJUNCTS_THEN2 (LABEL_TAC "F4") (CONJUNCTS_THEN2 (LABEL_TAC "F5") (CONJUNCTS_THEN2 (LABEL_TAC "F6") (LABEL_TAC "F7" o CONJUNCT1)))))
   THEN SUBGOAL_THEN `L':(A)loop = L:(A)loop` (SUBST_ALL_TAC)
   THENL[MATCH_MP_TAC disjoint_loops 
       THEN EXISTS_TAC `H:(A)hypermap` THEN EXISTS_TAC `NF:(A)loop->bool` THEN EXISTS_TAC `x:A`
       THEN ASM_REWRITE_TAC[]; ALL_TAC]
   THEN ASM_REWRITE_TAC[]);;

let tail_on_loop = prove(`!(H:(A)hypermap) (NF:(A)loop->bool) (L:(A)loop) (x:A). is_normal H NF /\ L IN NF /\ x inside L 
   ==> tail H NF x IN atom H L x /\ ~(tail H NF x = inverse (node_map H) (back L (tail H NF x)))`,
  REPEAT GEN_TAC
   THEN DISCH_THEN (LABEL_TAC "FC")
   THEN USE_THEN "FC" (CONJUNCTS_THEN2 (LABEL_TAC "F1") (CONJUNCTS_THEN2 (LABEL_TAC "F2") (LABEL_TAC "F3")))
   THEN USE_THEN "F2"(fun th -> (USE_THEN "F3"(fun th1-> ASSUME_TAC (MATCH_MP lemma_in_support2  (CONJ th1 th)))))
   THEN USE_THEN "F1"(fun th-> MP_TAC (CONJUNCT2(SPEC `x:A`(MATCH_MP lemma_head_tail th))))
   THEN POP_ASSUM (fun th -> REWRITE_TAC[th])
   THEN DISCH_THEN (X_CHOOSE_THEN `L':(A)loop` (CONJUNCTS_THEN2 (LABEL_TAC "F4") (CONJUNCTS_THEN2 (LABEL_TAC "F5") (MP_TAC o CONJUNCT2 o CONJUNCT2))))
   THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F6") (LABEL_TAC "F7"))
   THEN SUBGOAL_THEN `L':(A)loop = L:(A)loop` (SUBST_ALL_TAC)
   THENL[MATCH_MP_TAC disjoint_loops 
       THEN EXISTS_TAC `H:(A)hypermap` THEN EXISTS_TAC `NF:(A)loop->bool` THEN EXISTS_TAC `x:A`
       THEN ASM_REWRITE_TAC[]; ALL_TAC]
   THEN ASM_REWRITE_TAC[]);;

let lemma_map_next = prove(`!(H:(A)hypermap) (NF:(A)loop->bool) (L:(A)loop) (x:A). is_normal H NF /\ L IN NF /\ x inside L /\ next L x IN atom H L x 
   ==> next L x = inverse (node_map H) x`,			    
   REPEAT GEN_TAC
   THEN DISCH_THEN(CONJUNCTS_THEN2 (LABEL_TAC "F1") (CONJUNCTS_THEN2 (LABEL_TAC "F2") (CONJUNCTS_THEN2 (LABEL_TAC "F3") (LABEL_TAC "FC"))))
   THEN USE_THEN "F2" (fun th -> (USE_THEN "F1" (MP_TAC o REWRITE_RULE[th] o  SPEC `L:(A)loop` o  CONJUNCT1 o REWRITE_RULE[is_normal])))
   THEN DISCH_THEN (LABEL_TAC "F4" o CONJUNCT1)
   THEN USE_THEN "FC" (MP_TAC o REWRITE_RULE[atom; IN_ELIM_THM])
   THEN STRIP_TAC
   THENL[POP_ASSUM (MP_TAC o REWRITE_RULE[is_node_going])
       THEN DISCH_THEN  (X_CHOOSE_THEN `k:num` (CONJUNCTS_THEN2 (LABEL_TAC "F5") (LABEL_TAC "F6")))
       THEN ASM_CASES_TAC `k:num = 0`
       THENL[POP_ASSUM SUBST_ALL_TAC
	   THEN REMOVE_THEN "F5" (MP_TAC o REWRITE_RULE[POWER_0; I_THM])
	   THEN DISCH_THEN (ASSUME_TAC o ONCE_REWRITE_RULE[SPEC `next (L:(A)loop)` orbit_one_point])
	   THEN USE_THEN "F3"(fun th2->MP_TAC(MATCH_MP lemma_transitive_permutation th2))
	   THEN POP_ASSUM SUBST1_TAC
	   THEN DISCH_TAC
	   THEN SUBGOAL_THEN `dart_of (L:(A)loop) SUBSET node (H:(A)hypermap) (x:A)` MP_TAC
	   THENL[POP_ASSUM SUBST1_TAC
	      THEN REWRITE_TAC[SUBSET; IN_SING; node]
	      THEN GEN_TAC
	      THEN DISCH_THEN SUBST1_TAC THEN REWRITE_TAC[orbit_reflect]; ALL_TAC]
	   THEN USE_THEN "F1"(fun th->(USE_THEN "F2"(fun th1->REWRITE_TAC[MATCH_MP lemma_loop_outside_node (CONJ th th1)]))); ALL_TAC]
       THEN REMOVE_THEN "F6" (MP_TAC o REWRITE_RULE[POWER_1; LT1_NZ; LT_NZ ] o SPEC `1`)
       THEN POP_ASSUM (fun th-> REWRITE_TAC[th]); ALL_TAC]
   THEN POP_ASSUM (MP_TAC o REWRITE_RULE[is_node_going])
   THEN DISCH_THEN  (X_CHOOSE_THEN `k:num` (CONJUNCTS_THEN2 (LABEL_TAC "F5") (LABEL_TAC "F6")))
   THEN SUBGOAL_THEN `dart_of (L:(A)loop) SUBSET node (H:(A)hypermap) (x:A)` MP_TAC
   THENL[MP_TAC (SPECL[`H:(A)hypermap`; `L:(A)loop`; `x:A`]  lemma_atom_sub_node)
      THEN USE_THEN "FC"(fun th->(DISCH_THEN(fun th1->MP_TAC(MATCH_MP lemma_in_subset (CONJ th1 th)))))
      THEN DISCH_THEN(fun th->REWRITE_TAC[MATCH_MP lemma_node_identity th])
      THEN USE_THEN "F3" (fun th1-> (MP_TAC (SPEC `1` (MATCH_MP lemma_power_next_in_loop th1))))
      THEN REWRITE_TAC[POWER_1]
      THEN DISCH_THEN(fun th2->MP_TAC(MATCH_MP lemma_transitive_permutation th2))
      THEN DISCH_THEN SUBST1_TAC
      THEN REMOVE_THEN "F5" (MP_TAC o REWRITE_RULE[iterate_map_valuation] o SYM o AP_TERM `next (L:(A)loop)`)
      THEN DISCH_THEN (fun th-> MP_TAC (REWRITE_RULE[LT_SUC_LE] (MATCH_MP orbit_cyclic (CONJ (SPEC `k:num` NON_ZERO) th))))
      THEN POP_ASSUM (MP_TAC o MATCH_MP lemma_two_series_eq)
      THEN DISCH_THEN SUBST1_TAC
      THEN DISCH_THEN SUBST1_TAC
      THEN REWRITE_TAC[SUBSET; IN_ELIM_THM]
      THEN GEN_TAC
      THEN DISCH_THEN (X_CHOOSE_THEN `i:num` (SUBST1_TAC o CONJUNCT2))
      THEN MP_TAC (SPEC `i:num` (MATCH_MP power_inverse_element_lemma (SPEC `H:(A)hypermap` node_map_and_darts)))
      THEN DISCH_THEN (X_CHOOSE_THEN `j:num` (SUBST1_TAC))
      THEN REWRITE_TAC[node; lemma_in_orbit]; ALL_TAC]
   THEN USE_THEN "F1"(fun th->(USE_THEN "F2"(fun th1->REWRITE_TAC[MATCH_MP lemma_loop_outside_node (CONJ th th1)]))));;

let next_head_outside_atom =  prove(`!(H:(A)hypermap) (NF:(A)loop->bool) (L:(A)loop) (x:A). is_normal H NF /\ L IN NF /\ x inside L
   ==> ~((next L (head H NF x)) IN (atom H L x))`,
REPEAT GEN_TAC
   THEN DISCH_THEN (LABEL_TAC "FC")
   THEN USE_THEN "FC" (CONJUNCTS_THEN2 (LABEL_TAC "F1") (CONJUNCTS_THEN2 (LABEL_TAC "F2") (LABEL_TAC "F3")))
   THEN USE_THEN "F2" (fun th -> (USE_THEN "F1" (MP_TAC o REWRITE_RULE[th] o  SPEC `L:(A)loop` o  CONJUNCT1 o REWRITE_RULE[is_normal])))
   THEN DISCH_THEN (LABEL_TAC "F4" o CONJUNCT1)
   THEN USE_THEN "FC" ((CONJUNCTS_THEN2 (LABEL_TAC "F5") (MP_TAC)) o MATCH_MP head_on_loop)
   THEN REWRITE_TAC[CONTRAPOS_THM]
   THEN DISCH_TAC
   THEN MATCH_MP_TAC lemma_map_next
   THEN EXISTS_TAC `NF:(A)loop->bool`
   THEN ASM_REWRITE_TAC[]
   THEN STRIP_TAC
   THENL[MATCH_MP_TAC lemma_in_loop
        THEN EXISTS_TAC `H:(A)hypermap` THEN EXISTS_TAC `x:A`
	THEN ASM_REWRITE_TAC[]; ALL_TAC]
   THEN USE_THEN "F5" (fun th2 -> (ONCE_REWRITE_TAC[GSYM (MATCH_MP lemma_identity_atom th2)]))
   THEN POP_ASSUM (fun th2 -> (ONCE_REWRITE_TAC[MATCH_MP lemma_identity_atom th2]))
   THEN REWRITE_TAC[atom_reflect]);;

let value_next_of_head =  prove(`!(H:(A)hypermap) (NF:(A)loop->bool) (L:(A)loop) (x:A). is_normal H NF /\ L IN NF /\ x inside L  ==> next L (head H NF x) = face_map H (head H NF x)`,
   REPEAT GEN_TAC THEN DISCH_THEN (LABEL_TAC "FC")
   THEN USE_THEN "FC" (CONJUNCTS_THEN2 (LABEL_TAC "F1") (CONJUNCTS_THEN2 (LABEL_TAC "F2") (LABEL_TAC "F3")))
   THEN REMOVE_THEN "FC"(fun th-> (MP_TAC (MATCH_MP head_on_loop th )))
   THEN DISCH_THEN (CONJUNCTS_THEN2 MP_TAC ASSUME_TAC)
   THEN REMOVE_THEN "F3"(fun th->(DISCH_THEN(fun th1->ASSUME_TAC(MATCH_MP lemma_in_loop (CONJ th th1)))))
   THEN USE_THEN "F2" (fun th -> (USE_THEN "F1" (MP_TAC o REWRITE_RULE[th] o  SPEC `L:(A)loop` o  CONJUNCT1 o REWRITE_RULE[is_normal])))
   THEN DISCH_THEN (MP_TAC o SPEC `head (H:(A)hypermap) (NF:(A)loop->bool) (x:A)` o REWRITE_RULE[is_loop] o CONJUNCT1)
   THEN REWRITE_TAC[one_step_contour]
   THEN ASM_REWRITE_TAC[]);;

let back_tail_outside_atom = prove(`!(H:(A)hypermap) (NF:(A)loop->bool) (L:(A)loop) (x:A). is_normal H NF /\ L IN NF /\ x inside L ==> ~((back L (tail H NF x)) IN (atom H L x))`,
   REPEAT GEN_TAC
   THEN DISCH_THEN (LABEL_TAC "FC")
   THEN USE_THEN "FC" (CONJUNCTS_THEN2 (LABEL_TAC "F1") (CONJUNCTS_THEN2 (LABEL_TAC "F2") (LABEL_TAC "F3")))
   THEN USE_THEN "F2" (fun th -> (USE_THEN "F1" (MP_TAC o REWRITE_RULE[th] o  SPEC `L:(A)loop` o  CONJUNCT1 o REWRITE_RULE[is_normal])))
   THEN DISCH_THEN (LABEL_TAC "F4" o CONJUNCT1)
   THEN USE_THEN "FC" ((CONJUNCTS_THEN2 (LABEL_TAC "F5") (MP_TAC)) o MATCH_MP tail_on_loop)
   THEN REWRITE_TAC[CONTRAPOS_THM]
   THEN DISCH_TAC
   THEN ABBREV_TAC `y = back (L:(A)loop) (tail (H:(A)hypermap) (NF:(A)loop->bool) (x:A))`
   THEN POP_ASSUM (MP_TAC o AP_TERM `next (L:(A)loop)`)
   THEN ONCE_REWRITE_TAC[lemma_inverse_evaluation]
   THEN DISCH_THEN SUBST_ALL_TAC
   THEN MATCH_MP_TAC lemma_map_next
   THEN EXISTS_TAC `NF:(A)loop->bool`
   THEN POP_ASSUM (LABEL_TAC "F6")
   THEN USE_THEN "F6" (fun th2 -> (SUBST_ALL_TAC (SYM(MATCH_MP lemma_identity_atom th2))))
   THEN ASM_REWRITE_TAC[]
   THEN MATCH_MP_TAC lemma_in_loop
   THEN EXISTS_TAC `H:(A)hypermap` THEN EXISTS_TAC `x:A` THEN ASM_REWRITE_TAC[]);; 

let face_map_on_margin =  prove(`!(H:(A)hypermap) (NF:(A)loop->bool) (L:(A)loop) (x:A). is_normal H NF /\ L IN NF /\ x inside L ==>
face_map H (head H NF x) inside L /\ inverse (face_map H) (tail H NF x) inside L /\ face_map H (head H NF x) = tail H NF (face_map H (head H NF x))
/\ inverse (face_map H) (tail H NF x) = head H NF (inverse (face_map H) (tail H NF x))`,
   REPEAT GEN_TAC
   THEN DISCH_THEN (LABEL_TAC "FC")
   THEN USE_THEN "FC" (CONJUNCTS_THEN2 (LABEL_TAC "F1") (CONJUNCTS_THEN2 (LABEL_TAC "F2") (LABEL_TAC "F3")))
   THEN USE_THEN "F2" (fun th -> (USE_THEN "F1" (MP_TAC o REWRITE_RULE[th] o  SPEC `L:(A)loop` o  CONJUNCT1 o REWRITE_RULE[is_normal])))
   THEN DISCH_THEN (LABEL_TAC "F4" o CONJUNCT1)
   THEN USE_THEN "FC" ((CONJUNCTS_THEN2 (LABEL_TAC "F5") (LABEL_TAC "F6")) o MATCH_MP head_on_loop)
   THEN ABBREV_TAC `y = head (H:(A)hypermap) (NF:(A)loop->bool) (x:A)`
   THEN USE_THEN "F3"(fun th2->(REMOVE_THEN "F5"(fun th3->LABEL_TAC "F8" (MATCH_MP lemma_in_loop (CONJ th2 th3)))))
   THEN USE_THEN "F8"(fun th-> (USE_THEN "F4"(MP_TAC o REWRITE_RULE[th; one_step_contour] o SPEC `y:A` o  REWRITE_RULE[is_loop])))
   THEN USE_THEN "F6" (fun th -> SIMP_TAC[th])
   THEN DISCH_THEN (SUBST1_TAC o SYM)
   THEN USE_THEN "F8" (fun th1-> (MP_TAC (SPEC `1` (MATCH_MP lemma_power_next_in_loop th1))))
   THEN REWRITE_TAC[POWER_1]
   THEN DISCH_THEN (fun th -> (REWRITE_TAC[th] THEN LABEL_TAC "F9" th))
   THEN SUBGOAL_THEN `next (L:(A)loop) (y:A) = tail (H:(A)hypermap) (NF:(A)loop->bool) (next L y)` (LABEL_TAC "F10")
   THENL[CONV_TAC SYM_CONV
       THEN MATCH_MP_TAC lemma_unique_tail
       THEN EXISTS_TAC `L:(A)loop`
       THEN ONCE_REWRITE_TAC[lemma_inverse_evaluation]
       THEN ASM_REWRITE_TAC[atom_reflect]; ALL_TAC]
   THEN REMOVE_THEN "F10" (SUBST1_TAC o SYM)
   THEN SIMP_TAC[]
   THEN USE_THEN "FC" ((CONJUNCTS_THEN2 (LABEL_TAC "F11") (LABEL_TAC "F12")) o MATCH_MP tail_on_loop)
   THEN ABBREV_TAC `z = tail (H:(A)hypermap) (NF:(A)loop->bool) (x:A)`
   THEN USE_THEN "F3"(fun th2->(REMOVE_THEN "F11"(fun th3->LABEL_TAC "F14" (MATCH_MP lemma_in_loop (CONJ th2 th3)))))
   THEN USE_THEN "F14" (fun th1-> (MP_TAC (SPEC `1` (MATCH_MP lemma_power_back_in_loop th1))))
   THEN REWRITE_TAC[POWER_1]
   THEN DISCH_THEN (LABEL_TAC "F15")
   THEN USE_THEN "F15"(fun th-> (USE_THEN "F4"(MP_TAC o REWRITE_RULE[th; one_step_contour] o SPEC `back (L:(A)loop) (z:A)` o  REWRITE_RULE[is_loop])))
   THEN ONCE_REWRITE_TAC[lemma_inverse_evaluation]
   THEN REWRITE_TAC[one_step_contour]
   THEN USE_THEN "F12" (fun th -> SIMP_TAC[th])
   THEN REWRITE_TAC[face_map_inverse_representation]
   THEN DISCH_THEN (SUBST1_TAC o SYM)
   THEN USE_THEN "F15" (fun th->REWRITE_TAC[th])
   THEN CONV_TAC SYM_CONV
   THEN MATCH_MP_TAC lemma_unique_head
   THEN EXISTS_TAC `L:(A)loop`
   THEN ONCE_REWRITE_TAC[lemma_inverse_evaluation]
   THEN ASM_REWRITE_TAC[atom_reflect]
  );;

let node_map_on_margin =  prove(`!(H:(A)hypermap) (NF:(A)loop->bool) (L:(A)loop) (x:A). is_normal H NF /\ L IN NF /\ x inside L ==> (?L':(A)loop. L' IN NF /\ node_map H (tail H NF x) inside L' /\ node_map H (tail H NF x) = head H NF (node_map H (tail H NF x)))
/\ (?P:(A)loop. P IN NF /\ inverse (node_map H) (head H NF x) inside P /\ inverse (node_map H) (head H NF x) = tail H NF (inverse (node_map H) (head H NF x)))`,
   REPEAT GEN_TAC
   THEN DISCH_THEN (LABEL_TAC "FC")
   THEN USE_THEN "FC" (CONJUNCTS_THEN2 (LABEL_TAC "F1") (CONJUNCTS_THEN2 (LABEL_TAC "F2") (LABEL_TAC "F3")))
   THEN USE_THEN "F2" (fun th -> (USE_THEN "F1" (MP_TAC o REWRITE_RULE[th] o  SPEC `L:(A)loop` o  CONJUNCT1 o REWRITE_RULE[is_normal])))
   THEN DISCH_THEN (LABEL_TAC "F4" o CONJUNCT1)
   THEN STRIP_TAC
   THENL[USE_THEN "FC" ((CONJUNCTS_THEN2 (LABEL_TAC "F5") (LABEL_TAC "F6")) o MATCH_MP tail_on_loop)
      THEN ABBREV_TAC `y = tail (H:(A)hypermap) (NF:(A)loop->bool) (x:A)`
      THEN USE_THEN "F3"(fun th2->(REMOVE_THEN "F5"(fun th3->LABEL_TAC "F8" (MATCH_MP lemma_in_loop (CONJ th2 th3)))))
      THEN USE_THEN "F8"(fun th1->(USE_THEN "F2"(fun th2->(MP_TAC (MATCH_MP lemma_in_support2 (CONJ th1 th2))))))
      THEN USE_THEN "F1"(fun th1->(DISCH_THEN(fun th2->(MP_TAC (SPEC `1` (MATCH_MP lemma_node_in_support2 (CONJ th1 th2)))))))
      THEN REWRITE_TAC[POWER_1; lemma_in_support]
      THEN DISCH_THEN (X_CHOOSE_THEN `L':(A)loop` (CONJUNCTS_THEN2 (LABEL_TAC "F9") (LABEL_TAC "F10")))
      THEN EXISTS_TAC `L':(A)loop`
      THEN ASM_REWRITE_TAC[]
      THEN CONV_TAC SYM_CONV
      THEN MATCH_MP_TAC lemma_unique_head
      THEN EXISTS_TAC `L':(A)loop`
      THEN ASM_REWRITE_TAC[atom_reflect]
      THEN REMOVE_THEN "F6" MP_TAC
      THEN REWRITE_TAC[CONTRAPOS_THM]
      THEN REWRITE_TAC[MATCH_MP PERMUTES_INVERSES (CONJUNCT2(SPEC `H:(A)hypermap` node_map_and_darts))]
      THEN DISCH_TAC
      THEN USE_THEN "F10" (fun th1-> (MP_TAC (SPEC `1` (MATCH_MP lemma_power_next_in_loop th1))))
      THEN REWRITE_TAC[POWER_1]
      THEN POP_ASSUM (fun th ->  SUBST1_TAC th THEN LABEL_TAC "F11" th)
      THEN DISCH_TAC
      THEN SUBGOAL_THEN `L':(A)loop = L:(A)loop` SUBST_ALL_TAC
      THENL[MATCH_MP_TAC disjoint_loops
         THEN EXISTS_TAC `H:(A)hypermap` THEN EXISTS_TAC `NF:(A)loop->bool` THEN EXISTS_TAC `y:A`
         THEN ASM_REWRITE_TAC[]; ALL_TAC]
      THEN REMOVE_THEN "F11" (MP_TAC o AP_TERM `back (L:(A)loop)`)
      THEN ONCE_REWRITE_TAC[lemma_inverse_evaluation]
      THEN REWRITE_TAC[GSYM node_map_inverse_representation]
      THEN MESON_TAC[EQ_SYM]; ALL_TAC]
   THEN USE_THEN "FC" ((CONJUNCTS_THEN2 (LABEL_TAC "F15") (LABEL_TAC "F16")) o MATCH_MP head_on_loop)
   THEN ABBREV_TAC `y = head (H:(A)hypermap) (NF:(A)loop->bool) (x:A)`
   THEN USE_THEN "F3"(fun th2->(REMOVE_THEN "F15"(fun th3->LABEL_TAC "F17" (MATCH_MP lemma_in_loop (CONJ th2 th3)))))
   THEN USE_THEN "F17"(fun th1->(USE_THEN "F2"(fun th2->(MP_TAC (MATCH_MP lemma_in_support2 (CONJ th1 th2))))))
   THEN MP_TAC (MATCH_MP inverse_element_lemma (SPEC `H:(A)hypermap` node_map_and_darts))
   THEN DISCH_THEN (X_CHOOSE_THEN `j:num` ASSUME_TAC)
   THEN USE_THEN "F1"(fun th1->(DISCH_THEN(fun th2->(MP_TAC (SPEC `j:num` (MATCH_MP lemma_node_in_support2 (CONJ th1 th2)))))))
   THEN POP_ASSUM (SUBST1_TAC o SYM)
   THEN REWRITE_TAC[lemma_in_support]
   THEN DISCH_THEN (X_CHOOSE_THEN `P:(A)loop` (CONJUNCTS_THEN2 (LABEL_TAC "F18") (LABEL_TAC "F19")))
   THEN EXISTS_TAC `P:(A)loop`
   THEN ASM_REWRITE_TAC[]
   THEN CONV_TAC SYM_CONV
   THEN MATCH_MP_TAC lemma_unique_tail
   THEN EXISTS_TAC `P:(A)loop`
   THEN ASM_REWRITE_TAC[atom_reflect]
   THEN REMOVE_THEN "F16" MP_TAC
   THEN REWRITE_TAC[CONTRAPOS_THM]
   THEN DISCH_THEN (MP_TAC o AP_TERM `node_map (H:(A)hypermap)`)
   THEN REWRITE_TAC[MATCH_MP PERMUTES_INVERSES (CONJUNCT2(SPEC `H:(A)hypermap` node_map_and_darts))]
   THEN DISCH_THEN (MP_TAC o AP_TERM `next (P:(A)loop)`)
   THEN REWRITE_TAC[lemma_inverse_evaluation]
   THEN DISCH_THEN (SUBST_ALL_TAC o SYM)
   THEN REMOVE_THEN "F19" (fun th1-> (MP_TAC (SPEC `1` (MATCH_MP lemma_power_back_in_loop th1))))
   THEN REWRITE_TAC[POWER_1]
   THEN REWRITE_TAC[lemma_inverse_evaluation]
   THEN DISCH_TAC
   THEN SUBGOAL_THEN `L:(A)loop = P:(A)loop` SUBST1_TAC
   THENL[MATCH_MP_TAC disjoint_loops
       THEN EXISTS_TAC `H:(A)hypermap` THEN EXISTS_TAC `NF:(A)loop->bool` THEN EXISTS_TAC `y:A`
       THEN ASM_REWRITE_TAC[]; ALL_TAC]
   THEN SIMP_TAC[]);;

let node_map_free_loop =  prove(`!(H:(A)hypermap) (NF:(A)loop->bool) (L:(A)loop) (x:A). is_normal H NF /\ L IN NF /\ x inside L ==> node_map H (tail H NF x) = head H NF (node_map H (tail H NF x)) /\ inverse (node_map H) (head H NF x) = tail H NF (inverse (node_map H) (head H NF x))`,
   MESON_TAC[node_map_on_margin]);;


let from_tail = prove(`!(H:(A)hypermap) (NF:(A)loop->bool) (L:(A)loop) (x:A) (y:A). is_normal H NF /\ L IN NF /\ x inside L /\ y IN atom H L x 
   ==> is_node_going H L (tail H NF x) y`,
   REPEAT GEN_TAC
   THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F1") (CONJUNCTS_THEN2 (LABEL_TAC "F2") (CONJUNCTS_THEN2 (LABEL_TAC "F3") (LABEL_TAC "F4"))))
   THEN USE_THEN "F1"(fun th->(USE_THEN "F2"(fun th2->(USE_THEN "F3"(fun th3-> MP_TAC (MATCH_MP tail_on_loop (CONJ th (CONJ th2 th3))))))))
   THEN DISCH_THEN (LABEL_TAC "F5" o CONJUNCT1)
   THEN USE_THEN "F1"(fun th->(USE_THEN "F2"(fun th2->(USE_THEN "F3"(fun th3->LABEL_TAC "F6"(MATCH_MP back_tail_outside_atom(CONJ th (CONJ th2 th3))))))))
   THEN USE_THEN "F2" (fun th -> (USE_THEN "F1" (MP_TAC o REWRITE_RULE[th] o  SPEC `L:(A)loop` o  CONJUNCT1 o REWRITE_RULE[is_normal])))
   THEN DISCH_THEN (LABEL_TAC "F7" o CONJUNCT1)
   THEN ABBREV_TAC `z = tail (H:(A)hypermap) (NF:(A)loop->bool) (x:A)`
   THEN REMOVE_THEN "F5" (fun th1-> (MP_TAC (MATCH_MP lemma_identity_atom th1)))
   THEN DISCH_THEN SUBST_ALL_TAC
   THEN USE_THEN "F4" (MP_TAC o REWRITE_RULE[atom; IN_ELIM_THM])
   THEN STRIP_TAC
   THEN POP_ASSUM (MP_TAC o REWRITE_RULE[is_node_going])
   THEN DISCH_THEN(X_CHOOSE_THEN `k:num` (CONJUNCTS_THEN2 (LABEL_TAC "G1") (LABEL_TAC "G2")))
   THEN ASM_CASES_TAC `k:num = 0`
   THENL[POP_ASSUM SUBST_ALL_TAC
      THEN REMOVE_THEN "G1" (MP_TAC o REWRITE_RULE[POWER_0; I_THM])
      THEN DISCH_THEN SUBST1_TAC
      THEN REWRITE_TAC[is_node_going]
      THEN EXISTS_TAC `0`
      THEN REWRITE_TAC[POWER_0; I_THM; LE]
      THEN GEN_TAC THEN DISCH_THEN SUBST1_TAC THEN REWRITE_TAC[POWER_0; I_THM]; ALL_TAC]
   THEN POP_ASSUM(ASSUME_TAC o REWRITE_RULE[GSYM LT_NZ])
   THEN POP_ASSUM (MP_TAC o MATCH_MP LT_SUC_PRE)
   THEN ABBREV_TAC `m = PRE k`
   THEN DISCH_THEN (SUBST_ALL_TAC)
   THEN REMOVE_THEN "G1" (MP_TAC o REWRITE_RULE[o_THM] o AP_TERM `back (L:(A)loop)` o  REWRITE_RULE[COM_POWER])
   THEN REWRITE_TAC[lemma_inverse_evaluation]
   THEN DISCH_TAC
   THEN SUBGOAL_THEN `back (L:(A)loop) (z:A) IN atom (H:(A)hypermap) L z` MP_TAC
   THENL[ USE_THEN "F4" (fun th1 -> REWRITE_TAC[MATCH_MP lemma_identity_atom th1])
       THEN REWRITE_TAC[atom; IN_ELIM_THM]
       THEN DISJ1_TAC
       THEN REWRITE_TAC[is_node_going]
       THEN EXISTS_TAC `m:num`
       THEN USE_THEN "G2" (fun th -> REWRITE_TAC[REWRITE_RULE[lemma_add_one_assumption] th])
       THEN POP_ASSUM (fun th -> REWRITE_TAC[th]); ALL_TAC]
   THEN USE_THEN "F6" (fun th -> REWRITE_TAC[th])
  );;

let to_head = prove(`!(H:(A)hypermap) (NF:(A)loop->bool) (L:(A)loop) (x:A) (y:A). is_normal H NF /\ L IN NF /\ x inside L /\ y IN atom H L x 
   ==> is_node_going H L y (head H NF x)`,
   REPEAT GEN_TAC
   THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F1") (CONJUNCTS_THEN2 (LABEL_TAC "F2") (CONJUNCTS_THEN2 (LABEL_TAC "F3") (LABEL_TAC "F4"))))
   THEN USE_THEN "F1"(fun th->(USE_THEN "F2"(fun th2->(USE_THEN "F3"(fun th3-> MP_TAC (MATCH_MP head_on_loop (CONJ th (CONJ th2 th3))))))))
   THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F5") (LABEL_TAC "FF"))
   THEN USE_THEN "F2" (fun th -> (USE_THEN "F1" (MP_TAC o REWRITE_RULE[th] o  SPEC `L:(A)loop` o  CONJUNCT1 o REWRITE_RULE[is_normal])))
   THEN DISCH_THEN (LABEL_TAC "F6" o CONJUNCT1)
   THEN ABBREV_TAC `z = head (H:(A)hypermap) (NF:(A)loop->bool) (x:A)`
   THEN REMOVE_THEN "F5" (fun th1-> (MP_TAC (MATCH_MP lemma_identity_atom th1)))
   THEN DISCH_THEN SUBST_ALL_TAC
   THEN USE_THEN "F4" (MP_TAC o REWRITE_RULE[atom; IN_ELIM_THM])
   THEN STRIP_TAC
   THEN POP_ASSUM (MP_TAC o REWRITE_RULE[is_node_going])
   THEN DISCH_THEN(X_CHOOSE_THEN `k:num` (CONJUNCTS_THEN2 (LABEL_TAC "G1") (LABEL_TAC "G2")))
   THEN ASM_CASES_TAC `k:num = 0`
   THENL[POP_ASSUM SUBST_ALL_TAC
      THEN REMOVE_THEN "G1" (MP_TAC o REWRITE_RULE[POWER_0; I_THM])
      THEN DISCH_THEN SUBST1_TAC
      THEN REWRITE_TAC[is_node_going]
      THEN EXISTS_TAC `0`
      THEN REWRITE_TAC[POWER_0; I_THM; LE]
      THEN GEN_TAC THEN DISCH_THEN SUBST1_TAC THEN REWRITE_TAC[POWER_0; I_THM]; ALL_TAC]
   THEN POP_ASSUM(ASSUME_TAC o REWRITE_RULE[GSYM LT_NZ])
   THEN REMOVE_THEN "G2" (MP_TAC o SPEC `1`)
   THEN POP_ASSUM (fun th -> REWRITE_TAC[REWRITE_RULE[GSYM LT_NZ; GSYM LT1_NZ] th])
   THEN REWRITE_TAC[POWER_1]
   THEN USE_THEN "FF" (fun th -> REWRITE_TAC[th]));;

let lemma_in_atom = prove(`!(H:(A)hypermap) (L:(A)loop) (x:A) (m:num). is_loop H L /\ (!i:num .i <= m ==> ((next L) POWER i) x = ((inverse (node_map H)) POWER i) x)  ==> ((next L) POWER m) x IN atom H L x`,
    REPEAT GEN_TAC
    THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F1") (LABEL_TAC "F3"))
    THEN ASM_CASES_TAC `~(x:A inside L:(A)loop)`
    THENL[POP_ASSUM (fun th -> REWRITE_TAC[MATCH_MP lemma_power_back_and_next_outside_loop th])
        THEN REWRITE_TAC[atom_reflect]; ALL_TAC]
    THEN POP_ASSUM (LABEL_TAC "F2" o REWRITE_RULE[])
    THEN ABBREV_TAC `y = ((next (L:(A)loop)) POWER (m:num)) (x:A)`
    THEN REWRITE_TAC[atom; IN_ELIM_THM]
    THEN DISJ1_TAC
    THEN REWRITE_TAC[is_node_going]
    THEN EXISTS_TAC `m:num`
    THEN ASM_SIMP_TAC[]);;

let atom_subset = prove(`!(H:(A)hypermap) (NF:(A)loop->bool) (L:(A)loop) (x:A) (m:num). is_normal H NF /\ L IN NF /\ x inside L /\ 
head H NF x = ((next L ) POWER m) (tail H NF x) ==> (atom H L x) SUBSET {((next L) POWER (i:num)) (tail H NF x) | i <= m}`,
   REPEAT GEN_TAC
   THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F1") (CONJUNCTS_THEN2 (LABEL_TAC "F2") (CONJUNCTS_THEN2 (LABEL_TAC "F3") (LABEL_TAC "F4"))))
   THEN REWRITE_TAC[SUBSET]
   THEN GEN_TAC
   THEN USE_THEN "F3" MP_TAC
   THEN USE_THEN "F2" MP_TAC
   THEN USE_THEN "F1" MP_TAC
   THEN REWRITE_TAC[IMP_IMP; GSYM CONJ_ASSOC]
   THEN DISCH_THEN (MP_TAC o MATCH_MP from_tail)
   THEN REWRITE_TAC[is_node_going]
   THEN DISCH_THEN (X_CHOOSE_THEN `k:num` (CONJUNCTS_THEN2 SUBST1_TAC (LABEL_TAC "F5")))
   THEN ABBREV_TAC `h = head (H:(A)hypermap) (NF:(A)loop->bool) (x:A)`
   THEN ABBREV_TAC `t = tail (H:(A)hypermap) (NF:(A)loop->bool) (x:A)`
   THEN ASM_CASES_TAC `k:num <= m:num`
   THENL[REWRITE_TAC[IN_ELIM_THM]
      THEN EXISTS_TAC `k:num`
      THEN POP_ASSUM (fun th -> REWRITE_TAC[th]); ALL_TAC]
   THEN POP_ASSUM (ASSUME_TAC o REWRITE_RULE[NOT_LE; GSYM LE_SUC_LT])
   THEN SUBGOAL_THEN `next (L:(A)loop) (h:A)  IN atom (H:(A)hypermap) L (x:A)` MP_TAC
   THENL[USE_THEN "F2" (fun th -> (USE_THEN "F1" (MP_TAC o REWRITE_RULE[th] o  SPEC `L:(A)loop` o  CONJUNCT1 o REWRITE_RULE[is_normal])))
      THEN DISCH_THEN (LABEL_TAC "F6" o CONJUNCT1)
      THEN USE_THEN "F1"(fun th->(USE_THEN "F2"(fun th1->USE_THEN "F3"(fun th2->(MP_TAC (MATCH_MP tail_on_loop (CONJ th (CONJ th1 th2))))))))
      THEN FIND_ASSUM (fun th -> REWRITE_TAC[th])  `tail (H:(A)hypermap) (NF:(A)loop->bool) (x:A) = t:A`
      THEN DISCH_THEN(fun th1 -> MP_TAC (MATCH_MP lemma_identity_atom (CONJUNCT1 th1)))
      THEN DISCH_THEN SUBST1_TAC
      THEN USE_THEN "F4" SUBST1_TAC
      THEN REWRITE_TAC[iterate_map_valuation]
      THEN MATCH_MP_TAC lemma_in_atom
      THEN POP_ASSUM (fun th -> REWRITE_TAC[th])
      THEN GEN_TAC THEN POP_ASSUM MP_TAC THEN ONCE_REWRITE_TAC[IMP_IMP]
      THEN ONCE_REWRITE_TAC[CONJ_SYM] THEN DISCH_THEN (ASSUME_TAC o MATCH_MP LE_TRANS)
      THEN USE_THEN "F5" (MP_TAC o SPEC `i:num`)
      THEN POP_ASSUM (fun th -> REWRITE_TAC[th]); ALL_TAC]
   THEN USE_THEN "F1"(fun th->(USE_THEN "F2"(fun th1->USE_THEN "F3"(fun th2->(MP_TAC (MATCH_MP next_head_outside_atom (CONJ th (CONJ th1 th2))))))))
   THEN FIND_ASSUM (fun th -> REWRITE_TAC[th])  `head (H:(A)hypermap) (NF:(A)loop->bool) (x:A) = h:A`
   THEN SIMP_TAC[]);;

let atom_one_point = prove(`!(H:(A)hypermap) (NF:(A)loop->bool) (L:(A)loop) (x:A). is_normal H NF /\ L IN NF /\ x inside L /\ head H NF x = tail H NF x ==> atom H L x = {x}`,
  REPEAT GEN_TAC
   THEN SUBGOAL_THEN `tail (H:(A)hypermap) (NF:(A)loop->bool) x = (next L POWER 0) (tail (H:(A)hypermap) (NF:(A)loop->bool) x)` SUBST1_TAC
   THENL[REWRITE_TAC[POWER_0; I_THM]; ALL_TAC]
   THEN DISCH_THEN (MP_TAC o MATCH_MP atom_subset)
   THEN SUBGOAL_THEN `!p:A->A y:A. {(p POWER i) y | i = 0} = {y}` ASSUME_TAC
   THENL[SET_TAC[POWER_0; I_THM]; ALL_TAC]
   THEN POP_ASSUM (fun th-> REWRITE_TAC[LE; th])
   THEN DISCH_THEN (LABEL_TAC "F1")
   THEN LABEL_TAC "F2" (SPECL[`H:(A)hypermap`; `L:(A)loop`; `x:A`] atom_reflect)
   THEN USE_THEN "F1" (fun th-> (USE_THEN "F2" (fun th1->MP_TAC(MATCH_MP lemma_in_subset (CONJ th th1)))))
   THEN REWRITE_TAC[IN_SING]
   THEN DISCH_THEN (SUBST_ALL_TAC o SYM)
   THEN SET_TAC[]);;

let atom_eq =  prove(`!(H:(A)hypermap) (NF:(A)loop->bool) (L:(A)loop) (x:A) (m:num). is_normal H NF /\ L IN NF /\ x inside L /\ 
head H NF x = ((next L ) POWER m) (tail H NF x) /\ (!i:num. i <= m ==> ((next L ) POWER i) (tail H NF x) = (inverse (node_map H)  POWER i) (tail H NF x)) ==> (atom H L x) = {((next L) POWER (i:num)) (tail H NF x) | i <= m}`,
    REPEAT GEN_TAC
    THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F1") (CONJUNCTS_THEN2 (LABEL_TAC "F2") (CONJUNCTS_THEN2 (LABEL_TAC "F3") STRIP_ASSUME_TAC)))
    THEN MATCH_MP_TAC SUBSET_ANTISYM
    THEN STRIP_TAC
    THENL[MATCH_MP_TAC atom_subset THEN ASM_REWRITE_TAC[]; ALL_TAC]
    THEN REWRITE_TAC[SUBSET; IN_ELIM_THM]
    THEN GEN_TAC
    THEN DISCH_THEN (X_CHOOSE_THEN `i:num` (CONJUNCTS_THEN2 (ASSUME_TAC) (SUBST1_TAC)))
    THEN USE_THEN "F1"(fun th->(USE_THEN "F2"(fun th1->USE_THEN "F3"(fun th2->(MP_TAC (CONJUNCT1 (MATCH_MP tail_on_loop (CONJ th (CONJ th1 th2)))))))))
    THEN USE_THEN "F2" (fun th -> (USE_THEN "F1" (MP_TAC o REWRITE_RULE[th] o  SPEC `L:(A)loop` o  CONJUNCT1 o REWRITE_RULE[is_normal])))
    THEN DISCH_THEN (MP_TAC o CONJUNCT1)
    THEN REWRITE_TAC[IMP_IMP]
    THEN DISCH_THEN (fun th -> MP_TAC (MATCH_MP lemma_identity_atom (CONJUNCT2 th)) THEN ASSUME_TAC (CONJUNCT1 th))
    THEN ABBREV_TAC `y = tail (H:(A)hypermap) (NF:(A)loop->bool) (x:A)`
    THEN DISCH_THEN SUBST1_TAC
    THEN MATCH_MP_TAC lemma_in_atom
    THEN ASM_REWRITE_TAC[]
    THEN GEN_TAC
    THEN UNDISCH_TAC `i:num <= m:num`
    THEN REWRITE_TAC[IMP_IMP]
    THEN ONCE_REWRITE_TAC[CONJ_SYM]
    THEN DISCH_THEN (ASSUME_TAC o MATCH_MP LE_TRANS)
    THEN FIRST_X_ASSUM (MP_TAC o SPEC `i':num`)
    THEN POP_ASSUM (fun th -> REWRITE_TAC[th]));;

let change_to_margin = prove( `!(H:(A)hypermap) (NF:(A)loop->bool) (x:A) (L:(A)loop). is_normal H NF /\ L IN NF /\ x inside L
                               ==> atom H L x = atom H L (tail H NF x) /\ atom H L x = atom H L (head H NF x)`,
 REPEAT GEN_TAC
   THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F1") (CONJUNCTS_THEN2 (LABEL_TAC "F2") (LABEL_TAC "F3")))
   THEN USE_THEN "F1"(fun th->(USE_THEN "F2"(fun th1->(USE_THEN "F3"(fun th2->MP_TAC(CONJUNCT1(MATCH_MP head_on_loop (CONJ th (CONJ th1 th2)))))))))
   THEN DISCH_THEN(fun th1->MP_TAC(MATCH_MP lemma_identity_atom th1))
   THEN USE_THEN "F1"(fun th->(USE_THEN "F2"(fun th1->(USE_THEN "F3"(fun th2->MP_TAC(CONJUNCT1(MATCH_MP tail_on_loop (CONJ th (CONJ th1 th2)))))))))
   THEN DISCH_THEN(fun th1->MP_TAC(MATCH_MP lemma_identity_atom th1))
   THEN MESON_TAC[]);;

let change_parameters = prove(`!(H:(A)hypermap) (NF:(A)loop->bool) (L:(A)loop) (x:A) (y:A). is_normal H NF /\ L IN NF /\ x inside L /\ y IN atom H L x
    ==> head H NF y = head H NF x /\ tail H NF y = tail H NF x`,
   REPEAT GEN_TAC
   THEN DISCH_THEN (LABEL_TAC "FC")
   THEN USE_THEN "FC" (CONJUNCTS_THEN2 (LABEL_TAC "F1") (CONJUNCTS_THEN2 (LABEL_TAC "F2")(CONJUNCTS_THEN2 (LABEL_TAC "F3") (LABEL_TAC "F4"))))
   THEN USE_THEN "F3"(fun th2->(USE_THEN "F4"(fun th3->LABEL_TAC "F6"(MATCH_MP lemma_in_loop (CONJ th2 th3)))))
   THEN USE_THEN "F4"(fun th1->(LABEL_TAC "F7"(MATCH_MP lemma_identity_atom th1)))
   THEN STRIP_TAC
   THENL[MATCH_MP_TAC lemma_unique_head
      THEN EXISTS_TAC `L:(A)loop`
      THEN ASM_REWRITE_TAC[]
      THEN POP_ASSUM (SUBST1_TAC o SYM)
      THEN USE_THEN "F1"(fun th->(USE_THEN "F2"(fun th1->(USE_THEN "F3"(fun th2-> REWRITE_TAC[MATCH_MP head_on_loop (CONJ th(CONJ th1 th2))])))))
      ; ALL_TAC]
   THEN MATCH_MP_TAC lemma_unique_tail
   THEN EXISTS_TAC `L:(A)loop`
   THEN ASM_REWRITE_TAC[]
   THEN POP_ASSUM (SUBST1_TAC o SYM)
   THEN USE_THEN "F1"(fun th->(USE_THEN "F2"(fun th1->(USE_THEN "F3"(fun th2-> REWRITE_TAC[MATCH_MP tail_on_loop (CONJ th(CONJ th1 th2))]))))));;

let lemma_map_next = prove(`!(H:(A)hypermap) (NF:(A)loop->bool) (L:(A)loop) (x:A). is_normal H NF /\ L IN NF /\ x inside L /\ next L x IN atom H L x 
   ==> next L x = inverse (node_map H) x`,
   REPEAT GEN_TAC
   THEN DISCH_THEN(CONJUNCTS_THEN2 (LABEL_TAC "F1") (CONJUNCTS_THEN2 (LABEL_TAC "F2") (CONJUNCTS_THEN2 (LABEL_TAC "F3") (LABEL_TAC "FC"))))
   THEN USE_THEN "F2" (fun th -> (USE_THEN "F1" (MP_TAC o REWRITE_RULE[th] o  SPEC `L:(A)loop` o  CONJUNCT1 o REWRITE_RULE[is_normal])))
   THEN DISCH_THEN (LABEL_TAC "F4" o CONJUNCT1)
   THEN USE_THEN "FC" (MP_TAC o REWRITE_RULE[atom; IN_ELIM_THM])
   THEN STRIP_TAC
   THENL[POP_ASSUM (MP_TAC o REWRITE_RULE[is_node_going])
       THEN DISCH_THEN  (X_CHOOSE_THEN `k:num` (CONJUNCTS_THEN2 (LABEL_TAC "F5") (LABEL_TAC "F6")))
       THEN ASM_CASES_TAC `k:num = 0`
       THENL[POP_ASSUM SUBST_ALL_TAC
	   THEN REMOVE_THEN "F5" (MP_TAC o REWRITE_RULE[POWER_0; I_THM])
	   THEN DISCH_THEN (ASSUME_TAC o ONCE_REWRITE_RULE[SPEC `next (L:(A)loop)` orbit_one_point])
	   THEN USE_THEN "F3"(fun th2->MP_TAC(MATCH_MP lemma_transitive_permutation th2))
	   THEN POP_ASSUM SUBST1_TAC
	   THEN DISCH_TAC
	   THEN SUBGOAL_THEN `dart_of (L:(A)loop) SUBSET node (H:(A)hypermap) (x:A)` MP_TAC
	   THENL[POP_ASSUM SUBST1_TAC
	      THEN REWRITE_TAC[SUBSET; IN_SING; node]
	      THEN GEN_TAC
	      THEN DISCH_THEN SUBST1_TAC THEN REWRITE_TAC[orbit_reflect]; ALL_TAC]
	   THEN USE_THEN "F1"(fun th->(USE_THEN "F2"(fun th1->REWRITE_TAC[MATCH_MP lemma_loop_outside_node (CONJ th th1)]))); ALL_TAC]
       THEN REMOVE_THEN "F6" (MP_TAC o REWRITE_RULE[POWER_1; LT1_NZ; LT_NZ ] o SPEC `1`)
       THEN POP_ASSUM (fun th-> REWRITE_TAC[th]); ALL_TAC]
   THEN POP_ASSUM (MP_TAC o REWRITE_RULE[is_node_going])
   THEN DISCH_THEN  (X_CHOOSE_THEN `k:num` (CONJUNCTS_THEN2 (LABEL_TAC "F5") (LABEL_TAC "F6")))
   THEN SUBGOAL_THEN `dart_of (L:(A)loop) SUBSET node (H:(A)hypermap) (x:A)` MP_TAC
   THENL[MP_TAC (SPECL[`H:(A)hypermap`; `L:(A)loop`; `x:A`]  lemma_atom_sub_node)
      THEN USE_THEN "FC"(fun th->(DISCH_THEN(fun th1->MP_TAC(MATCH_MP lemma_in_subset (CONJ th1 th)))))
      THEN DISCH_THEN(fun th->REWRITE_TAC[MATCH_MP lemma_node_identity th])
      THEN USE_THEN "F3" (fun th1-> (MP_TAC (SPEC `1` (MATCH_MP lemma_power_next_in_loop th1))))
      THEN REWRITE_TAC[POWER_1]
      THEN DISCH_THEN(fun th2->MP_TAC(MATCH_MP lemma_transitive_permutation th2))
      THEN DISCH_THEN SUBST1_TAC
      THEN REMOVE_THEN "F5" (MP_TAC o REWRITE_RULE[iterate_map_valuation] o SYM o AP_TERM `next (L:(A)loop)`)
      THEN DISCH_THEN (fun th-> MP_TAC (REWRITE_RULE[LT_SUC_LE] (MATCH_MP orbit_cyclic (CONJ (SPEC `k:num` NON_ZERO) th))))
      THEN POP_ASSUM (MP_TAC o MATCH_MP lemma_two_series_eq)
      THEN DISCH_THEN SUBST1_TAC
      THEN DISCH_THEN SUBST1_TAC
      THEN REWRITE_TAC[SUBSET; IN_ELIM_THM]
      THEN GEN_TAC
      THEN DISCH_THEN (X_CHOOSE_THEN `i:num` (SUBST1_TAC o CONJUNCT2))
      THEN MP_TAC (SPEC `i:num` (MATCH_MP power_inverse_element_lemma (SPEC `H:(A)hypermap` node_map_and_darts)))
      THEN DISCH_THEN (X_CHOOSE_THEN `j:num` (SUBST1_TAC))
      THEN REWRITE_TAC[node; lemma_in_orbit]; ALL_TAC]
   THEN USE_THEN "F1"(fun th->(USE_THEN "F2"(fun th1->REWRITE_TAC[MATCH_MP lemma_loop_outside_node (CONJ th th1)]))));;

let lemma_atom_node_eq =  prove(`!(H:(A)hypermap) (NF:(A)loop->bool) (x:A) (L:(A)loop). is_normal H NF /\ L IN NF /\ x inside L /\ node_map H (tail H NF x) IN (atom H L x) ==> atom H L x = node H x`,
  REPEAT GEN_TAC
   THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F1") (CONJUNCTS_THEN2 (LABEL_TAC "F2") (CONJUNCTS_THEN2 (LABEL_TAC "F3") (LABEL_TAC "F4"))))
   THEN USE_THEN "F1"(fun th->(USE_THEN "F2"(fun th1->(USE_THEN "F3"(fun th2-> LABEL_TAC "FC"(CONJUNCT1(MATCH_MP tail_on_loop (CONJ th(CONJ th1 th2)))))))))
   THEN  USE_THEN "F1" (MP_TAC o SPEC `L:(A)loop` o CONJUNCT1 o REWRITE_RULE[is_normal])
   THEN ASM_REWRITE_TAC[]
   THEN DISCH_THEN (LABEL_TAC "FA" o CONJUNCT1)
   THEN USE_THEN "FC"(fun th1->(LABEL_TAC "sa"(MATCH_MP lemma_identity_atom th1)))
   THEN MATCH_MP_TAC SUBSET_ANTISYM
   THEN REWRITE_TAC[lemma_atom_sub_node]
   THEN USE_THEN "F1"(fun th->(USE_THEN "F2"(fun th1->(USE_THEN "F3"(fun th2-> MP_TAC(CONJUNCT1(MATCH_MP head_on_loop (CONJ th(CONJ th1 th2)))))))))
   THEN USE_THEN "F3" MP_TAC
   THEN REWRITE_TAC[IMP_IMP]
   THEN USE_THEN "F1"(fun th->(USE_THEN "F2"(fun th1->(DISCH_THEN(fun th2-> MP_TAC(MATCH_MP from_tail (CONJ th(CONJ th1 th2))))))))
   THEN REWRITE_TAC[is_node_going]
   THEN DISCH_THEN (X_CHOOSE_THEN `m:num` (fun th -> (LABEL_TAC "F5" (CONJUNCT1 th) THEN LABEL_TAC "F6" (CONJUNCT2 th) THEN MP_TAC th)))
   THEN USE_THEN "F1"(fun th->(USE_THEN "F2"(fun th1->(USE_THEN "F3"(fun th2-> (DISCH_THEN (fun th3-> MP_TAC(MATCH_MP atom_eq (CONJ th(CONJ th1 (CONJ th2 th3)))))))))))
   THEN REMOVE_THEN "F6" (MP_TAC o MATCH_MP lemma_two_series_eq)
   THEN DISCH_THEN (fun th->GEN_REWRITE_TAC (LAND_CONV o ONCE_DEPTH_CONV) [th])
   THEN DISCH_THEN (LABEL_TAC "F7")
   THEN REMOVE_THEN "F4" MP_TAC
   THEN USE_THEN "F7" (fun th->GEN_REWRITE_TAC (LAND_CONV o ONCE_DEPTH_CONV) [th])
   THEN REWRITE_TAC[IN_ELIM_THM]
   THEN DISCH_THEN (X_CHOOSE_THEN `k:num` (CONJUNCTS_THEN2 (LABEL_TAC "F8") (MP_TAC o SYM)))
   THEN REWRITE_TAC[node_map_inverse_representation]
   THEN DISCH_THEN (fun th -> MP_TAC (REWRITE_RULE[iterate_map_valuation] (SYM th)))
   THEN DISCH_THEN (fun th -> (MP_TAC(MATCH_MP orbit_cyclic (CONJ (SPEC `k:num` NON_ZERO) th))))
   THEN REWRITE_TAC[LT_SUC_LE]
   THEN REWRITE_TAC[MATCH_MP lemma_card_inverse_map_eq (SPEC `H:(A)hypermap` node_map_and_darts); GSYM node]
   THEN DISCH_TAC
   THEN SUBGOAL_THEN `{((inverse (node_map (H:(A)hypermap))) POWER (k':num)) (tail H (NF:(A)loop->bool) (x:A)) | k' <= k:num}
SUBSET {((inverse (node_map H)) POWER (i:num)) (tail H (NF:(A)loop->bool) (x:A)) | i <= m:num}` MP_TAC
   THENL[REWRITE_TAC[SUBSET; IN_ELIM_THM]
      THEN GEN_TAC
      THEN DISCH_THEN (X_CHOOSE_THEN `l:num` (CONJUNCTS_THEN2 (ASSUME_TAC) (SUBST1_TAC)))
      THEN EXISTS_TAC `l:num`
      THEN POP_ASSUM(fun th->(USE_THEN "F8"(fun th1->REWRITE_TAC[MATCH_MP LE_TRANS (CONJ th th1)]))); ALL_TAC]
   THEN POP_ASSUM (SUBST1_TAC o SYM)
   THEN REMOVE_THEN "F7" (SUBST1_TAC o SYM)
   THEN ABBREV_TAC `y = tail (H:(A)hypermap) (NF:(A)loop->bool) (x:A)`
   THEN MP_TAC (SPECL[`H:(A)hypermap`; `L:(A)loop`; `y:A`] atom_reflect)
   THEN REMOVE_THEN "sa" (SUBST1_TAC o SYM)
   THEN DISCH_THEN (fun th-> (MP_TAC (MATCH_MP lemma_in_subset (CONJ (SPECL[`H:(A)hypermap`; `L:(A)loop`; `x:A`] lemma_atom_sub_node) th))))
   THEN DISCH_THEN(fun th -> REWRITE_TAC[MATCH_MP lemma_node_identity th]));;

let lemma_fmap = prove(`!(H:(A)hypermap) (NF:(A)loop->bool). ?f:(A->bool)->(A->bool). (!s:A->bool. is_normal H NF ==> 
(~(s IN quotient_darts H NF) ==> f s = s) /\ 
  (s IN quotient_darts H NF ==> (?L:(A)loop x:A. L IN NF /\ x inside L /\ s = atom H L x /\ f s = atom H L ((face_map H) (head H NF x)))))`,
   REPEAT GEN_TAC
   THEN REWRITE_TAC[GSYM SKOLEM_THM]
   THEN GEN_TAC
   THEN REWRITE_TAC[RIGHT_EXISTS_IMP_THM]
   THEN DISCH_THEN (LABEL_TAC "F1")
   THEN ASM_CASES_TAC `~((s:A->bool) IN quotient_darts (H:(A)hypermap) (NF:(A)loop->bool))`
   THENL[EXISTS_TAC `s:A->bool`  THEN ASM_REWRITE_TAC[]; ALL_TAC]
   THEN POP_ASSUM (ASSUME_TAC o REWRITE_RULE[])
   THEN ASM_REWRITE_TAC[]
   THEN POP_ASSUM (MP_TAC o REWRITE_RULE[quotient_darts; IN_ELIM_THM])
   THEN DISCH_THEN (X_CHOOSE_THEN `L:(A)loop` (X_CHOOSE_THEN `x:A` MP_TAC))
   THEN DISCH_THEN (CONJUNCTS_THEN2 (CONJUNCTS_THEN2 (LABEL_TAC "F2") (LABEL_TAC "F3")) (LABEL_TAC "F4"))
   THEN ASM_REWRITE_TAC[SWAP_EXISTS_THM]
   THEN EXISTS_TAC `x:A`
   THEN ONCE_REWRITE_TAC[SWAP_EXISTS_THM]
   THEN EXISTS_TAC `L:(A)loop`
   THEN EXISTS_TAC `atom (H:(A)hypermap) (L:(A)loop) (face_map H (head H NF (x:A)))`
   THEN ASM_REWRITE_TAC[]);;

let lemma_nmap = prove(`!(H:(A)hypermap) (NF:(A)loop->bool). ?f:(A->bool)->(A->bool). (!s:A->bool. is_normal H NF ==> 
(~(s IN quotient_darts H NF) ==> f s = s) /\ 
  (s IN quotient_darts H NF ==> (?L:(A)loop L':(A)loop x:A. L IN NF /\ L' IN NF /\ x inside L /\ node_map H (tail H NF x) inside L' /\ s = atom H L x /\
  f s = atom H L' ((node_map H) (tail H NF x)))))`,
 REPEAT GEN_TAC
   THEN REWRITE_TAC[GSYM SKOLEM_THM]
   THEN GEN_TAC
   THEN REWRITE_TAC[RIGHT_EXISTS_IMP_THM]
   THEN DISCH_THEN (LABEL_TAC "F1")
   THEN ASM_CASES_TAC `~((s:A->bool) IN quotient_darts (H:(A)hypermap) (NF:(A)loop->bool))`
   THENL[EXISTS_TAC `s:A->bool`  THEN ASM_REWRITE_TAC[]; ALL_TAC]
   THEN POP_ASSUM (ASSUME_TAC o REWRITE_RULE[])
   THEN ASM_REWRITE_TAC[]
   THEN POP_ASSUM (MP_TAC o REWRITE_RULE[quotient_darts; IN_ELIM_THM])
   THEN DISCH_THEN (X_CHOOSE_THEN `L:(A)loop` (X_CHOOSE_THEN `x:A` MP_TAC))
   THEN DISCH_THEN (CONJUNCTS_THEN2 (CONJUNCTS_THEN2 (LABEL_TAC "F2") (LABEL_TAC "F3")) (LABEL_TAC "F4"))
   THEN USE_THEN "F1"(fun th1->(USE_THEN "F2"(fun th2->USE_THEN "F3"(fun th3->MP_TAC (CONJUNCT1(MATCH_MP node_map_on_margin (CONJ th1 (CONJ th2 th3))))))))
   THEN DISCH_THEN (X_CHOOSE_THEN `L':(A)loop` (CONJUNCTS_THEN2 (LABEL_TAC "F2") (LABEL_TAC "F3" o CONJUNCT1)))
   THEN ASM_REWRITE_TAC[SWAP_EXISTS_THM]
   THEN EXISTS_TAC `x:A`
   THEN ONCE_REWRITE_TAC[SWAP_EXISTS_THM]
   THEN EXISTS_TAC `L:(A)loop`
   THEN ONCE_REWRITE_TAC[SWAP_EXISTS_THM]
   THEN EXISTS_TAC `L':(A)loop`
   THEN EXISTS_TAC `atom (H:(A)hypermap) (L':(A)loop) (node_map H (tail H NF (x:A)))`
   THEN ASM_REWRITE_TAC[]);;
		     
let lemma_face_map = new_specification ["fmap"] (REWRITE_RULE[SKOLEM_THM] lemma_fmap);;

let lemma_node_map = new_specification ["nmap"] (REWRITE_RULE[SKOLEM_THM] lemma_nmap);;

let unique_fmap = prove(`!(H:(A)hypermap) (NF:(A)loop->bool) L:(A)loop x:A. is_normal H NF /\ L IN NF /\ x inside L ==> fmap H NF (atom H L x) =  atom H L ((face_map H) (head H NF x))`,
   REPEAT GEN_TAC
   THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F1") (CONJUNCTS_THEN2 (LABEL_TAC "F2") (LABEL_TAC "F3")))
   THEN USE_THEN "F1" (MP_TAC o CONJUNCT2 o SPEC `atom (H:(A)hypermap) (L:(A)loop) (x:A)` o MATCH_MP lemma_face_map)
   THEN USE_THEN "F2" (fun th-> (USE_THEN "F3" (fun th1-> REWRITE_TAC[MATCH_MP lemma_in_quotient (CONJ th th1)])))
   THEN STRIP_TAC
   THEN SUBGOAL_THEN `L':(A)loop = L:(A)loop` SUBST_ALL_TAC
   THENL[MP_TAC(SPECL[`H:(A)hypermap`; `L':(A)loop`; `x':A`] atom_reflect)
       THEN UNDISCH_THEN `atom (H:(A)hypermap) (L:(A)loop) (x:A) = atom (H:(A)hypermap) (L':(A)loop) (x':A)` (SUBST1_TAC o SYM)
       THEN USE_THEN "F3"(fun th2->(DISCH_THEN(fun th3->ASSUME_TAC(MATCH_MP lemma_in_loop (CONJ th2 th3)))))
       THEN MATCH_MP_TAC disjoint_loops
       THEN EXISTS_TAC `H:(A)hypermap` THEN EXISTS_TAC `NF:(A)loop->bool` THEN EXISTS_TAC `x':A`
       THEN ASM_REWRITE_TAC[]; ALL_TAC]
   THEN POP_ASSUM MP_TAC
   THEN MP_TAC(SPECL[`H:(A)hypermap`; `L:(A)loop`; `x':A`] atom_reflect)
   THEN POP_ASSUM (SUBST1_TAC o SYM)
   THEN USE_THEN "F1"(fun th1->(USE_THEN "F2"(fun th2->(USE_THEN "F3"(fun th3->(DISCH_THEN(fun th4->MP_TAC(MATCH_MP change_parameters (CONJ th1 (CONJ th2 (CONJ th3 th4)))))))))))
   THEN DISCH_THEN (SUBST1_TAC o CONJUNCT1)
   THEN SIMP_TAC[]);;


let unique_nmap = prove(`!(H:(A)hypermap) (NF:(A)loop->bool) L:(A)loop L':(A)loop x:A. is_normal H NF /\ L IN NF /\ L' IN NF /\ x inside L /\ node_map H (tail H NF x) inside L' ==> nmap H NF (atom H L x) = atom H L' ((node_map H) (tail H NF x))`,
   REPEAT GEN_TAC
   THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F1") (CONJUNCTS_THEN2 (LABEL_TAC "F2") (CONJUNCTS_THEN2 (LABEL_TAC "F3") (CONJUNCTS_THEN2 (LABEL_TAC "F4") (LABEL_TAC "F5")))))
   THEN USE_THEN "F1" (MP_TAC o CONJUNCT2 o SPEC `atom (H:(A)hypermap) (L:(A)loop) (x:A)` o MATCH_MP lemma_node_map)
   THEN USE_THEN "F2" (fun th-> (USE_THEN "F4" (fun th1-> REWRITE_TAC[MATCH_MP lemma_in_quotient (CONJ th th1)])))
   THEN STRIP_TAC
   THEN SUBGOAL_THEN `L'':(A)loop = L:(A)loop` SUBST_ALL_TAC
   THENL[MP_TAC(SPECL[`H:(A)hypermap`; `L'':(A)loop`; `x':A`] atom_reflect)
      THEN UNDISCH_THEN `atom (H:(A)hypermap) (L:(A)loop) (x:A) = atom (H:(A)hypermap) (L'':(A)loop) (x':A)` (SUBST1_TAC o SYM)
      THEN USE_THEN "F4"(fun th2->(DISCH_THEN(fun th3->ASSUME_TAC(MATCH_MP lemma_in_loop (CONJ th2 th3)))))
      THEN MATCH_MP_TAC disjoint_loops
      THEN EXISTS_TAC `H:(A)hypermap` THEN EXISTS_TAC `NF:(A)loop->bool` THEN EXISTS_TAC `x':A`
      THEN ASM_REWRITE_TAC[]; ALL_TAC]
   THEN MP_TAC(SPECL[`H:(A)hypermap`; `L:(A)loop`; `x':A`] atom_reflect)
   THEN UNDISCH_THEN `atom (H:(A)hypermap) (L:(A)loop) (x:A) = atom (H:(A)hypermap) (L:(A)loop) (x':A)` (SUBST1_TAC o SYM)
   THEN USE_THEN "F1"(fun th1->(USE_THEN "F2"(fun th2->(USE_THEN "F4"(fun th3->(DISCH_THEN(fun th4->MP_TAC(MATCH_MP change_parameters (CONJ th1 (CONJ th2 (CONJ th3 th4)))))))))))
   THEN DISCH_THEN (ASSUME_TAC o CONJUNCT2)
   THEN SUBGOAL_THEN `L''':(A)loop = L':(A)loop` SUBST_ALL_TAC
   THENL[MATCH_MP_TAC disjoint_loops
      THEN EXISTS_TAC `H:(A)hypermap` THEN EXISTS_TAC `NF:(A)loop->bool` 
      THEN EXISTS_TAC `node_map (H:(A)hypermap) (tail H (NF:(A)loop->bool) (x':A))`
      THEN ASM_REWRITE_TAC[]; ALL_TAC]
   THEN POP_ASSUM (SUBST1_TAC o SYM)
   THEN POP_ASSUM (fun th -> REWRITE_TAC[th]));;

let fmap_permute = prove(`!(H:(A)hypermap) (NF:(A)loop->bool). is_normal H NF ==> (fmap H NF) permutes (quotient_darts H NF)`,
   REPEAT GEN_TAC
   THEN DISCH_THEN (LABEL_TAC "F1")
   THEN REWRITE_TAC[permutes]
   THEN STRIP_TAC
   THENL[USE_THEN "F1" (fun th -> REWRITE_TAC[MATCH_MP lemma_face_map th]); ALL_TAC]
   THEN REWRITE_TAC[EXISTS_UNIQUE]
   THEN GEN_TAC
   THEN ASM_CASES_TAC `~(y:A->bool IN (quotient_darts (H:(A)hypermap) (NF:(A)loop->bool)))`
   THENL[EXISTS_TAC `y:A->bool`
       THEN USE_THEN "F1" (MP_TAC o CONJUNCT1 o SPEC `y:A->bool` o MATCH_MP lemma_face_map)
       THEN ASM_REWRITE_TAC[]
       THEN DISCH_THEN (fun th-> REWRITE_TAC[th] THEN (LABEL_TAC "G1" th))
       THEN GEN_TAC
       THEN ASM_CASES_TAC `~(y':A->bool IN quotient_darts (H:(A)hypermap) (NF:(A)loop->bool))`
       THENL[USE_THEN "F1" (MP_TAC o CONJUNCT1 o SPEC `y':A->bool` o MATCH_MP lemma_face_map)
	  THEN ASM_REWRITE_TAC[]
	  THEN DISCH_THEN(fun th-> REWRITE_TAC[th]); ALL_TAC]	  
       THEN POP_ASSUM (MP_TAC o REWRITE_RULE[quotient_darts; IN_ELIM_THM])
       THEN DISCH_THEN (X_CHOOSE_THEN `L:(A)loop` (X_CHOOSE_THEN `x:A` (CONJUNCTS_THEN2 (CONJUNCTS_THEN2 (LABEL_TAC "G2") (LABEL_TAC "G3")) SUBST1_TAC)))
       THEN USE_THEN "F1"(fun th1->(USE_THEN "G2"(fun th2->(USE_THEN "G3"(fun th3->(MP_TAC(MATCH_MP unique_fmap(CONJ th1 (CONJ th2 th3)))))))))
       THEN DISCH_THEN (SUBST1_TAC)
       THEN DISCH_TAC
       THEN SUBGOAL_THEN `y:A->bool IN quotient_darts (H:(A)hypermap) (NF:(A)loop->bool)` MP_TAC
       THENL[ POP_ASSUM (SUBST1_TAC o SYM)
           THEN  MATCH_MP_TAC lemma_in_quotient
           THEN USE_THEN "F1"(fun th1->(USE_THEN "G2"(fun th2->(USE_THEN "G3"(fun th3->REWRITE_TAC[MATCH_MP face_map_on_margin (CONJ th1 (CONJ th2 th3))])))))
           THEN USE_THEN "G2" (fun th -> REWRITE_TAC[th]); ALL_TAC]
       THEN ASM_REWRITE_TAC[]; ALL_TAC]
   THEN POP_ASSUM (LABEL_TAC "F2" o REWRITE_RULE[])
    THEN USE_THEN "F2" (MP_TAC o REWRITE_RULE[quotient_darts; IN_ELIM_THM])
    THEN DISCH_THEN (X_CHOOSE_THEN `L:(A)loop` (X_CHOOSE_THEN `x:A` (CONJUNCTS_THEN2 (CONJUNCTS_THEN2 (LABEL_TAC "F3") (LABEL_TAC "F4")) SUBST1_TAC)))
    THEN USE_THEN "F3" (fun th -> (USE_THEN "F1" (LABEL_TAC "FC" o CONJUNCT1 o REWRITE_RULE[th] o  SPEC `L:(A)loop` o  CONJUNCT1 o REWRITE_RULE[is_normal])))
    THEN EXISTS_TAC `atom (H:(A)hypermap) (L:(A)loop) ((inverse (face_map (H:(A)hypermap))) (tail H (NF:(A)loop->bool) (x:A)))`
    THEN STRIP_TAC
    THENL[USE_THEN "F1"(fun th1->(USE_THEN "F3"(fun th2->(USE_THEN "F4"(fun th3->MP_TAC(MATCH_MP face_map_on_margin (CONJ th1 (CONJ th2 th3))))))))
        THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F5") (CONJUNCTS_THEN2 (LABEL_TAC "F6") (CONJUNCTS_THEN2 (LABEL_TAC "F7") (LABEL_TAC "F8"))))
	THEN USE_THEN "F1"(fun th1->(USE_THEN "F3"(fun th2->(USE_THEN "F6"(fun th3->(MP_TAC(MATCH_MP unique_fmap(CONJ th1 (CONJ th2 th3)))))))))
	THEN DISCH_THEN SUBST1_TAC
	THEN POP_ASSUM (SUBST1_TAC o SYM)
	THEN REWRITE_TAC[MATCH_MP PERMUTES_INVERSES (CONJUNCT2 (SPEC `H:(A)hypermap` face_map_and_darts))]
	THEN CONV_TAC SYM_CONV
	THEN MATCH_MP_TAC lemma_identity_atom
	THEN USE_THEN "F1"(fun th1->(USE_THEN "F3"(fun th2->(USE_THEN "F4"(fun th3->(REWRITE_TAC[CONJUNCT1(MATCH_MP tail_on_loop (CONJ th1 (CONJ th2 th3)))]))))))
	THEN USE_THEN "FC" (fun th -> REWRITE_TAC[th]); ALL_TAC]
    THEN GEN_TAC
    THEN ASM_CASES_TAC `~(y':A->bool IN quotient_darts (H:(A)hypermap) (NF:(A)loop->bool))`
    THENL[USE_THEN "F1" (MP_TAC o CONJUNCT1 o SPEC `y':A->bool` o MATCH_MP lemma_face_map)
       THEN ASM_REWRITE_TAC[]
       THEN DISCH_THEN SUBST1_TAC
       THEN DISCH_TAC
       THEN FIRST_X_ASSUM (MP_TAC o check (is_neg o concl))
       THEN POP_ASSUM SUBST1_TAC
       THEN USE_THEN "F3" (fun th-> (USE_THEN "F4" (fun th1 -> (REWRITE_TAC[MATCH_MP lemma_in_quotient (CONJ th th1)])))); ALL_TAC]
   THEN POP_ASSUM (MP_TAC o REWRITE_RULE[quotient_darts; IN_ELIM_THM])
   THEN DISCH_THEN (X_CHOOSE_THEN `L':(A)loop` (X_CHOOSE_THEN `y:A` (CONJUNCTS_THEN2 (CONJUNCTS_THEN2 (LABEL_TAC "F5") (LABEL_TAC "F6")) SUBST1_TAC)))
   THEN USE_THEN "F1"(fun th1->(USE_THEN "F5"(fun th2->(USE_THEN "F6"(fun th3->(MP_TAC(MATCH_MP unique_fmap(CONJ th1 (CONJ th2 th3)))))))))
   THEN DISCH_THEN SUBST1_TAC
   THEN DISCH_THEN (LABEL_TAC "F7")
   THEN USE_THEN "F1"(fun th1->(USE_THEN "F5"(fun th2->(USE_THEN "F6"(fun th3->MP_TAC(CONJUNCT1(MATCH_MP face_map_on_margin (CONJ th1 (CONJ th2 th3)))))))))
   THEN DISCH_THEN (LABEL_TAC "F8")
   THEN SUBGOAL_THEN `L':(A)loop = L:(A)loop` SUBST_ALL_TAC
   THENL[MP_TAC(SPECL[`H:(A)hypermap`; `L:(A)loop`; `x:A`] atom_reflect)
       THEN REMOVE_THEN "F7" (SUBST1_TAC o SYM)
       THEN USE_THEN "F8"(fun th2->(DISCH_THEN(fun th3->ASSUME_TAC(MATCH_MP lemma_in_loop (CONJ th2 th3)))))
       THEN MATCH_MP_TAC disjoint_loops
       THEN EXISTS_TAC `H:(A)hypermap` THEN EXISTS_TAC `NF:(A)loop->bool` THEN EXISTS_TAC `x:A`
       THEN ASM_REWRITE_TAC[]; ALL_TAC]
   THEN MP_TAC(SPECL[`H:(A)hypermap`; `L:(A)loop`; `x:A`] atom_reflect)
   THEN USE_THEN "F7" (SUBST1_TAC o SYM)
   THEN USE_THEN "F1"(fun th1->(USE_THEN "F3"(fun th2->(USE_THEN "F8"(fun th3->(DISCH_THEN(fun th4->MP_TAC(MATCH_MP change_parameters (CONJ th1 (CONJ th2 (CONJ th3 th4)))))))))))
   THEN DISCH_THEN (SUBST1_TAC o CONJUNCT2)
   THEN USE_THEN "F1"(fun th1->(USE_THEN "F5"(fun th2->(USE_THEN "F6"(fun th3->MP_TAC(MATCH_MP face_map_on_margin (CONJ th1 (CONJ th2 th3))))))))
   THEN DISCH_THEN (SUBST1_TAC o SYM o CONJUNCT1 o CONJUNCT2 o CONJUNCT2)
   THEN REWRITE_TAC [MATCH_MP PERMUTES_INVERSES (CONJUNCT2 (SPEC `H:(A)hypermap` face_map_and_darts))]
   THEN USE_THEN "F1"(fun th1->(USE_THEN "F5"(fun th2->(USE_THEN "F6"(fun th3->REWRITE_TAC[MATCH_MP change_to_margin (CONJ th1 (CONJ th2 th3))]))))));;

let nmap_permute = prove(`!(H:(A)hypermap) (NF:(A)loop->bool). is_normal H NF ==> (nmap H NF) permutes (quotient_darts H NF)`,
   REPEAT GEN_TAC
   THEN DISCH_THEN (LABEL_TAC "F1")
   THEN REWRITE_TAC[permutes]
   THEN STRIP_TAC
   THENL[USE_THEN "F1" (fun th -> REWRITE_TAC[MATCH_MP lemma_node_map th]); ALL_TAC]
   THEN REWRITE_TAC[EXISTS_UNIQUE] 
   THEN GEN_TAC
   THEN ASM_CASES_TAC `~(y:A->bool IN (quotient_darts (H:(A)hypermap) (NF:(A)loop->bool)))`
THENL[EXISTS_TAC `y:A->bool`
       THEN USE_THEN "F1" (MP_TAC o CONJUNCT1 o SPEC `y:A->bool` o MATCH_MP lemma_node_map)
       THEN ASM_REWRITE_TAC[]
       THEN DISCH_THEN (fun th-> REWRITE_TAC[th] THEN (LABEL_TAC "G1" th))
       THEN GEN_TAC
       THEN ASM_CASES_TAC `~(y':A->bool IN quotient_darts (H:(A)hypermap) (NF:(A)loop->bool))`
       THENL[USE_THEN "F1" (MP_TAC o CONJUNCT1 o SPEC `y':A->bool` o MATCH_MP lemma_node_map)
	  THEN ASM_REWRITE_TAC[]
	  THEN DISCH_THEN(fun th-> REWRITE_TAC[th]); ALL_TAC]
       THEN POP_ASSUM (MP_TAC o REWRITE_RULE[quotient_darts; IN_ELIM_THM])
       THEN DISCH_THEN (X_CHOOSE_THEN `L:(A)loop` (X_CHOOSE_THEN `x:A` (CONJUNCTS_THEN2 (CONJUNCTS_THEN2 (LABEL_TAC "G2") (LABEL_TAC "G3")) SUBST1_TAC)))
       THEN USE_THEN "G2" (fun th -> (USE_THEN "F1" (LABEL_TAC "FC" o CONJUNCT1 o REWRITE_RULE[th] o  SPEC `L:(A)loop` o  CONJUNCT1 o REWRITE_RULE[is_normal])))
       THEN USE_THEN "F1"(fun th->(USE_THEN "G2"(fun th2->(USE_THEN "G3"(fun th3-> MP_TAC (CONJUNCT1 (MATCH_MP node_map_on_margin (CONJ th (CONJ th2 th3)))))))))
       THEN DISCH_THEN (X_CHOOSE_THEN `L':(A)loop` (CONJUNCTS_THEN2 (LABEL_TAC "G4") (CONJUNCTS_THEN2 (LABEL_TAC "G5") (LABEL_TAC "G6"))))
       THEN DISCH_THEN (LABEL_TAC "G7")
       THEN USE_THEN "G5" MP_TAC THEN USE_THEN "G3" MP_TAC THEN USE_THEN "G4" MP_TAC THEN USE_THEN "G2" MP_TAC THEN USE_THEN "F1" MP_TAC
       THEN REWRITE_TAC[IMP_IMP; GSYM CONJ_ASSOC]
       THEN DISCH_THEN (MP_TAC o MATCH_MP unique_nmap)
       THEN POP_ASSUM SUBST1_TAC
       THEN DISCH_TAC
       THEN FIRST_X_ASSUM (MP_TAC o check (is_neg o concl))
       THEN POP_ASSUM (fun th -> GEN_REWRITE_TAC (LAND_CONV o ONCE_DEPTH_CONV) [th])
       THEN USE_THEN "G4" (fun th1 -> (USE_THEN "G5" (fun th2 -> REWRITE_TAC[MATCH_MP lemma_in_quotient (CONJ th1 th2)]))); ALL_TAC]
   THEN POP_ASSUM (MP_TAC o REWRITE_RULE[quotient_darts; IN_ELIM_THM])
   THEN DISCH_THEN (X_CHOOSE_THEN `L:(A)loop` (X_CHOOSE_THEN `x:A` (CONJUNCTS_THEN2 (CONJUNCTS_THEN2 (LABEL_TAC "F3") (LABEL_TAC "F4")) SUBST1_TAC)))
   THEN USE_THEN "F3" (fun th -> (USE_THEN "F1" (LABEL_TAC "FC" o CONJUNCT1 o REWRITE_RULE[th] o  SPEC `L:(A)loop` o  CONJUNCT1 o REWRITE_RULE[is_normal])))
   THEN USE_THEN "F1"(fun th->(USE_THEN "F3"(fun th2->(USE_THEN "F4"(fun th3-> MP_TAC (CONJUNCT2 (MATCH_MP node_map_on_margin (CONJ th (CONJ th2 th3)))))))))
   THEN DISCH_THEN (X_CHOOSE_THEN `L':(A)loop` (CONJUNCTS_THEN2 (LABEL_TAC "G4") (CONJUNCTS_THEN2 (LABEL_TAC "G5") (LABEL_TAC "G6"))))
   THEN EXISTS_TAC `atom (H:(A)hypermap) (L':(A)loop) ((inverse (node_map (H:(A)hypermap))) (head H (NF:(A)loop->bool) (x:A)))`
  THEN ABBREV_TAC `y = inverse (node_map H) (head H NF (x:A))`
   THEN POP_ASSUM (MP_TAC o AP_TERM `node_map (H:(A)hypermap)`)
   THEN GEN_REWRITE_TAC (LAND_CONV o ONCE_DEPTH_CONV)  [MATCH_MP PERMUTES_INVERSES (CONJUNCT2(SPEC `H:(A)hypermap` node_map_and_darts))]
   THEN DISCH_THEN (LABEL_TAC "G7" o SYM)
   THEN USE_THEN "F1"(fun th->(USE_THEN "F3"(fun th2->(USE_THEN "F4"(fun th3-> MP_TAC (CONJUNCT1 (MATCH_MP head_on_loop (CONJ th (CONJ th2 th3)))))))))
   THEN USE_THEN "G7" (SUBST1_TAC o SYM)
   THEN DISCH_THEN (LABEL_TAC "F8")
   THEN USE_THEN "F4"(fun th2->(USE_THEN "F8"(fun th3-> MP_TAC (MATCH_MP lemma_in_loop (CONJ th2 th3)))))
   THEN USE_THEN "G6" (fun th -> GEN_REWRITE_TAC (LAND_CONV o ONCE_DEPTH_CONV) [th])
   THEN USE_THEN "G5" MP_TAC THEN USE_THEN "F3" MP_TAC THEN USE_THEN "G4" MP_TAC THEN USE_THEN "F1" MP_TAC
   THEN REWRITE_TAC[IMP_IMP; GSYM CONJ_ASSOC]
   THEN DISCH_THEN (MP_TAC o MATCH_MP unique_nmap)
   THEN USE_THEN "G6" (SUBST1_TAC o SYM)
   THEN USE_THEN "G7" (SUBST1_TAC )
   THEN DISCH_THEN SUBST1_TAC
   THEN USE_THEN "F1"(fun th->(USE_THEN "F3"(fun th2->(USE_THEN "F4"(fun th3-> REWRITE_TAC[MATCH_MP change_to_margin (CONJ th (CONJ th2 th3))])))))
   THEN GEN_TAC
   THEN ASM_CASES_TAC `~(y':A->bool IN quotient_darts (H:(A)hypermap) (NF:(A)loop->bool))`
   THENL[USE_THEN "F1" (fun th -> REWRITE_TAC[MATCH_MP lemma_node_map th])
       THEN USE_THEN "F1" (MP_TAC o CONJUNCT1 o SPEC `y':A->bool` o MATCH_MP lemma_node_map)
       THEN ASM_REWRITE_TAC[]
       THEN DISCH_THEN SUBST1_TAC
       THEN DISCH_TAC
       THEN FIRST_X_ASSUM (MP_TAC o check (is_neg o concl))
       THEN POP_ASSUM SUBST1_TAC
       THEN USE_THEN "F1"(fun th->(USE_THEN "F3"(fun th2->(USE_THEN "F4"(fun th3-> MP_TAC (CONJUNCT1 (MATCH_MP head_on_loop (CONJ th (CONJ th2 th3)))))))))
       THEN USE_THEN "F4"(fun th2->(DISCH_THEN(fun th3-> MP_TAC (MATCH_MP lemma_in_loop (CONJ th2 th3)))))
       THEN USE_THEN "F3" (fun th1 -> (DISCH_THEN (fun th2 -> REWRITE_TAC[MATCH_MP lemma_in_quotient (CONJ th1 th2)]))); ALL_TAC]
   THEN POP_ASSUM (MP_TAC o REWRITE_RULE[quotient_darts; IN_ELIM_THM])
   THEN DISCH_THEN (X_CHOOSE_THEN `P:(A)loop`(X_CHOOSE_THEN `z:A` (CONJUNCTS_THEN2 (CONJUNCTS_THEN2 (LABEL_TAC "F9") (LABEL_TAC "F10")) SUBST1_TAC)))
   THEN USE_THEN "F9" (fun th1 -> (USE_THEN "F10" (fun th2 -> ASSUME_TAC(SPEC `H:(A)hypermap`(MATCH_MP lemma_in_quotient (CONJ th1 th2))))))
   THEN USE_THEN "F1" (MP_TAC o CONJUNCT2 o SPEC `atom (H:(A)hypermap) (P:(A)loop) (z:A)` o MATCH_MP lemma_node_map)
   THEN POP_ASSUM (fun th-> REWRITE_TAC[th])
   THEN DISCH_THEN (X_CHOOSE_THEN `Q:(A)loop` (X_CHOOSE_THEN `Q':(A)loop` (X_CHOOSE_THEN `t:A` (CONJUNCTS_THEN2 (LABEL_TAC "F11") MP_TAC))))
   THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F12") (CONJUNCTS_THEN2 (LABEL_TAC "F14") (CONJUNCTS_THEN2 (LABEL_TAC "F15") MP_TAC)))
   THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F17") SUBST1_TAC)
   THEN USE_THEN "F1"(fun th->(USE_THEN "F3"(fun th2->(USE_THEN "F4"(fun th3-> REWRITE_TAC[GSYM(MATCH_MP change_to_margin (CONJ th (CONJ th2 th3)))])))))
   THEN DISCH_THEN (LABEL_TAC "F18")
   THEN SUBGOAL_THEN `Q:(A)loop = P:(A)loop` SUBST_ALL_TAC
   THENL[MP_TAC(SPECL[`H:(A)hypermap`; `P:(A)loop`; `z:A`] atom_reflect)
      THEN USE_THEN "F17" SUBST1_TAC
      THEN USE_THEN "F14" MP_TAC
      THEN USE_THEN "F11" (fun th -> (USE_THEN "F1" (MP_TAC o CONJUNCT1 o REWRITE_RULE[th] o  SPEC `Q:(A)loop` o  CONJUNCT1 o REWRITE_RULE[is_normal])))
      THEN REWRITE_TAC[IMP_IMP; GSYM CONJ_ASSOC]
      THEN DISCH_THEN (ASSUME_TAC o MATCH_MP lemma_in_loop o CONJUNCT2)
      THEN MATCH_MP_TAC disjoint_loops
      THEN EXISTS_TAC `H:(A)hypermap` THEN EXISTS_TAC `NF:(A)loop->bool` THEN  EXISTS_TAC `z:A`
      THEN ASM_REWRITE_TAC[]; ALL_TAC]
   THEN SUBGOAL_THEN `Q':(A)loop = L:(A)loop` SUBST_ALL_TAC
   THENL[MP_TAC(SPECL[`H:(A)hypermap`; `L:(A)loop`; `x:A`] atom_reflect)
      THEN USE_THEN "F18" (SUBST1_TAC o  SYM)
      THEN USE_THEN "F15" MP_TAC
      THEN USE_THEN "F12" (fun th -> (USE_THEN "F1" (MP_TAC o CONJUNCT1 o REWRITE_RULE[th] o  SPEC `Q':(A)loop` o  CONJUNCT1 o REWRITE_RULE[is_normal])))
      THEN REWRITE_TAC[IMP_IMP; GSYM CONJ_ASSOC]
      THEN DISCH_THEN (ASSUME_TAC o MATCH_MP lemma_in_loop o (CONJUNCT2))
      THEN MATCH_MP_TAC disjoint_loops
      THEN EXISTS_TAC `H:(A)hypermap` THEN EXISTS_TAC `NF:(A)loop->bool` THEN  EXISTS_TAC `x:A`
      THEN ASM_REWRITE_TAC[]; ALL_TAC]
   THEN REMOVE_THEN "F17" (SUBST1_TAC)
   THEN USE_THEN "F1"(fun th->(USE_THEN "F11"(fun th2->(USE_THEN "F14"(fun th3->MP_TAC(CONJUNCT1(MATCH_MP node_map_free_loop (CONJ th (CONJ th2 th3)))))))))
   THEN MP_TAC(SPECL[`H:(A)hypermap`; `L:(A)loop`; `node_map (H:(A)hypermap) (tail H (NF:(A)loop->bool) (t:A))`] atom_reflect)
   THEN USE_THEN "F18" SUBST1_TAC
   THEN USE_THEN "F1"(fun th1->(USE_THEN "F3"(fun th2->(USE_THEN "F4"(fun th3->(DISCH_THEN(fun th4->MP_TAC(CONJUNCT1(MATCH_MP change_parameters (CONJ th1 (CONJ th2 (CONJ th3 th4))))))))))))
   THEN DISCH_THEN SUBST1_TAC
   THEN USE_THEN "G7" (SUBST1_TAC o SYM)
   THEN REWRITE_TAC[node_map_injective]
   THEN DISCH_THEN (LABEL_TAC "F19")
   THEN USE_THEN "F1"(fun th1->(USE_THEN "F11"(fun th2->(USE_THEN "F14"(fun th3->LABEL_TAC "F20"(CONJUNCT1(MATCH_MP change_to_margin (CONJ th1 (CONJ th2 th3)))))))))
  THEN SUBGOAL_THEN `P:(A)loop = L':(A)loop` SUBST_ALL_TAC
  THENL[ MP_TAC(SPECL[`H:(A)hypermap`; `P:(A)loop`; `(tail H (NF:(A)loop->bool) (t:A))`] atom_reflect)
      THEN USE_THEN "F20" (SUBST1_TAC o SYM)
      THEN USE_THEN "F19" SUBST1_TAC
      THEN USE_THEN "F14" MP_TAC
      THEN USE_THEN "F11" (fun th -> (USE_THEN "F1" (MP_TAC o CONJUNCT1 o REWRITE_RULE[th] o  SPEC `P:(A)loop` o  CONJUNCT1 o REWRITE_RULE[is_normal])))
      THEN REWRITE_TAC[IMP_IMP; GSYM CONJ_ASSOC]
      THEN DISCH_THEN (ASSUME_TAC o MATCH_MP lemma_in_loop o CONJUNCT2)
      THEN MATCH_MP_TAC disjoint_loops
      THEN EXISTS_TAC `H:(A)hypermap` THEN EXISTS_TAC `NF:(A)loop->bool` THEN EXISTS_TAC `y:A`
      THEN ASM_REWRITE_TAC[]; ALL_TAC]
  THEN REPLICATE_TAC 2 (POP_ASSUM SUBST1_TAC)
  THEN POP_ASSUM SUBST1_TAC
  THEN SIMP_TAC[]);;

(* THE DEFINITION OF THE QUOTION HYPERMAP *)

let quotient = new_definition `!(H:(A)hypermap) (NF:(A)loop->bool). 
    quotient H NF = hypermap (quotient_darts H NF, inverse (fmap H NF) o inverse (nmap H NF), nmap H NF, fmap H NF)`;;


let lemma_quotient = prove(`!(H:(A)hypermap) (NF:(A)loop->bool). is_normal H NF ==> dart (quotient H NF) = quotient_darts H NF /\ edge_map (quotient H NF) = inverse (fmap H NF) o inverse (nmap H NF) /\ node_map (quotient H NF) = nmap H NF /\ face_map (quotient H NF) = fmap H NF`,
    REPEAT GEN_TAC
    THEN REWRITE_TAC[quotient]
    THEN DISCH_THEN (LABEL_TAC "F1")
    THEN USE_THEN "F1" (ASSUME_TAC o MATCH_MP lemma_finite_quotient_darts)
    THEN USE_THEN "F1" (LABEL_TAC "F2" o MATCH_MP nmap_permute)
    THEN USE_THEN "F1" (LABEL_TAC "F3" o MATCH_MP fmap_permute)
    THEN ABBREV_TAC `D = quotient_darts (H:(A)hypermap) (NF:(A)loop->bool)`
    THEN ABBREV_TAC `e = inverse (fmap (H:(A)hypermap) (NF:(A)loop->bool)) o inverse (nmap H NF)`
    THEN ABBREV_TAC `n = nmap (H:(A)hypermap) (NF:(A)loop->bool)`
    THEN ABBREV_TAC `f = fmap (H:(A)hypermap) (NF:(A)loop->bool)`
    THEN SUBGOAL_THEN `e:(A->bool) -> (A->bool) permutes (D:(A->bool)->bool)` ASSUME_TAC
    THENL[EXPAND_TAC "e"
	THEN ASM_MESON_TAC[PERMUTES_INVERSE; PERMUTES_COMPOSE]; ALL_TAC]
    THEN SUBGOAL_THEN `(e:(A->bool)->(A->bool)) o (n:(A->bool)->(A->bool)) o (f:(A->bool)->(A->bool)) = I` ASSUME_TAC
    THENL[EXPAND_TAC "e"
	THEN REWRITE_TAC[GSYM o_ASSOC] THEN REWRITE_TAC[lemma_4functions]
	THEN USE_THEN "F2" (fun th -> REWRITE_TAC[MATCH_MP PERMUTES_INVERSES_o th; I_O_ID])
	THEN USE_THEN "F3" (fun th -> REWRITE_TAC[MATCH_MP PERMUTES_INVERSES_o th; I_O_ID]); ALL_TAC]
    THEN MP_TAC (ISPECL[`D:(A->bool)->bool`; `e:(A->bool)->(A->bool)`; `n:(A->bool)->(A->bool)`; `f:(A->bool)->(A->bool)`]  lemma_hypermap_representation)
    THEN ASM_REWRITE_TAC[]
    THEN STRIP_TAC
    THEN ABBREV_TAC `G = hypermap(D:(A->bool)->bool, e:(A->bool)->(A->bool), n:(A->bool)->(A->bool), f:(A->bool)->(A->bool))`
    THEN UNDISCH_THEN `H':(A->bool)hypermap = G:(A->bool)hypermap` SUBST_ALL_TAC
    THEN ASM_SIMP_TAC[]);;

let choice_reflect = prove(`!(H:(A)hypermap) (NF:(A)loop->bool) (x:A). is_normal H NF ==> x IN choice H NF x`,
 REPEAT GEN_TAC THEN DISCH_THEN (LABEL_TAC "F1")
   THEN ASM_CASES_TAC `~(x:A IN support_darts NF)`
   THENL[USE_THEN "F1" (MP_TAC o SPEC `x:A` o CONJUNCT1 o MATCH_MP first_unique_choice)
      THEN ASM_REWRITE_TAC[]
      THEN DISCH_THEN SUBST1_TAC THEN REWRITE_TAC[IN_SING]; ALL_TAC]
   THEN POP_ASSUM (MP_TAC o REWRITE_RULE[support_darts; lemma_in_support])
   THEN DISCH_THEN (X_CHOOSE_THEN `L:(A)loop` MP_TAC)
   THEN POP_ASSUM (fun th -> (DISCH_THEN (fun th1-> MP_TAC (MATCH_MP unique_choice (CONJ th th1)))))
   THEN DISCH_THEN SUBST1_TAC
   THEN REWRITE_TAC[atom_reflect]);;

let lemma_choice_in_quotient = prove(`!(H:(A)hypermap) (NF:(A)loop->bool). is_normal H NF ==> (!x:A. choice H NF x IN quotient_darts H NF <=> x IN support_darts NF)`, 
  REPEAT GEN_TAC THEN DISCH_THEN (LABEL_TAC "F1") THEN GEN_TAC
    THEN REWRITE_TAC[quotient_darts; IN_ELIM_THM]
    THEN EQ_TAC
    THENL[DISCH_THEN (X_CHOOSE_THEN `L:(A)loop` (X_CHOOSE_THEN `y:A` (CONJUNCTS_THEN2 (CONJUNCTS_THEN2 (LABEL_TAC "F2") (LABEL_TAC "F3")) (ASSUME_TAC))))
	THEN MP_TAC (SPECL[`H:(A)hypermap`; `NF:(A)loop->bool`; `x:A`] choice_reflect)
	THEN ASM_REWRITE_TAC[]
	THEN POP_ASSUM SUBST1_TAC
	THEN POP_ASSUM (fun th->(DISCH_THEN(fun th1->MP_TAC(MATCH_MP lemma_in_loop (CONJ th th1)))))
	THEN POP_ASSUM (fun th->(DISCH_THEN(fun th1->MP_TAC(MATCH_MP lemma_in_support2 (CONJ th1 th)))))
	THEN SIMP_TAC[]; ALL_TAC]
    THEN REWRITE_TAC[lemma_in_support]
    THEN DISCH_THEN (X_CHOOSE_THEN `L':(A)loop` (CONJUNCTS_THEN2 (LABEL_TAC "G1") (LABEL_TAC "G2")))
    THEN EXISTS_TAC `L':(A)loop`
    THEN EXISTS_TAC `x:A`
    THEN ASM_REWRITE_TAC[]
    THEN MATCH_MP_TAC unique_choice
    THEN ASM_REWRITE_TAC[]);;

let atom_via_choice = prove(`!(H:(A)hypermap) (NF:(A)loop->bool). is_normal H NF ==> !atm:A->bool. atm IN quotient_darts H NF <=> ?x:A. x IN support_darts NF /\ atm = choice H NF x`,
  REPEAT GEN_TAC
    THEN DISCH_THEN (LABEL_TAC "F1")
    THEN GEN_TAC
    THEN EQ_TAC
    THENL[REWRITE_TAC[quotient_darts; IN_ELIM_THM]
	THEN DISCH_THEN(X_CHOOSE_THEN `L:(A)loop`(X_CHOOSE_THEN `x:A` (CONJUNCTS_THEN2 (CONJUNCTS_THEN2 (LABEL_TAC "F2") (LABEL_TAC "F3")) (SUBST1_TAC))))
	THEN EXISTS_TAC `x:A`
	THEN USE_THEN "F3"(fun th->(USE_THEN "F2"(fun th1-> REWRITE_TAC[MATCH_MP lemma_in_support2 (CONJ th th1)])))
	THEN CONV_TAC SYM_CONV
	THEN MATCH_MP_TAC unique_choice
	THEN ASM_REWRITE_TAC[]; ALL_TAC]
    THEN ASM_MESON_TAC[lemma_choice_in_quotient]);;

let choice_identity = prove(`!(H:(A)hypermap) (NF:(A)loop->bool) (x:A) (y:A). is_normal H NF /\ y IN choice H NF x  ==> choice H NF y = choice H NF x`,
   REPEAT GEN_TAC
   THEN REPEAT GEN_TAC
   THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F1") (LABEL_TAC "F2"))
   THEN ASM_CASES_TAC `~(x:A IN support_darts (NF:(A)loop->bool))`
   THENL[USE_THEN "F1" (MP_TAC o SPEC `x:A` o CONJUNCT1 o MATCH_MP first_unique_choice)
      THEN ASM_REWRITE_TAC[]
      THEN DISCH_THEN (LABEL_TAC "F3")
      THEN REMOVE_THEN "F2" MP_TAC   
      THEN USE_THEN "F3" (fun th -> REWRITE_TAC[th])
      THEN REWRITE_TAC[IN_SING]
      THEN DISCH_THEN SUBST1_TAC
      THEN ASM_REWRITE_TAC[]; ALL_TAC]
   THEN POP_ASSUM (MP_TAC o REWRITE_RULE[lemma_in_support])
   THEN DISCH_THEN (X_CHOOSE_THEN `L:(A)loop` (CONJUNCTS_THEN2 (LABEL_TAC "F3") (LABEL_TAC "F4")))
   THEN USE_THEN "F1"(fun th->(USE_THEN "F3"(fun th2->(USE_THEN "F4"(fun th3->MP_TAC (MATCH_MP unique_choice (CONJ th(CONJ th2 th3))))))))
   THEN DISCH_THEN SUBST_ALL_TAC
   THEN USE_THEN "F2" (fun th->REWRITE_TAC[MATCH_MP lemma_identity_atom th])
   THEN MATCH_MP_TAC unique_choice
   THEN ASM_REWRITE_TAC[]  
   THEN USE_THEN "F4"(fun th->(USE_THEN "F2"(fun th1->REWRITE_TAC[MATCH_MP lemma_in_loop (CONJ th th1)]))));;

let choice_at_margin = prove(`!(H:(A)hypermap) (NF:(A)loop->bool) (x:A). is_normal H NF ==> choice H NF x = choice H NF (tail H NF x) /\ choice H NF x = choice H NF (head H NF x)`,
  REPEAT GEN_TAC
  THEN DISCH_THEN (LABEL_TAC "F1")
  THEN ASM_CASES_TAC `~(x:A IN support_darts (NF:(A)loop->bool))`
  THENL[USE_THEN "F1" (MP_TAC o CONJUNCT1 o SPEC `x:A` o MATCH_MP lemma_head_tail)
       THEN ASM_REWRITE_TAC[]
       THEN MESON_TAC[]; ALL_TAC]
  THEN POP_ASSUM (MP_TAC o REWRITE_RULE[lemma_in_support])
  THEN DISCH_THEN (X_CHOOSE_THEN `L:(A)loop` (CONJUNCTS_THEN2 (LABEL_TAC "F2") (LABEL_TAC "F3")))
  THEN USE_THEN "F1"(fun th->(USE_THEN "F2"(fun th1->(USE_THEN "F3"(fun th2->LABEL_TAC "F4"(CONJUNCT1(MATCH_MP head_on_loop (CONJ th (CONJ th1 th2)))))))))
  THEN USE_THEN "F1"(fun th->(USE_THEN "F2"(fun th1->(USE_THEN "F3"(fun th2->LABEL_TAC "F5"(CONJUNCT1(MATCH_MP tail_on_loop (CONJ th (CONJ th1 th2)))))))))
  THEN USE_THEN "F1"(fun th->(USE_THEN "F2"(fun th1->(USE_THEN "F3"(fun th2->MP_TAC(MATCH_MP unique_choice (CONJ th (CONJ th1 th2))))))))
  THEN DISCH_THEN (SUBST_ALL_TAC o SYM)
  THEN USE_THEN "F1" (fun th-> (USE_THEN "F4"(fun th1->REWRITE_TAC[MATCH_MP choice_identity (CONJ th th1)])))
  THEN USE_THEN "F1" (fun th-> (USE_THEN "F5"(fun th1->REWRITE_TAC[MATCH_MP choice_identity (CONJ th th1)]))));;

let fmap_via_choice = prove(`!(H:(A)hypermap) (NF:(A)loop->bool) (x:A). is_normal H NF /\ x IN support_darts NF ==>  face_map H (head H NF x) IN support_darts NF /\ face_map H (head H NF x) = tail H NF (face_map H (head H NF x)) /\ fmap H NF (choice H NF x) = choice H NF (face_map H (head H NF x))`,
   REPEAT GEN_TAC
   THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F1") (MP_TAC o REWRITE_RULE[lemma_in_support]))
   THEN DISCH_THEN (X_CHOOSE_THEN `L:(A)loop` (CONJUNCTS_THEN2 (LABEL_TAC "F2") (LABEL_TAC "F3")))
   THEN USE_THEN "F1"(fun th->(USE_THEN "F2"(fun th1->(USE_THEN "F3"(fun th2->MP_TAC(MATCH_MP face_map_on_margin (CONJ th (CONJ th1 th2))))))))
   THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F4") (SUBST1_TAC o SYM o CONJUNCT1 o CONJUNCT2))
   THEN REWRITE_TAC[]
   THEN USE_THEN "F4"(fun th->(USE_THEN "F2"(fun th1->(REWRITE_TAC[MATCH_MP lemma_in_support2 (CONJ th th1)]))))
   THEN USE_THEN "F1"(fun th->(USE_THEN "F2"(fun th1->(USE_THEN "F3"(fun th2->MP_TAC(MATCH_MP unique_fmap (CONJ th (CONJ th1 th2))))))))
   THEN USE_THEN "F1"(fun th->(USE_THEN "F2"(fun th1->(USE_THEN "F3"(fun th2->MP_TAC(MATCH_MP unique_choice (CONJ th (CONJ th1 th2))))))))
   THEN DISCH_THEN SUBST1_TAC
   THEN USE_THEN "F1"(fun th->(USE_THEN "F2"(fun th1->(USE_THEN "F4"(fun th2->MP_TAC(MATCH_MP unique_choice (CONJ th (CONJ th1 th2))))))))
   THEN DISCH_THEN SUBST1_TAC
   THEN SIMP_TAC[]);;

let nmap_via_choice = prove(`!(H:(A)hypermap) (NF:(A)loop->bool) (x:A). is_normal H NF /\ x IN support_darts NF ==> node_map H (tail H NF x) IN support_darts NF /\ node_map H (tail H NF x) = head H NF (node_map H (tail H NF x)) /\ nmap H NF (choice H NF x) = choice H NF (node_map H (tail H NF x))`,
 REPEAT GEN_TAC
   THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F1") (MP_TAC o REWRITE_RULE[lemma_in_support]))
   THEN DISCH_THEN (X_CHOOSE_THEN `L:(A)loop` (CONJUNCTS_THEN2 (LABEL_TAC "F2") (LABEL_TAC "F3")))
   THEN USE_THEN "F1"(fun th->(USE_THEN "F2"(fun th1->(USE_THEN "F3"(fun th2->MP_TAC(CONJUNCT1(MATCH_MP node_map_on_margin (CONJ th (CONJ th1 th2)))))))))
   THEN DISCH_THEN (X_CHOOSE_THEN `L':(A)loop` (CONJUNCTS_THEN2 (LABEL_TAC "F4") (CONJUNCTS_THEN2 (LABEL_TAC "F5") (SUBST1_TAC o SYM))))
   THEN REWRITE_TAC[]
   THEN USE_THEN "F5"(fun th->(USE_THEN "F4"(fun th1->(REWRITE_TAC[MATCH_MP lemma_in_support2 (CONJ th th1)]))))
   THEN USE_THEN "F1"(fun th->(USE_THEN "F2"(fun th1->(USE_THEN "F3"(fun th2->REWRITE_TAC[MATCH_MP unique_choice (CONJ th (CONJ th1 th2))])))))
   THEN USE_THEN "F1"(fun th->(USE_THEN "F4"(fun th1->(USE_THEN "F5"(fun th2->REWRITE_TAC[MATCH_MP unique_choice (CONJ th (CONJ th1 th2))])))))
   THEN USE_THEN "F5" MP_TAC THEN USE_THEN "F3" MP_TAC THEN  USE_THEN "F4" MP_TAC THEN USE_THEN "F2" MP_TAC THEN USE_THEN "F1" MP_TAC
   THEN REWRITE_TAC[IMP_IMP; GSYM CONJ_ASSOC]
   THEN DISCH_THEN (SUBST1_TAC o MATCH_MP unique_nmap)
   THEN SIMP_TAC[]);;

let lemmaJMKRXLA = prove(`!(H:(A)hypermap) (NF:(A)loop->bool). is_normal H NF /\ plain_hypermap H ==> plain_hypermap (quotient H NF)`,
 REPEAT GEN_TAC
   THEN DISCH_THEN(CONJUNCTS_THEN2 (LABEL_TAC "F1") (LABEL_TAC "F2"))
   THEN REWRITE_TAC[edge_convolution]
   THEN USE_THEN "F1" (fun th -> REWRITE_TAC[MATCH_MP lemma_quotient th])
   THEN GEN_TAC
   THEN USE_THEN "F1"(fun th-> REWRITE_TAC[MATCH_MP atom_via_choice th])
   THEN DISCH_THEN (X_CHOOSE_THEN `x:A` (CONJUNCTS_THEN2 ASSUME_TAC SUBST1_TAC))
   THEN USE_THEN "F1"(fun th -> (POP_ASSUM (fun th1 -> MP_TAC (MATCH_MP fmap_via_choice (CONJ th th1)))))
   THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F3") (CONJUNCTS_THEN2 ASSUME_TAC (SUBST1_TAC)))
   THEN USE_THEN "F1"(fun th -> (REMOVE_THEN "F3" (fun th1 -> MP_TAC (MATCH_MP nmap_via_choice (CONJ th th1)))))
   THEN POP_ASSUM (SUBST1_TAC o SYM)
   THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F4") (CONJUNCTS_THEN2 ASSUME_TAC (SUBST1_TAC)))
   THEN USE_THEN "F1"(fun th -> (REMOVE_THEN "F4" (fun th1 -> MP_TAC (MATCH_MP fmap_via_choice (CONJ th th1)))))
   THEN POP_ASSUM (SUBST1_TAC o SYM)
   THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F5") (CONJUNCTS_THEN2 ASSUME_TAC (SUBST1_TAC)))
   THEN USE_THEN "F1"(fun th -> (REMOVE_THEN "F5" (fun th1 -> MP_TAC (MATCH_MP nmap_via_choice (CONJ th th1)))))
   THEN POP_ASSUM (SUBST1_TAC o SYM)
   THEN DISCH_THEN (SUBST1_TAC o CONJUNCT2 o CONJUNCT2)
   THEN POP_ASSUM (MP_TAC o REWRITE_RULE[plain_hypermap])
   THEN REWRITE_TAC[MATCH_MP convolution_inv (CONJUNCT2 (SPEC `H:(A)hypermap` edge_map_and_darts))]
   THEN REWRITE_TAC[inverse_hypermap_maps]
   THEN DISCH_THEN (fun th -> (MP_TAC(AP_THM th `head (H:(A)hypermap) (NF:(A)loop->bool) (x:A)`)))
   THEN REWRITE_TAC[o_THM; I_THM]
   THEN DISCH_THEN SUBST1_TAC
   THEN POP_ASSUM (fun th-> MESON_TAC[MATCH_MP choice_at_margin th]));;

(* SOME LEMMAS ON INJECTIVE, SURJECTIVE AND BIJECTIVE MAPS *)

let COMPOSE_INJ = prove(`!f:A->B  g:B->C s t w. INJ f s t /\ INJ g t w ==> INJ (g o f) s w`,
 REPEAT GEN_TAC
   THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F1") (LABEL_TAC "F2"))
   THEN SUBGOAL_THEN `!x:A. x IN s ==> (f:A->B) x IN t /\ ((g:B->C) (f x)) IN w` (LABEL_TAC "F3")
   THENL[GEN_TAC THEN DISCH_TAC
       THEN POP_ASSUM(fun th-> USE_THEN "F1" (ASSUME_TAC o REWRITE_RULE[th] o  SPEC `x:A` o CONJUNCT1 o REWRITE_RULE[INJ]))
       THEN ASM_REWRITE_TAC[]
       THEN POP_ASSUM(fun th-> USE_THEN "F2" (ASSUME_TAC o REWRITE_RULE[th] o  SPEC `(f:A->B) (x:A)` o CONJUNCT1 o REWRITE_RULE[INJ]))
       THEN ASM_REWRITE_TAC[]; ALL_TAC]
   THEN REWRITE_TAC[INJ; o_THM]
   THEN STRIP_TAC
   THENL[GEN_TAC
       THEN DISCH_THEN(fun th->(POP_ASSUM (MP_TAC o CONJUNCT2 o REWRITE_RULE[th] o SPEC `x:A`)))
       THEN SIMP_TAC[]; ALL_TAC]
   THEN REPEAT STRIP_TAC
   THEN USE_THEN "F3" (MP_TAC o SPEC `x:A`)
   THEN REMOVE_THEN "F3" (MP_TAC o SPEC `y:A`)
   THEN ASM_REWRITE_TAC[]
   THEN REPEAT STRIP_TAC
   THEN REMOVE_THEN "F2" (MP_TAC o SPECL[`(f:A->B) (x:A)`; `(f:A->B) (y:A)`] o CONJUNCT2 o REWRITE_RULE[INJ])
   THEN ASM_REWRITE_TAC[]
   THEN DISCH_TAC
   THEN REMOVE_THEN "F1" (MP_TAC o SPECL[`x:A`; `y:A`] o CONJUNCT2 o REWRITE_RULE[INJ] )
   THEN ASM_REWRITE_TAC[]);;

let COMPOSE_SURJ = prove(`!f:A->B  g:B->C s t w. SURJ f s t /\ SURJ g t w ==> SURJ (g o f) s w`,
 REPEAT GEN_TAC
   THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F1") (LABEL_TAC "F2"))
   THEN REWRITE_TAC[SURJ; o_THM]
   THEN STRIP_TAC
   THENL[REPEAT STRIP_TAC
      THEN POP_ASSUM(fun th-> USE_THEN "F1" (ASSUME_TAC o REWRITE_RULE[th] o  SPEC `x:A` o CONJUNCT1 o REWRITE_RULE[SURJ]))
      THEN POP_ASSUM(fun th-> USE_THEN "F2" (ASSUME_TAC o REWRITE_RULE[th] o  SPEC `(f:A->B) (x:A)` o CONJUNCT1 o REWRITE_RULE[SURJ]))
      THEN ASM_REWRITE_TAC[]; ALL_TAC]
   THEN REPEAT STRIP_TAC
   THEN POP_ASSUM(fun th->(REMOVE_THEN "F2" (MP_TAC o REWRITE_RULE[th] o  SPEC `x:C` o CONJUNCT2 o REWRITE_RULE[SURJ])))
   THEN DISCH_THEN (X_CHOOSE_THEN `y:B` (CONJUNCTS_THEN2 ASSUME_TAC (SUBST1_TAC o SYM)))
   THEN POP_ASSUM(fun th->(REMOVE_THEN "F1" (MP_TAC o REWRITE_RULE[th] o  SPEC `y:B` o CONJUNCT2 o REWRITE_RULE[SURJ])))
   THEN DISCH_THEN (X_CHOOSE_THEN `z:A` (CONJUNCTS_THEN2 ASSUME_TAC (SUBST1_TAC o SYM)))
   THEN EXISTS_TAC `z:A`
   THEN ASM_REWRITE_TAC[]);;

let COMPOSE_BIJ = prove(`!f:A->B  g:B->C s t w. BIJ f s t /\ BIJ g t w ==> BIJ (g o f) s w`,
   MESON_TAC[BIJ; COMPOSE_INJ; COMPOSE_SURJ]);;

let BIJ_INVERSE = prove(`!f:A->B s t. BIJ f s t ==> ?g:B->A. (!x:A. x IN s ==> g (f x) = x) /\ (!x:B. x IN t ==> f (g x) = x) /\ BIJ g t s`,
   REPEAT GEN_TAC
   THEN DISCH_THEN (LABEL_TAC "F1" o REWRITE_RULE[BIJ])
   THEN USE_THEN "F1" (MP_TAC o REWRITE_RULE[INJ] o CONJUNCT1)
   THEN REWRITE_TAC[ISPECL[`f:A->B`; `s:A->bool`] INJECTIVE_ON_LEFT_INVERSE]
   THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F2") (X_CHOOSE_THEN `g:B->A` (LABEL_TAC "F3")))
   THEN EXISTS_TAC `g:B->A`
   THEN ASM_REWRITE_TAC[]
   THEN SUBGOAL_THEN `SURJ (g:B->A) t s` (LABEL_TAC "F4")
   THENL[REWRITE_TAC[SURJ]
       THEN STRIP_TAC
       THENL[REPEAT STRIP_TAC
          THEN USE_THEN "F1" (MP_TAC o SPEC `x:B` o CONJUNCT2 o  REWRITE_RULE[SURJ] o CONJUNCT2)
          THEN ASM_REWRITE_TAC[]
          THEN DISCH_THEN (X_CHOOSE_THEN `y:A` (CONJUNCTS_THEN2 ASSUME_TAC (SUBST1_TAC o SYM)))
          THEN REMOVE_THEN "F3" (MP_TAC o SPEC `y:A`)
          THEN ASM_REWRITE_TAC[]
          THEN POP_ASSUM (fun th -> MESON_TAC[th]); ALL_TAC]
       THEN REPEAT GEN_TAC
       THEN DISCH_THEN (LABEL_TAC "F4")
       THEN USE_THEN "F4" (fun th -> (USE_THEN "F2" (ASSUME_TAC o REWRITE_RULE[th] o SPEC `x:A`)))
       THEN EXISTS_TAC `(f:A->B) x`
       THEN USE_THEN "F4" (fun th -> (USE_THEN "F3" (MP_TAC o REWRITE_RULE[th] o SPEC `x:A`)))
       THEN POP_ASSUM (fun th-> SIMP_TAC[th]); ALL_TAC]
    THEN SUBGOAL_THEN `BIJ (g:B->A) t s` (LABEL_TAC "F5")
    THENL[REWRITE_TAC[BIJ]
       THEN ASM_REWRITE_TAC[INJ]
       THEN STRIP_TAC
       THENL[POP_ASSUM (fun th-> MESON_TAC[REWRITE_RULE[SURJ] th]); ALL_TAC]
       THEN REPEAT GEN_TAC
       THEN DISCH_THEN(CONJUNCTS_THEN2 (LABEL_TAC "F5") (CONJUNCTS_THEN2 (LABEL_TAC "F6")  (LABEL_TAC "F7")))
       THEN REMOVE_THEN "F5"(fun th->(USE_THEN "F1"(MP_TAC o REWRITE_RULE[th] o SPEC `x:B` o CONJUNCT2 o REWRITE_RULE[SURJ] o CONJUNCT2)))
       THEN DISCH_THEN (X_CHOOSE_THEN `a:A` (CONJUNCTS_THEN2 ASSUME_TAC (SUBST_ALL_TAC o SYM)))
       THEN REMOVE_THEN "F6"(fun th->(USE_THEN "F1"(MP_TAC o REWRITE_RULE[th] o SPEC `y:B` o CONJUNCT2 o REWRITE_RULE[SURJ] o CONJUNCT2)))
       THEN DISCH_THEN (X_CHOOSE_THEN `b:A` (CONJUNCTS_THEN2 ASSUME_TAC (SUBST_ALL_TAC o SYM)))
       THEN AP_TERM_TAC
       THEN POP_ASSUM(fun th->(USE_THEN "F3"(MP_TAC o REWRITE_RULE[th] o SPEC `b:A`)))
       THEN REMOVE_THEN "F7" (SUBST1_TAC o SYM)
       THEN POP_ASSUM(fun th->(REMOVE_THEN "F3"(MP_TAC o REWRITE_RULE[th] o SPEC `a:A`)))
       THEN MESON_TAC[]; ALL_TAC]
    THEN USE_THEN "F5" (fun th-> REWRITE_TAC[th])
    THEN GEN_TAC THEN (DISCH_THEN (LABEL_TAC "G1"))
    THEN USE_THEN "G1" (fun th-> (USE_THEN "F4" (LABEL_TAC "G2" o REWRITE_RULE[th] o SPEC `x:B` o CONJUNCT1 o REWRITE_RULE[SURJ])))
    THEN USE_THEN "G2" (fun th-> (USE_THEN "F3" (fun thm -> (ASSUME_TAC (MATCH_MP thm th)))))
    THEN USE_THEN "G2" (fun th-> (USE_THEN "F2" (fun thm -> (ASSUME_TAC (MATCH_MP thm th)))))
    THEN USE_THEN "F5" (MP_TAC o CONJUNCT1 o REWRITE_RULE[BIJ])
    THEN USE_THEN "G1" (fun th-> (DISCH_THEN (MP_TAC o REWRITE_RULE[th] o SPECL[`(f:A->B) ((g:B->A) x)`; `x:B`] o CONJUNCT2 o REWRITE_RULE[INJ])))
    THEN ASM_REWRITE_TAC[]);;

let I_BIJ = prove(`!s:A->bool. BIJ I s s`, REWRITE_TAC[BIJ; INJ; SURJ] THEN REWRITE_TAC[I_THM] THEN MESON_TAC[]);;

(* the definition of isomorphism between two hypermaps and some obvious properties *)

let iso = new_definition `!(H:(A)hypermap) (H':(B)hypermap) . H iso H'  <=> (?f:A->B. BIJ f (dart H) (dart H')  /\
!x:A. x IN dart H ==> (edge_map H')  (f x) = f (edge_map H x) /\ (node_map H') (f x) = f (node_map H x) /\ (face_map H') (f x) = f (face_map H x))`;;

let iso_reflect = prove(`!(H:(A)hypermap). H iso H`,
 GEN_TAC THEN REWRITE_TAC[iso] THEN EXISTS_TAC `I:A->A` THEN REWRITE_TAC[I_THM; I_BIJ]);;

let iso_sym = prove(`!(H:(A)hypermap) (G:(B)hypermap). H iso G ==> G iso H`,
  REPEAT GEN_TAC
   THEN REWRITE_TAC[iso]
   THEN DISCH_THEN (X_CHOOSE_THEN `f:A->B` (CONJUNCTS_THEN2 (LABEL_TAC "F1") (LABEL_TAC "F2")))
   THEN USE_THEN "F1" (MP_TAC o MATCH_MP BIJ_INVERSE)
   THEN DISCH_THEN(X_CHOOSE_THEN `g:B->A` (CONJUNCTS_THEN2 (LABEL_TAC "F3") (CONJUNCTS_THEN2(LABEL_TAC "FC") (LABEL_TAC "F4"))))
   THEN EXISTS_TAC `g:B->A`
   THEN ASM_REWRITE_TAC[]
   THEN GEN_TAC
   THEN DISCH_THEN (LABEL_TAC "F5")
   THEN STRIP_TAC
   THENL[USE_THEN "F5" (LABEL_TAC "F6" o CONJUNCT1 o  MATCH_MP lemma_dart_invariant)
      THEN USE_THEN "F4" (MP_TAC o SPEC `x:B` o CONJUNCT1 o  REWRITE_RULE[INJ] o CONJUNCT1 o REWRITE_RULE[BIJ])
      THEN USE_THEN "F5" (fun th-> REWRITE_TAC[th])
      THEN DISCH_THEN (LABEL_TAC "F7")
      THEN USE_THEN "F7" (LABEL_TAC "F8" o CONJUNCT1 o  MATCH_MP lemma_dart_invariant)
      THEN USE_THEN "F7" (fun th-> (USE_THEN "F2" (MP_TAC o CONJUNCT1 o REWRITE_RULE[th] o SPEC `(g:B->A) x`)))
      THEN USE_THEN "F5" (fun th-> USE_THEN "FC" (MP_TAC o REWRITE_RULE[th] o SPEC `x:B`))
      THEN DISCH_THEN SUBST1_TAC
      THEN DISCH_THEN (MP_TAC o SYM o AP_TERM `g:B->A`)
      THEN USE_THEN "F3" (fun thm-> (USE_THEN "F8" (fun th -> REWRITE_TAC[MATCH_MP thm th]))); ALL_TAC]
    THEN STRIP_TAC
    THENL[USE_THEN "F5" (LABEL_TAC "F6" o CONJUNCT1 o CONJUNCT2 o MATCH_MP lemma_dart_invariant)
      THEN USE_THEN "F4" (MP_TAC o SPEC `x:B` o CONJUNCT1 o  REWRITE_RULE[INJ] o CONJUNCT1 o REWRITE_RULE[BIJ])
      THEN USE_THEN "F5" (fun th-> REWRITE_TAC[th])
      THEN DISCH_THEN (LABEL_TAC "F7")
      THEN USE_THEN "F7" (LABEL_TAC "F8" o CONJUNCT1 o CONJUNCT2 o  MATCH_MP lemma_dart_invariant)
      THEN USE_THEN "F7" (fun th-> (USE_THEN "F2" (MP_TAC o CONJUNCT1 o CONJUNCT2 o REWRITE_RULE[th] o SPEC `(g:B->A) x`)))
      THEN USE_THEN "F5" (fun th-> USE_THEN "FC" (MP_TAC o REWRITE_RULE[th] o SPEC `x:B`))
      THEN DISCH_THEN SUBST1_TAC
      THEN DISCH_THEN (MP_TAC o SYM o AP_TERM `g:B->A`)
      THEN USE_THEN "F3" (fun thm-> (USE_THEN "F8" (fun th -> REWRITE_TAC[MATCH_MP thm th]))); ALL_TAC]
    THEN USE_THEN "F5" (LABEL_TAC "F6" o CONJUNCT2 o CONJUNCT2 o MATCH_MP lemma_dart_invariant)
    THEN USE_THEN "F4" (MP_TAC o SPEC `x:B` o CONJUNCT1 o  REWRITE_RULE[INJ] o CONJUNCT1 o REWRITE_RULE[BIJ])
    THEN USE_THEN "F5" (fun th-> REWRITE_TAC[th])
    THEN DISCH_THEN (LABEL_TAC "F7")
    THEN USE_THEN "F7" (LABEL_TAC "F8" o CONJUNCT2 o CONJUNCT2 o  MATCH_MP lemma_dart_invariant)
    THEN USE_THEN "F7" (fun th-> (USE_THEN "F2" (MP_TAC o CONJUNCT2 o CONJUNCT2 o REWRITE_RULE[th] o SPEC `(g:B->A) x`)))
    THEN USE_THEN "F5" (fun th-> USE_THEN "FC" (MP_TAC o REWRITE_RULE[th] o SPEC `x:B`))
    THEN DISCH_THEN SUBST1_TAC
    THEN DISCH_THEN (MP_TAC o SYM o AP_TERM `g:B->A`)
    THEN USE_THEN "F3" (fun thm-> (USE_THEN "F8" (fun th -> REWRITE_TAC[MATCH_MP thm th]))));;

let iso_trans = prove(`!(H:(A)hypermap) (G:(B)hypermap) (W:(C)hypermap). H iso G /\ G iso W ==> H iso W`,
 REPEAT GEN_TAC
   THEN REWRITE_TAC[iso]
   THEN DISCH_THEN (CONJUNCTS_THEN2 (X_CHOOSE_THEN `f:A->B` (CONJUNCTS_THEN2 (LABEL_TAC "F1") (LABEL_TAC "F2"))) (X_CHOOSE_THEN `g:B->C` (CONJUNCTS_THEN2 (LABEL_TAC "F3") (LABEL_TAC "F4"))))
   THEN EXISTS_TAC `(g:B->C) o (f:A->B)`
   THEN USE_THEN "F1" (fun th-> (USE_THEN "F3" (fun th1-> REWRITE_TAC[MATCH_MP COMPOSE_BIJ (CONJ th th1)])))
   THEN GEN_TAC THEN DISCH_THEN (LABEL_TAC "F5")
   THEN USE_THEN "F1" (MP_TAC o SPEC `x:A` o CONJUNCT1 o REWRITE_RULE[INJ] o CONJUNCT1 o REWRITE_RULE[BIJ])
   THEN USE_THEN "F5" (fun th-> (DISCH_THEN(fun thm-> (LABEL_TAC "F6" (MATCH_MP thm th)))))
   THEN REWRITE_TAC[o_THM]
   THEN STRIP_TAC
   THENL[USE_THEN "F5" (fun th-> (USE_THEN "F2" (MP_TAC o CONJUNCT1 o REWRITE_RULE[th] o SPEC `x:A`)))
       THEN DISCH_THEN (SUBST1_TAC o SYM)
       THEN USE_THEN "F6" (fun th-> (USE_THEN "F4" (MP_TAC o CONJUNCT1 o REWRITE_RULE[th] o SPEC `(f:A->B) x`)))
       THEN SIMP_TAC[]; ALL_TAC]
   THEN STRIP_TAC
   THENL[USE_THEN "F5" (fun th-> (USE_THEN "F2" (MP_TAC o CONJUNCT1 o CONJUNCT2 o REWRITE_RULE[th] o SPEC `x:A`)))
       THEN DISCH_THEN (SUBST1_TAC o SYM)
       THEN USE_THEN "F6" (fun th-> (USE_THEN "F4" (MP_TAC o CONJUNCT1 o CONJUNCT2 o  REWRITE_RULE[th] o SPEC `(f:A->B) x`)))
       THEN SIMP_TAC[]; ALL_TAC]
   THEN USE_THEN "F5" (fun th-> (USE_THEN "F2" (MP_TAC o CONJUNCT2 o CONJUNCT2 o REWRITE_RULE[th] o SPEC `x:A`)))
   THEN DISCH_THEN (SUBST1_TAC o SYM)
   THEN USE_THEN "F6" (fun th-> (USE_THEN "F4" (MP_TAC o CONJUNCT2 o CONJUNCT2 o  REWRITE_RULE[th] o SPEC `(f:A->B) x`)))
   THEN SIMP_TAC[]);;

(* the detail on faces of quotients *)

let team = new_definition `!(H:(A)hypermap) (L:(A)loop). team H L = {atom H L x |x:A | x inside L}`;;

let lemma_team_eq = prove(`!H:(A)hypermap NF:(A)loop->bool L:(A)loop L':(A)loop. is_normal H NF /\ L IN NF /\ L' IN NF /\ team H L = team H L' ==> L = L'`,
   REPEAT GEN_TAC
   THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F1") (LABEL_TAC "F2"))
   THEN USE_THEN "F1" (MP_TAC o SPEC `L:(A)loop` o CONJUNCT1 o  REWRITE_RULE[is_normal])
   THEN ASM_REWRITE_TAC[]
   THEN DISCH_THEN (MP_TAC o CONJUNCT2)
   THEN DISCH_THEN (X_CHOOSE_THEN `x:A` (LABEL_TAC "F3" o CONJUNCT2))
   THEN SUBGOAL_THEN `atom (H:(A)hypermap) (L:(A)loop) (x:A) IN team H L` MP_TAC
   THENL[REWRITE_TAC[team; IN_ELIM_THM]
      THEN EXISTS_TAC `x:A`
      THEN ASM_REWRITE_TAC[]; ALL_TAC]
   THEN USE_THEN "F2" (SUBST1_TAC o CONJUNCT2 o CONJUNCT2)
   THEN REWRITE_TAC[team; IN_ELIM_THM]
   THEN DISCH_THEN (X_CHOOSE_THEN `y:A` (CONJUNCTS_THEN2 (LABEL_TAC "F4") (LABEL_TAC "F5")))
   THEN MP_TAC(SPECL[`H:(A)hypermap`; `L':(A)loop`; `y:A`] atom_reflect)
   THEN POP_ASSUM (SUBST1_TAC o SYM)
   THEN USE_THEN "F3"(fun th->(DISCH_THEN(fun th1->ASSUME_TAC(MATCH_MP lemma_in_loop (CONJ th th1)))))
   THEN MATCH_MP_TAC disjoint_loops
   THEN EXISTS_TAC `H:(A)hypermap` THEN EXISTS_TAC `NF:(A)loop->bool` THEN EXISTS_TAC `y:A`
   THEN ASM_REWRITE_TAC[]);;

let lemma_team_is_face = prove(`!H:(A)hypermap NF:(A)loop->bool L:(A)loop x:A. is_normal H NF /\ L IN NF /\ x inside L ==> team H L = orbit_map (fmap H NF) (atom  H L x)`, 
   REPEAT GEN_TAC
   THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F1") (CONJUNCTS_THEN2 (LABEL_TAC "F2") (LABEL_TAC "F3")))
   THEN SUBGOAL_THEN `(!m:num u:A v:A. u inside (L:(A)loop) /\ v inside L /\ v = ((next L) POWER m) u ==> (?j:num. atom (H:(A)hypermap) L v = ((fmap H (NF:(A)loop->bool)) POWER j) (atom H L u)))` (LABEL_TAC "F4")
   THENL[INDUCT_TAC
      THENL[REWRITE_TAC[POWER_0; I_THM]
	 THEN REPEAT STRIP_TAC
	 THEN EXISTS_TAC `0`
	 THEN POP_ASSUM SUBST1_TAC
	 THEN REWRITE_TAC[POWER_0; I_THM]; ALL_TAC]
      THEN POP_ASSUM (LABEL_TAC "G1")
      THEN REPEAT GEN_TAC
      THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "G2") (CONJUNCTS_THEN2 (LABEL_TAC "G3") (LABEL_TAC "G4")))
      THEN ASM_CASES_TAC `next (L:(A)loop) (u:A) = inverse (node_map (H:(A)hypermap)) u`
      THENL[MP_TAC (SPECL[`H:(A)hypermap`; `L:(A)loop`; `u:A`] atom_reflect)
	 THEN DISCH_THEN(fun th->POP_ASSUM(fun th1->MP_TAC(MATCH_MP lemma_atom_absorb_quark (CONJ th th1))))
	 THEN DISCH_THEN (SUBST1_TAC o MATCH_MP lemma_identity_atom)
	 THEN USE_THEN "G2" (ASSUME_TAC o REWRITE_RULE[POWER_1] o  SPEC `1` o MATCH_MP lemma_power_next_in_loop)
	 THEN REMOVE_THEN "G4" (ASSUME_TAC o REWRITE_RULE[POWER; o_THM])
	 THEN ABBREV_TAC `z = (next (L:(A)loop) (u:A))`
	 THEN REMOVE_THEN "G1" (MP_TAC o SPECL[`z:A`; `v:A`])
	 THEN ASM_REWRITE_TAC[]; ALL_TAC]
      THEN POP_ASSUM MP_TAC THEN MP_TAC (SPECL[`H:(A)hypermap`; `L:(A)loop`; `u:A`] atom_reflect)
      THEN USE_THEN "G2" MP_TAC THEN USE_THEN "F2" MP_TAC THEN USE_THEN "F1" MP_TAC
      THEN REWRITE_TAC[IMP_IMP; GSYM CONJ_ASSOC]
      THEN DISCH_THEN (ASSUME_TAC o MATCH_MP lemma_unique_head)
      THEN USE_THEN "F1"(fun th->USE_THEN "F2"(fun th1->(USE_THEN "G2" (fun th2 -> MP_TAC(MATCH_MP unique_fmap (CONJ th (CONJ th1 th2)))))))
      THEN USE_THEN "F1"(fun th->USE_THEN "F2"(fun th1->(USE_THEN "G2" (fun th2 -> MP_TAC(MATCH_MP value_next_of_head (CONJ th (CONJ th1 th2)))))))
      THEN POP_ASSUM SUBST1_TAC
      THEN DISCH_THEN (SUBST1_TAC o SYM)
      THEN USE_THEN "G2" (ASSUME_TAC o REWRITE_RULE[POWER_1] o  SPEC `1` o MATCH_MP lemma_power_next_in_loop)
      THEN DISCH_THEN (LABEL_TAC "G5")
      THEN REMOVE_THEN "G4" (ASSUME_TAC o REWRITE_RULE[POWER; o_THM])
      THEN ABBREV_TAC `z = (next (L:(A)loop) (u:A))`
      THEN REMOVE_THEN "G1" (MP_TAC o SPECL[`z:A`; `v:A`])
      THEN ASM_REWRITE_TAC[]
      THEN DISCH_THEN (X_CHOOSE_THEN `k:num` MP_TAC)
      THEN REMOVE_THEN "G5" (SUBST1_TAC o SYM)
      THEN REWRITE_TAC[iterate_map_valuation2]
      THEN MESON_TAC[]; ALL_TAC]
   THEN SUBGOAL_THEN `!m:num x:A. x inside (L:(A)loop) ==> ?y:A. y inside L /\ ((fmap (H:(A)hypermap) (NF:(A)loop->bool)) POWER m) (atom H L x) = atom H L y` (LABEL_TAC "F5")
   THENL[INDUCT_TAC
       THENL[REPEAT STRIP_TAC THEN EXISTS_TAC `x':A` THEN ASM_REWRITE_TAC[POWER_0; I_THM]; ALL_TAC]
       THEN GEN_TAC
       THEN POP_ASSUM (LABEL_TAC "G4")
       THEN DISCH_THEN (LABEL_TAC "G5")
       THEN REWRITE_TAC[COM_POWER; o_THM]
       THEN REMOVE_THEN "G5" (fun th-> (REMOVE_THEN "G4" (MP_TAC o REWRITE_RULE[th] o  SPEC `x':A`)))
       THEN DISCH_THEN (X_CHOOSE_THEN `a:A` (CONJUNCTS_THEN2 (LABEL_TAC "G6") (SUBST1_TAC)))
       THEN EXISTS_TAC `(face_map (H:(A)hypermap)) (head H (NF:(A)loop->bool) (a:A))`
       THEN USE_THEN "F1"(fun th->(USE_THEN "F2"(fun th1->(USE_THEN "G6"(fun th2->REWRITE_TAC[MATCH_MP face_map_on_margin (CONJ th (CONJ th1 th2))])))))
       THEN MATCH_MP_TAC unique_fmap
       THEN ASM_REWRITE_TAC[]; ALL_TAC]
   THEN REWRITE_TAC[EXTENSION]
   THEN GEN_TAC
   THEN REWRITE_TAC[team; orbit_map; IN_ELIM_THM; GE; LE_0]
   THEN EQ_TAC
   THENL[DISCH_THEN (X_CHOOSE_THEN `y:A` (CONJUNCTS_THEN2 (LABEL_TAC "F6") (SUBST1_TAC)))
       THEN USE_THEN "F3"(fun th->(USE_THEN "F6"(fun th1->(MP_TAC (MATCH_MP lemma_next_power_representation (CONJ th th1))))))
       THEN DISCH_THEN (X_CHOOSE_THEN `n:num` (ASSUME_TAC o CONJUNCT2))
       THEN REMOVE_THEN "F4" (MP_TAC o SPECL[`n:num`; `x:A`; `y:A`])
       THEN ASM_MESON_TAC[]; ALL_TAC]
   THEN STRIP_TAC
   THEN POP_ASSUM SUBST1_TAC
   THEN POP_ASSUM (MP_TAC o SPECL[`n:num`; `x:A`])
   THEN USE_THEN "F3" (fun th-> REWRITE_TAC[th]));;

let lemma_face_set_via_teams = prove(`!H:(A)hypermap NF:(A)loop->bool L:(A)loop. is_normal H NF ==> face_set (quotient H NF) = {team H L | L IN NF}`,
   REPEAT GEN_TAC
   THEN DISCH_THEN (LABEL_TAC "F1")
   THEN REWRITE_TAC[EXTENSION; face_set; set_of_orbits; IN_ELIM_THM]
   THEN GEN_TAC
   THEN REWRITE_TAC[GSYM EXTENSION]
   THEN USE_THEN "F1"(fun th-> REWRITE_TAC[MATCH_MP lemma_quotient th])
   THEN EQ_TAC
   THENL[REWRITE_TAC[quotient_darts; IN_ELIM_THM]
      THEN DISCH_THEN (X_CHOOSE_THEN `atm:A->bool` (CONJUNCTS_THEN2 MP_TAC (SUBST1_TAC)))
      THEN DISCH_THEN(X_CHOOSE_THEN `L:(A)loop`(X_CHOOSE_THEN `y:A` (CONJUNCTS_THEN2 (CONJUNCTS_THEN2 (LABEL_TAC "F2") (LABEL_TAC "F3")) SUBST1_TAC)))
      THEN EXISTS_TAC `L:(A)loop`
      THEN ASM_REWRITE_TAC[]
      THEN CONV_TAC SYM_CONV
      THEN MATCH_MP_TAC lemma_team_is_face
      THEN ASM_REWRITE_TAC[]; ALL_TAC]
   THEN DISCH_THEN(X_CHOOSE_THEN `L:(A)loop`(CONJUNCTS_THEN2 (LABEL_TAC "F2") SUBST1_TAC))
   THEN USE_THEN "F2" (fun th-> (USE_THEN "F1" (MP_TAC o REWRITE_RULE[th] o SPEC `L:(A)loop` o  CONJUNCT1  o REWRITE_RULE[is_normal])))
   THEN DISCH_THEN ((X_CHOOSE_THEN `x:A` (LABEL_TAC "F3" o CONJUNCT2)) o CONJUNCT2)
   THEN EXISTS_TAC `atom (H:(A)hypermap) (L:(A)loop) (x:A)`
   THEN STRIP_TAC
   THENL[MATCH_MP_TAC lemma_in_quotient THEN ASM_REWRITE_TAC[]; ALL_TAC]
   THEN MATCH_MP_TAC lemma_team_is_face THEN ASM_REWRITE_TAC[]);;


let res = new_definition `!f:A->A s:A->bool x:A. res f s x = if x IN s then f x else x`;;

let lemma_in_face = prove(`!(H:(A)hypermap) x:A n:num. ((face_map H) POWER n) x IN face H x`, REWRITE_TAC[face; lemma_in_orbit]);;

let face_map_restrict = prove(`!(H:(A)hypermap) x:A.  res (face_map H) (face H x) permutes face H x`,
   REPEAT GEN_TAC THEN REWRITE_TAC[permutes] THEN SIMP_TAC[res]
   THEN GEN_TAC THEN REWRITE_TAC[EXISTS_UNIQUE]
   THEN ASM_CASES_TAC `~((y:A) IN face (H:(A)hypermap) x)`
   THENL[EXISTS_TAC `y:A` 
      THEN ASM_REWRITE_TAC[]
      THEN GEN_TAC
      THEN ASM_CASES_TAC `~(y':A IN face (H:(A)hypermap) x)`
      THENL[ASM_REWRITE_TAC[]; ALL_TAC]
      THEN POP_ASSUM (ASSUME_TAC o REWRITE_RULE[])
      THEN ASM_REWRITE_TAC[]
      THEN POP_ASSUM (SUBST_ALL_TAC o MATCH_MP lemma_face_identity)
      THEN DISCH_TAC
      THEN MP_TAC(REWRITE_RULE[POWER_1] (SPECL[`H:(A)hypermap`; `y':A`; `1`] lemma_in_face))
      THEN POP_ASSUM SUBST1_TAC
      THEN ASM_REWRITE_TAC[]; ALL_TAC]
   THEN POP_ASSUM (LABEL_TAC "F1" o REWRITE_RULE[])
   THEN POP_ASSUM (SUBST1_TAC o MATCH_MP lemma_face_identity)
   THEN MP_TAC (MATCH_MP inverse_element_lemma (SPEC `H:(A)hypermap` face_map_and_darts))
   THEN DISCH_THEN (X_CHOOSE_THEN `j:num` (fun th -> (ASSUME_TAC (AP_THM th `y:A`))))
   THEN MP_TAC (SPECL[`H:(A)hypermap`; `y:A`; `j:num`] lemma_in_face)
   THEN POP_ASSUM (SUBST1_TAC o SYM)
   THEN DISCH_TAC
   THEN EXISTS_TAC `inverse (face_map (H:(A)hypermap)) y`
   THEN ASM_REWRITE_TAC[]
   THEN REWRITE_TAC[MATCH_MP PERMUTES_INVERSES (CONJUNCT2 (SPEC `H:(A)hypermap` face_map_and_darts))]
   THEN GEN_TAC
   THEN ASM_CASES_TAC `~(y':A IN face (H:(A)hypermap) y)`
   THENL[ASM_REWRITE_TAC[]
       THEN DISCH_THEN (SUBST_ALL_TAC)
       THEN POP_ASSUM (MP_TAC o REWRITE_RULE[face; orbit_reflect])
       THEN MESON_TAC[]; ALL_TAC]
   THEN POP_ASSUM (ASSUME_TAC o REWRITE_RULE[])
   THEN ASM_REWRITE_TAC[]
   THEN MESON_TAC[face_map_inverse_representation]);;

let power_res_face_map = prove(`!(H:(A)hypermap) x:A n:num. ((res (face_map H) (face H x)) POWER n) x = ((face_map H) POWER n) x`,
  REPLICATE_TAC 2 GEN_TAC
    THEN INDUCT_TAC
    THENL[REWRITE_TAC[POWER_0; orbit_reflect]; ALL_TAC]
    THEN MP_TAC(SPECL[`H:(A)hypermap`; `x:A`; `n:num`] lemma_in_face)
    THEN ABBREV_TAC `y = (face_map (H:(A)hypermap) POWER n) x`
    THEN DISCH_TAC
    THEN REWRITE_TAC[COM_POWER; o_THM]
    THEN ASM_REWRITE_TAC[res]);;

let face_loop = new_definition `!H:(A)hypermap x:A. face_loop H x = loop(face H x, res (face_map H) (face H x))`;;

let face_collection = new_definition `!H:(A)hypermap. face_collection H = {face_loop H x |x:A| x IN dart H}`;;

let face_loop_rep = prove(`!(H:(A)hypermap) x:A. dart_of (face_loop H x) = face H x /\ next (face_loop H x) = res (face_map H) (face H x)`,
  REPEAT GEN_TAC
    THEN REWRITE_TAC[face_loop]
    THEN MATCH_MP_TAC lemma_loop_representation
    THEN EXISTS_TAC `x:A`
    THEN REWRITE_TAC[FACE_FINITE; face_map_restrict]
    THEN REWRITE_TAC[orbit_map; power_res_face_map; face]);;

let lemma_inverse_res = prove(`!(H:(A)hypermap) x:A y:A. y IN face H x ==> inverse (res (face_map H) (face H x))  y = inverse(face_map H) y`,
    REPEAT STRIP_TAC
    THEN REWRITE_TAC[face_loop]
    THEN POP_ASSUM (SUBST1_TAC o MATCH_MP lemma_face_identity)
    THEN REWRITE_TAC[GSYM face_loop]
    THEN MP_TAC (MATCH_MP inverse_element_lemma (SPEC `H:(A)hypermap` face_map_and_darts)) 
    THEN DISCH_THEN (X_CHOOSE_THEN `j:num` (LABEL_TAC "F0"))
    THEN USE_THEN "F0" (MP_TAC o SPEC `face_map (H:(A)hypermap)` o  MATCH_MP RIGHT_MULT_MAP)
    THEN REWRITE_TAC[MATCH_MP PERMUTES_INVERSES_o (CONJUNCT2(SPEC `H:(A)hypermap` face_map_and_darts))]
    THEN REWRITE_TAC[GSYM (CONJUNCT2 POWER)]
    THEN DISCH_THEN (LABEL_TAC "F1" o SYM)
    THEN SUBGOAL_THEN `(res (face_map (H:(A)hypermap)) (face H y)) POWER (SUC j) = I` ASSUME_TAC
    THENL[REWRITE_TAC[FUN_EQ_THM;I_THM]
       THEN GEN_TAC
       THEN ASM_CASES_TAC `~(x:A IN face (H:(A)hypermap) (y:A))`
       THENL[MATCH_MP_TAC power_permutation_outside_domain
	 THEN EXISTS_TAC `face (H:(A)hypermap) y`
	 THEN ASM_REWRITE_TAC[face_map_restrict; FACE_FINITE]; ALL_TAC] 
       THEN POP_ASSUM (MP_TAC o REWRITE_RULE[])
       THEN DISCH_THEN (SUBST1_TAC o MATCH_MP lemma_face_identity)
       THEN REWRITE_TAC[power_res_face_map]
       THEN POP_ASSUM (fun th-> MP_TAC (AP_THM th `x:A`))
       THEN REWRITE_TAC[I_THM]; ALL_TAC]   
    THEN POP_ASSUM (MP_TAC o SPEC `inverse(res (face_map (H:(A)hypermap)) (face H y))` o  MATCH_MP RIGHT_MULT_MAP)
    THEN REWRITE_TAC[POWER; I_O_ID; GSYM o_ASSOC]
    THEN REWRITE_TAC[MATCH_MP PERMUTES_INVERSES_o (SPECL[`H:(A)hypermap`; `y:A`] face_map_restrict); I_O_ID]
    THEN DISCH_THEN (LABEL_TAC "F3")
    THEN POP_ASSUM (SUBST1_TAC o SYM)
    THEN REMOVE_THEN "F0" (SUBST1_TAC)
    THEN REWRITE_TAC[power_res_face_map]);;

let face_loop_lemma = prove(`!(H:(A)hypermap) x:A. is_loop H (face_loop H x)`,
  REPEAT STRIP_TAC
    THEN REWRITE_TAC[is_loop; inside; face_loop_rep]
    THEN REPEAT STRIP_TAC
    THEN ASM_REWRITE_TAC[res]
    THEN REWRITE_TAC[one_step_contour]);;

let edge_nondegenerate = new_definition `!(H:(A)hypermap). edge_nondegenerate H <=> (!x:A. x IN dart H  ==> ~(edge_map H x = x))`;;

let lemma_edge_nondegenerate = prove(`!(H:(A)hypermap). edge_nondegenerate H <=> (!x:A. x IN dart H ==> ~(face_map H x = (inverse (node_map H)) x))`,
   REWRITE_TAC[edge_nondegenerate] THEN  MESON_TAC[edge_nondegenerate; lemma_edge_degenarate]);;

let normal_face_collection = prove(`!(H:(A)hypermap). (!x:A. x IN dart H ==> (?y:A.y IN dart H /\ y IN face H x /\ ~(node H x = node H y))) ==> is_normal H (face_collection H)`,
   REPEAT GEN_TAC
   THEN REWRITE_TAC[is_normal]
   THEN DISCH_THEN (LABEL_TAC "F2")
   THEN STRIP_TAC
   THENL[GEN_TAC
      THEN REWRITE_TAC [face_collection; IN_ELIM_THM; inside]
      THEN STRIP_TAC
      THEN POP_ASSUM SUBST1_TAC
      THEN REWRITE_TAC[face_loop_lemma]
      THEN EXISTS_TAC `x:A`
      THEN ASM_REWRITE_TAC[face; orbit_reflect; face_loop_rep]; ALL_TAC]
   THEN STRIP_TAC
   THENL[GEN_TAC
     THEN REWRITE_TAC [face_collection; IN_ELIM_THM; inside]
     THEN STRIP_TAC
     THEN POP_ASSUM SUBST1_TAC
     THEN REWRITE_TAC[face_loop_rep]
     THEN EXISTS_TAC `x:A`
     THEN REWRITE_TAC[face; orbit_reflect]
     THEN REWRITE_TAC[GSYM face]
     THEN USE_THEN "F2" (fun thm->(POP_ASSUM (fun th-> MESON_TAC[MATCH_MP thm th]))); ALL_TAC]
   THEN STRIP_TAC
   THENL[REPEAT GEN_TAC
     THEN REWRITE_TAC [face_collection; IN_ELIM_THM; inside]
     THEN DISCH_THEN (CONJUNCTS_THEN2 (X_CHOOSE_THEN `y:A` (CONJUNCTS_THEN2 ASSUME_TAC (LABEL_TAC "G1"))) (CONJUNCTS_THEN2 (X_CHOOSE_THEN `z:A` (CONJUNCTS_THEN2 ASSUME_TAC (LABEL_TAC "G2"))) MP_TAC))
     THEN REMOVE_THEN "G1" SUBST_ALL_TAC
     THEN REMOVE_THEN "G2" SUBST_ALL_TAC
     THEN REWRITE_TAC[face_loop_rep]
     THEN STRIP_TAC
     THEN REWRITE_TAC[face_loop]
     THEN POP_ASSUM (SUBST1_TAC o MATCH_MP lemma_face_identity)
     THEN POP_ASSUM (SUBST1_TAC o MATCH_MP lemma_face_identity)
     THEN SIMP_TAC[]; ALL_TAC]
   THEN REPEAT GEN_TAC
   THEN REWRITE_TAC [face_collection;IN_ELIM_THM; inside]
   THEN DISCH_THEN (CONJUNCTS_THEN2 (X_CHOOSE_THEN `z:A` (CONJUNCTS_THEN2 ASSUME_TAC ASSUME_TAC)) MP_TAC)
   THEN POP_ASSUM SUBST1_TAC
   THEN REWRITE_TAC[face_loop_rep]
   THEN POP_ASSUM (LABEL_TAC "H1")
   THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "H2") (LABEL_TAC "H3"))
   THEN EXISTS_TAC `face_loop (H:(A)hypermap) y`
   THEN REWRITE_TAC[face_loop_rep; face; orbit_reflect]
   THEN EXISTS_TAC `y:A`
   THEN SIMP_TAC[]
   THEN USE_THEN "H1" (MP_TAC o MATCH_MP lemma_face_subset)
   THEN USE_THEN "H2" (SUBST1_TAC o MATCH_MP lemma_face_identity)
   THEN REWRITE_TAC[face]
   THEN DISCH_THEN (fun th-> MP_TAC (MATCH_MP lemma_in_subset (CONJ th (SPECL[`face_map (H:(A)hypermap)`; `x:A`] orbit_reflect))))
   THEN DISCH_THEN (MP_TAC o MATCH_MP lemma_node_subset)
   THEN USE_THEN "H3" (SUBST_ALL_TAC o MATCH_MP lemma_node_identity)
   THEN DISCH_THEN (fun th-> (POP_ASSUM(fun th1 -> REWRITE_TAC[MATCH_MP lemma_in_subset (CONJ th th1)]))));;

let lemma_support_face_collection = prove(`!(H:(A)hypermap). support_darts (face_collection H) = dart H`,
 GEN_TAC
   THEN REWRITE_TAC[EXTENSION]
   THEN GEN_TAC
   THEN REWRITE_TAC[lemma_in_support]
   THEN REWRITE_TAC[face_collection; IN_ELIM_THM]
   THEN EQ_TAC
   THENL[STRIP_TAC
      THEN POP_ASSUM MP_TAC
      THEN POP_ASSUM SUBST1_TAC
      THEN REWRITE_TAC[inside; face_loop_rep]
      THEN POP_ASSUM (MP_TAC o MATCH_MP lemma_face_subset)
      THEN REWRITE_TAC[IMP_IMP; lemma_in_subset]; ALL_TAC]
   THEN STRIP_TAC
   THEN EXISTS_TAC `face_loop (H:(A)hypermap) x`
   THEN REWRITE_TAC[inside; face; face_loop_rep; orbit_reflect]
   THEN EXISTS_TAC `x:A`
   THEN ASM_REWRITE_TAC[]);;

let lemma_card_face_collection = prove(`!(H:(A)hypermap). FINITE (face_collection H) /\ CARD (face_collection H) = number_of_faces H`,
  GEN_TAC
  THEN SUBGOAL_THEN `?t:(A->bool)->(A)loop.(!s:(A->bool).s IN face_set H ==> ?x:A.x IN dart H /\ s = face (H:(A)hypermap) x /\ t s = face_loop H x)` MP_TAC
  THENL[REWRITE_TAC[GSYM SKOLEM_THM]
      THEN GEN_TAC
      THEN REWRITE_TAC[GSYM RIGHT_IMP_EXISTS_THM]
      THEN DISCH_THEN (MP_TAC o MATCH_MP lemma_face_representation)
      THEN STRIP_TAC
      THEN REWRITE_TAC[SWAP_EXISTS_THM]
      THEN EXISTS_TAC `x:A`
      THEN EXISTS_TAC `face_loop (H:(A)hypermap) (x:A)`
      THEN ASM_REWRITE_TAC[]; ALL_TAC]
   THEN DISCH_THEN (X_CHOOSE_THEN `t:(A->bool)->(A)loop` (LABEL_TAC "F1"))
   THEN SUBGOAL_THEN `IMAGE (t:(A->bool)->(A)loop) (face_set (H:(A)hypermap)) = (face_collection H)` (LABEL_TAC "F2")
   THENL[REWRITE_TAC[IMAGE; face_collection; face_set; EXTENSION; IN_ELIM_THM]
      THEN GEN_TAC
      THEN EQ_TAC
      THENL[REWRITE_TAC[set_of_orbits; IN_ELIM_THM]
	  THEN REWRITE_TAC[GSYM face]
	  THEN STRIP_TAC
	  THEN EXISTS_TAC `x'':A`
	  THEN POP_ASSUM SUBST1_TAC
	  THEN POP_ASSUM SUBST1_TAC
	  THEN ASM_REWRITE_TAC[]
	  THEN USE_THEN "F1" (MP_TAC o SPEC `face (H:(A)hypermap) x''`)
	  THEN POP_ASSUM (fun th -> ASSUME_TAC th THEN REWRITE_TAC[REWRITE_RULE[lemma_in_face_set] th])
	  THEN STRIP_TAC
	  THEN ASM_REWRITE_TAC[]
	  THEN REWRITE_TAC[face_loop]
	  THEN ASM_REWRITE_TAC[]; ALL_TAC]
      THEN DISCH_THEN (X_CHOOSE_THEN `y:A` (CONJUNCTS_THEN2 (LABEL_TAC "G1") SUBST1_TAC))
      THEN REWRITE_TAC[set_of_orbits; IN_ELIM_THM; GSYM face]
      THEN EXISTS_TAC `face (H:(A)hypermap) (y:A)`
      THEN STRIP_TAC THENL[EXISTS_TAC `y:A` THEN ASM_REWRITE_TAC[]; ALL_TAC]
      THEN USE_THEN "F1" (MP_TAC o SPEC `face (H:(A)hypermap) (y:A)`)
      THEN USE_THEN "G1" (fun th -> REWRITE_TAC[REWRITE_RULE[lemma_in_face_set] th])
      THEN STRIP_TAC
      THEN POP_ASSUM SUBST1_TAC
      THEN REWRITE_TAC[face_loop]
      THEN ASM_REWRITE_TAC[]; ALL_TAC]
   THEN SUBGOAL_THEN `FINITE (face_collection (H:(A)hypermap))` (LABEL_TAC "F3")
   THENL[ POP_ASSUM (SUBST1_TAC o SYM)
      THEN MATCH_MP_TAC FINITE_IMAGE THEN REWRITE_TAC[FINITE_HYPERMAP_ORBITS]; ALL_TAC]
   THEN ASM_REWRITE_TAC[] THEN REWRITE_TAC[number_of_faces] THEN REMOVE_THEN "F2" (SUBST1_TAC o SYM)
   THEN MATCH_MP_TAC CARD_IMAGE_INJ THEN REWRITE_TAC[FINITE_HYPERMAP_ORBITS]
   THEN REPEAT GEN_TAC THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F4") (CONJUNCTS_THEN2 (LABEL_TAC "F5") (LABEL_TAC "F6")))
   THEN REMOVE_THEN "F4" (fun th -> USE_THEN "F1" (fun thm -> MP_TAC (MATCH_MP thm th))) THEN STRIP_TAC
   THEN REMOVE_THEN "F5" (fun th -> USE_THEN "F1" (fun thm -> MP_TAC (MATCH_MP thm th)))
   THEN STRIP_TAC THEN ASM_REWRITE_TAC[] THEN REMOVE_THEN "F6" MP_TAC
   THEN POP_ASSUM SUBST1_TAC
   THEN UNDISCH_THEN `(t:(A->bool)->(A)loop) x = face_loop (H:(A)hypermap) (x')` SUBST1_TAC
   THEN DISCH_THEN (MP_TAC o AP_TERM `dart_of:(A)loop->(A->bool)`)
   THEN REWRITE_TAC[face_loop_rep]);;

let face_refl = prove(`!(H:(A)hypermap) x:A. x IN face H x`, REWRITE_TAC[face; orbit_reflect]);;

let lemma_inverse_in_face = prove(`!(H:(A)hypermap) (x:A) (y:A). y IN face H x ==> inverse (face_map H) y IN face H x`,
    REPEAT STRIP_TAC
    THEN POP_ASSUM (SUBST1_TAC o MATCH_MP lemma_face_identity)
    THEN REPEAT GEN_TAC
    THEN MP_TAC (MATCH_MP inverse_element_lemma (SPEC `H:(A)hypermap` face_map_and_darts))
    THEN DISCH_THEN(X_CHOOSE_THEN `j:num` SUBST1_TAC)
    THEN REWRITE_TAC[lemma_in_face]);;

let SING_EQ = prove(`!x:A y:A. {x} = {y} <=> x = y`, SET_TAC[IN_SING]);;

let face_quotient_lemma = prove(`!(H:(A)hypermap). edge_nondegenerate H /\ (!x:A. x IN dart H ==> (?y:A. y IN dart H /\ y IN face H x /\ ~(node H x = node H y))) ==> (!x:A. choice H (face_collection H) x = {x}) /\ H iso (quotient H (face_collection H))`,
  GEN_TAC
   THEN REWRITE_TAC[lemma_edge_nondegenerate]
   THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F1") (LABEL_TAC "F2"))
   THEN USE_THEN "F2"(LABEL_TAC "F3" o MATCH_MP normal_face_collection)
   THEN SUBGOAL_THEN `!x:A. choice (H:(A)hypermap) (face_collection H) x = {x}` (LABEL_TAC "F4")
   THENL[GEN_TAC
      THEN ASM_CASES_TAC `~(x:A IN dart (H:(A)hypermap))`
      THENL[POP_ASSUM (ASSUME_TAC o REWRITE_RULE[GSYM lemma_support_face_collection])
	 THEN USE_THEN "F3" (MP_TAC o SPEC `x:A` o  CONJUNCT1 o MATCH_MP first_unique_choice)
	 THEN ASM_REWRITE_TAC[]; ALL_TAC]
      THEN POP_ASSUM (LABEL_TAC "G4" o REWRITE_RULE[])
      THEN USE_THEN "G4" (MP_TAC o REWRITE_RULE[GSYM lemma_support_face_collection])
      THEN USE_THEN "F3" (fun th -> REWRITE_TAC[GSYM(MATCH_MP lemma_choice_in_quotient th)])
      THEN REWRITE_TAC[quotient_darts; IN_ELIM_THM]
      THEN DISCH_THEN (X_CHOOSE_THEN `L:(A)loop` (X_CHOOSE_THEN `y:A` (CONJUNCTS_THEN2 (CONJUNCTS_THEN2 (LABEL_TAC "G5") (LABEL_TAC "G6")) (LABEL_TAC "G7"))))
      THEN USE_THEN "G5" (MP_TAC o REWRITE_RULE[face_collection; IN_ELIM_THM])
      THEN DISCH_THEN (X_CHOOSE_THEN `z:A` (CONJUNCTS_THEN2 (LABEL_TAC "G8") (LABEL_TAC "G9")))
      THEN USE_THEN "F3" (MP_TAC o SPEC `x:A` o MATCH_MP  choice_reflect)
      THEN REMOVE_THEN "G7" SUBST1_TAC
      THEN USE_THEN "G6" (MP_TAC o REWRITE_RULE[inside])
      THEN USE_THEN "G9" SUBST1_TAC
      THEN REWRITE_TAC[face_loop_rep]
      THEN DISCH_THEN (LABEL_TAC "G10")
      THEN DISCH_THEN (LABEL_TAC "G11")
      THEN SUBGOAL_THEN `~(next (L:(A)loop) y = inverse (node_map (H:(A)hypermap)) y)` MP_TAC
      THENL[USE_THEN "G9" (fun th-> REWRITE_TAC[th])
	 THEN REWRITE_TAC[face_loop_rep]
	 THEN USE_THEN "G10" (fun th-> REWRITE_TAC[res; th])
	 THEN USE_THEN "F1" (MP_TAC o SPEC `y:A`)
	 THEN USE_THEN "G8" (MP_TAC o MATCH_MP lemma_face_subset)
	 THEN DISCH_THEN (fun th -> (USE_THEN "G10" (fun th1-> (LABEL_TAC "G12" (MATCH_MP lemma_in_subset (CONJ th th1))))))
	 THEN USE_THEN "G12" (fun th-> REWRITE_TAC[th]); ALL_TAC]
      THEN MP_TAC(SPECL[`H:(A)hypermap`; `L:(A)loop`; `y:A`] atom_reflect)
      THEN USE_THEN "G6" MP_TAC THEN USE_THEN "G5" MP_TAC THEN USE_THEN "F3" MP_TAC
      THEN REWRITE_TAC[IMP_IMP; GSYM CONJ_ASSOC]
      THEN DISCH_THEN (LABEL_TAC "G14" o MATCH_MP lemma_unique_head)
      THEN SUBGOAL_THEN `~(y = inverse (node_map (H:(A)hypermap)) (back (L:(A)loop) y))` MP_TAC
      THENL[ONCE_REWRITE_TAC[lemma_inverse_on_loop]
	 THEN REWRITE_TAC[face_loop_rep]
	 THEN USE_THEN "G9" SUBST1_TAC
	 THEN REWRITE_TAC[face_loop_rep]
	 THEN USE_THEN "G10" (fun th-> REWRITE_TAC[MATCH_MP lemma_inverse_res th])
	 THEN USE_THEN "G10" (ASSUME_TAC o MATCH_MP lemma_inverse_in_face)
	 THEN ABBREV_TAC `t = inverse (face_map (H:(A)hypermap)) y`
	 THEN POP_ASSUM (SUBST1_TAC o REWRITE_RULE[GSYM face_map_inverse_representation] o SYM)
	 THEN USE_THEN "F1" (MP_TAC o SPEC `t:A`)
	 THEN USE_THEN "G8" (MP_TAC o MATCH_MP lemma_face_subset)
	 THEN DISCH_THEN (fun th -> (POP_ASSUM (fun th1-> (ASSUME_TAC (MATCH_MP lemma_in_subset (CONJ th th1))))))
	 THEN POP_ASSUM (fun th-> REWRITE_TAC[th]); ALL_TAC]
      THEN MP_TAC(SPECL[`H:(A)hypermap`; `L:(A)loop`; `y:A`] atom_reflect)
      THEN USE_THEN "G6" MP_TAC THEN USE_THEN "G5" MP_TAC THEN USE_THEN "F3" MP_TAC
      THEN REWRITE_TAC[IMP_IMP; GSYM CONJ_ASSOC]
      THEN DISCH_THEN (MP_TAC o SYM o MATCH_MP lemma_unique_tail)
      THEN POP_ASSUM(fun th-> (DISCH_THEN (fun th1 -> (ASSUME_TAC (MATCH_MP EQ_TRANS (CONJ th th1))))))
      THEN POP_ASSUM MP_TAC THEN USE_THEN "G6" MP_TAC THEN USE_THEN "G5" MP_TAC THEN USE_THEN "F3" MP_TAC
      THEN REWRITE_TAC[IMP_IMP; GSYM CONJ_ASSOC]
      THEN DISCH_THEN (MP_TAC o SYM o MATCH_MP atom_one_point)
      THEN DISCH_TAC
      THEN REMOVE_THEN "G11" MP_TAC
      THEN USE_THEN "G9" (SUBST1_TAC o SYM)
      THEN POP_ASSUM (SUBST1_TAC o SYM)
      THEN REWRITE_TAC[IN_SING]
      THEN DISCH_THEN SUBST1_TAC THEN SIMP_TAC[]; ALL_TAC]
   THEN ASM_REWRITE_TAC[]
   THEN REWRITE_TAC[iso]
   THEN USE_THEN "F3" (fun th -> REWRITE_TAC[MATCH_MP lemma_quotient th])
   THEN EXISTS_TAC `(\x:A. {x})`
   THEN STRIP_TAC
   THENL[REWRITE_TAC[BIJ]
      THEN STRIP_TAC
      THENL[REWRITE_TAC[INJ]
	  THEN STRIP_TAC
	  THENL[GEN_TAC
	      THEN REWRITE_TAC[GSYM lemma_support_face_collection]
	      THEN USE_THEN "F3" (fun th-> REWRITE_TAC[GSYM(MATCH_MP lemma_choice_in_quotient th)])
	      THEN USE_THEN "F3" (fun th -> REWRITE_TAC[MATCH_MP lemma_quotient th])
	      THEN USE_THEN "F4" (fun th -> REWRITE_TAC[th]); ALL_TAC]
	      THEN MESON_TAC[SING_EQ]; ALL_TAC]
          THEN REWRITE_TAC[SURJ]
          THEN STRIP_TAC      
          THENL[GEN_TAC
	     THEN REWRITE_TAC[GSYM lemma_support_face_collection]
	     THEN USE_THEN "F3" (fun th-> REWRITE_TAC[GSYM(MATCH_MP lemma_choice_in_quotient th)])
	     THEN USE_THEN "F3" (fun th -> REWRITE_TAC[MATCH_MP lemma_quotient th])
	     THEN USE_THEN "F4" (fun th -> REWRITE_TAC[th]); ALL_TAC]
          THEN GEN_TAC
          THEN USE_THEN "F3" (fun th-> REWRITE_TAC[MATCH_MP atom_via_choice th])
          THEN REWRITE_TAC[lemma_support_face_collection]
          THEN USE_THEN "F4" (fun th -> REWRITE_TAC[th])
          THEN MESON_TAC[]; ALL_TAC]
   THEN REWRITE_TAC[]
   THEN SUBGOAL_THEN `!x:A. x IN dart (H:(A)hypermap) ==>  nmap H (face_collection H) {x} = {node_map H x}` (LABEL_TAC "F5")
   THENL[REWRITE_TAC[GSYM lemma_support_face_collection] 
       THEN GEN_TAC
       THEN DISCH_THEN (LABEL_TAC "G1")
       THEN USE_THEN "F4" (fun th -> REWRITE_TAC[GSYM th])
       THEN USE_THEN "F3"(fun th-> (USE_THEN "G1" (fun th1-> REWRITE_TAC[MATCH_MP nmap_via_choice (CONJ th th1)])))
       THEN USE_THEN "F4" (fun th -> REWRITE_TAC[th])
       THEN USE_THEN "F3" (fun th-> MP_TAC(CONJUNCT1(SPEC `x:A` (GSYM(MATCH_MP choice_at_margin th)))))
       THEN USE_THEN "F4" (fun th -> REWRITE_TAC[th; SING_EQ])
       THEN DISCH_THEN (fun th-> REWRITE_TAC[th]); ALL_TAC]
   THEN SUBGOAL_THEN `!x:A. x IN dart (H:(A)hypermap) ==>  fmap H (face_collection H) {x} = {face_map H x}` (LABEL_TAC "F6")
   THENL[REWRITE_TAC[GSYM lemma_support_face_collection]
       THEN GEN_TAC
       THEN DISCH_THEN (LABEL_TAC "G1")
       THEN USE_THEN "F4" (fun th -> REWRITE_TAC[GSYM th])
       THEN USE_THEN "F3"(fun th-> (USE_THEN "G1" (fun th1-> REWRITE_TAC[MATCH_MP fmap_via_choice (CONJ th th1)])))
       THEN USE_THEN "F4" (fun th -> REWRITE_TAC[th])
       THEN USE_THEN "F3" (fun th-> MP_TAC(CONJUNCT2(SPEC `x:A` (GSYM(MATCH_MP choice_at_margin th)))))
       THEN USE_THEN "F4" (fun th -> REWRITE_TAC[th; SING_EQ])
       THEN DISCH_THEN (fun th-> REWRITE_TAC[th]); ALL_TAC]
   THEN ASM_REWRITE_TAC[]
   THEN GEN_TAC
   THEN DISCH_THEN (LABEL_TAC "F7")
   THEN USE_THEN "F7"(fun th-> (USE_THEN "F5"(fun thm -> REWRITE_TAC[MATCH_MP thm th])))
   THEN USE_THEN "F7"(fun th-> (USE_THEN "F6"(fun thm -> REWRITE_TAC[MATCH_MP thm th])))
   THEN REWRITE_TAC [o_THM]
   THEN USE_THEN "F3" (fun th -> REWRITE_TAC[GSYM(MATCH_MP lemma_quotient th)])
   THEN CONV_TAC SYM_CONV
   THEN REWRITE_TAC[GSYM face_map_inverse_representation]
   THEN CONV_TAC SYM_CONV
   THEN REWRITE_TAC[GSYM node_map_inverse_representation]
   THEN USE_THEN "F3" (fun th -> REWRITE_TAC[MATCH_MP lemma_quotient th])
   THEN USE_THEN "F7" (LABEL_TAC "F8" o CONJUNCT1 o MATCH_MP lemma_dart_invariant)
   THEN USE_THEN "F8" (fun th-> (USE_THEN "F6" (fun thm -> REWRITE_TAC[MATCH_MP thm th])))
   THEN USE_THEN "F8" (LABEL_TAC "F9" o CONJUNCT2 o CONJUNCT2 o  MATCH_MP lemma_dart_invariant)
   THEN USE_THEN "F9" (fun th-> (USE_THEN "F5" (fun thm -> REWRITE_TAC[MATCH_MP thm th])))
   THEN MP_TAC (AP_THM (CONJUNCT1 (SPEC `H:(A)hypermap` hypermap_cyclic)) `x:A`)
   THEN DISCH_THEN (MP_TAC o SYM o REWRITE_RULE[o_THM; I_THM])
   THEN REWRITE_TAC[SING_EQ]);;

let is_gen_flag = new_definition `!(H:(A)hypermap) (S:A->bool) (flag:(A->bool)->bool). is_gen_flag H S flag <=> (flag SUBSET face_set H) /\ (S SUBSET dart H) /\ (!x:A y:A. x IN UNIONS flag /\ y IN UNIONS flag ==> (?p:num->A n:num. p 0 = x /\ p n = y /\ (!i:num. 0 < i /\ i < n ==> (p i) IN UNIONS flag))) /\ (!x:A. x IN dart H ==> (?y:A. y IN edge H x /\ (y IN UNIONS flag \/ y IN S)))`;;

let is_flag = new_definition `!(H:(A)hypermap) (flag:(A->bool)->bool). is_flag H flag <=> (flag SUBSET face_set H) /\ (!x:A y:A. x IN UNIONS flag /\ y IN UNIONS flag ==> (?p:num->A n:num. p 0 = x /\ p n = y /\ (!i:num. 0 < i /\ i < n ==> (p i) IN UNIONS flag))) /\ (!x:A. x IN dart H ==> (?y:A. y IN edge H x /\ y IN UNIONS flag ))`;;

let canon = new_definition `!(H:(A)hypermap) (NF:(A)loop->bool). canon H NF = {qf:(A->bool)->bool | qf IN face_set (quotient H NF) /\ (!s:A->bool. s IN qf ==> CARD s = 1)}`;;

let set_one_point = prove(`!s:A->bool x:A. FINITE s /\ CARD s = 1 /\ x IN s ==> s = {x}`,
 REPEAT GEN_TAC
   THEN DISCH_THEN(CONJUNCTS_THEN2 (LABEL_TAC "F1") (CONJUNCTS_THEN2 (LABEL_TAC "F2") (LABEL_TAC "F3")))
   THEN USE_THEN "F1" (MP_TAC o SPEC `x:A` o MATCH_MP CARD_DELETE)
   THEN ASM_REWRITE_TAC[SUB_REFL]
   THEN USE_THEN "F1" (MP_TAC o SPEC `x:A` o MATCH_MP FINITE_DELETE_IMP)
   THEN REWRITE_TAC[IMP_IMP; GSYM HAS_SIZE; HAS_SIZE_0]
   THEN DISCH_TAC
   THEN USE_THEN "F3" (fun th-> MP_TAC th THEN MP_TAC (MATCH_MP INSERT_DELETE th))
   THEN POP_ASSUM SUBST1_TAC
   THEN ASM_REWRITE_TAC[EQ_SYM]);;

let lemma_in_team2 = prove(`!(H:(A)hypermap) (L:(A)loop) (x:A). x inside L ==> atom H L x IN team H L`, REWRITE_TAC[team; IN_ELIM_THM] THEN MESON_TAC[]);;


let lemma_canonical_function = prove(`!(H:(A)hypermap) (NF:(A)loop->bool). is_normal H NF ==> (!t:(A->bool)->bool. t IN canon H NF  <=> (?L:(A)loop. L IN NF /\ t = team H L /\ (!x:A. x inside L ==> L = face_loop H x /\ atom H L x = {x})))`,
   REPEAT GEN_TAC THEN DISCH_THEN (LABEL_TAC "F1") THEN GEN_TAC
   THEN EQ_TAC
   THENL[REWRITE_TAC[canon; IN_ELIM_THM; IN_ELIM_THM]
       THEN DISCH_THEN (CONJUNCTS_THEN2 MP_TAC (LABEL_TAC "F2"))
       THEN USE_THEN "F1"(fun th -> REWRITE_TAC[MATCH_MP lemma_face_set_via_teams th; IN_ELIM_THM])
       THEN DISCH_THEN (X_CHOOSE_THEN `L:(A)loop` (CONJUNCTS_THEN2 (LABEL_TAC "F3") SUBST_ALL_TAC))
       THEN EXISTS_TAC `L:(A)loop`
       THEN ASM_REWRITE_TAC[]
       THEN SUBGOAL_THEN `!y:A. atom (H:(A)hypermap) (L:(A)loop) (y:A) = {y}` (LABEL_TAC "F4")
       THENL[GEN_TAC
	  THEN ASM_CASES_TAC `y:A inside L`
	  THENL[MATCH_MP_TAC set_one_point
             THEN USE_THEN "F2" (MP_TAC o SPEC `atom (H:(A)hypermap) (L:(A)loop) (y:A)`)
	     THEN POP_ASSUM (fun th -> REWRITE_TAC[MATCH_MP lemma_in_team2 th])
	     THEN DISCH_THEN (fun th-> REWRITE_TAC[th])
	     THEN REWRITE_TAC[lemma_atom_finite; atom_reflect]; ALL_TAC]
	  THEN POP_ASSUM (fun th-> REWRITE_TAC[MATCH_MP lemma_atom_out_side_loop th]); ALL_TAC]
      THEN SUBGOAL_THEN `!z:A. z inside L ==> (!n:num. ((next (L:(A)loop)) POWER n) z = ((face_map (H:(A)hypermap)) POWER n) z)` (LABEL_TAC "F5")
      THENL[REWRITE_TAC[RIGHT_IMP_FORALL_THM]
	 THEN ONCE_REWRITE_TAC[SWAP_FORALL_THM]
	 THEN INDUCT_TAC THENL[REWRITE_TAC[POWER_0]; ALL_TAC]
         THEN GEN_TAC
	 THEN POP_ASSUM (LABEL_TAC "F5")
	 THEN DISCH_THEN (LABEL_TAC "F6")
	 THEN REWRITE_TAC[COM_POWER; o_THM]
	 THEN USE_THEN "F6"(fun th-> (USE_THEN "F5"(fun thm->REWRITE_TAC[SYM(MATCH_MP thm th)])))
	 THEN USE_THEN "F6" (LABEL_TAC "F7" o SPEC `n:num` o MATCH_MP lemma_power_next_in_loop)
	 THEN ABBREV_TAC `a = (next (L:(A)loop) POWER n) z`
	 THEN USE_THEN "F1"(fun th->(USE_THEN "F3"(fun th2->(USE_THEN "F7"(fun th3-> MP_TAC (MATCH_MP value_next_of_head (CONJ th (CONJ th2 th3))))))))
	 THEN USE_THEN "F1"(fun th->(USE_THEN "F3"(fun th2->(USE_THEN "F7"(fun th3-> MP_TAC(CONJUNCT1(MATCH_MP head_on_loop (CONJ th (CONJ th2 th3)))))))))
	 THEN USE_THEN "F4" (fun th -> REWRITE_TAC[th; IN_SING])
	 THEN DISCH_THEN SUBST1_TAC
	 THEN SIMP_TAC[]; ALL_TAC]
      THEN SUBGOAL_THEN `!z:A. z inside L ==>dart_of L = face H z` (LABEL_TAC "F6")
      THENL[GEN_TAC THEN DISCH_THEN (LABEL_TAC "F7")
	 THEN USE_THEN "F7" (fun th-> REWRITE_TAC[MATCH_MP lemma_transitive_permutation th])
	 THEN USE_THEN "F7" (fun th-> USE_THEN "F5"(fun thm-> (MP_TAC ( MATCH_MP thm th))))
	 THEN REWRITE_TAC[face; orbit_map; GE; LE_0]
	 THEN SET_TAC[]; ALL_TAC]
      THEN ASM_REWRITE_TAC[]
      THEN REWRITE_TAC[lemma_loop_identity; face_loop_rep]
      THEN GEN_TAC THEN DISCH_THEN (LABEL_TAC "F7")
      THEN USE_THEN "F7" (fun th-> (USE_THEN "F6"(fun thm-> (LABEL_TAC "F8" (MATCH_MP thm th)))))
      THEN USE_THEN "F8" (fun th-> REWRITE_TAC[th])
      THEN REWRITE_TAC[FUN_EQ_THM]
      THEN GEN_TAC
      THEN ASM_CASES_TAC `~(x':A inside L)`
      THENL[POP_ASSUM (LABEL_TAC "F9")
	 THEN USE_THEN "F9" (fun th-> REWRITE_TAC[MATCH_MP lemma_back_and_next_outside_loop th])
	 THEN POP_ASSUM (MP_TAC o REWRITE_RULE[inside])
	 THEN POP_ASSUM SUBST1_TAC
	 THEN MESON_TAC[res]; ALL_TAC]
      THEN POP_ASSUM (LABEL_TAC "F9" o REWRITE_RULE[])
      THEN USE_THEN "F5"(fun thm -> USE_THEN "F9" (fun th-> REWRITE_TAC[REWRITE_RULE[POWER_1] (SPEC `1` (MATCH_MP thm th))]))
      THEN POP_ASSUM (MP_TAC o REWRITE_RULE[inside])
      THEN POP_ASSUM SUBST1_TAC
      THEN MESON_TAC[res]; ALL_TAC]
   THEN DISCH_THEN (X_CHOOSE_THEN `L:(A)loop` (CONJUNCTS_THEN2 (LABEL_TAC "F2") (CONJUNCTS_THEN2 SUBST1_TAC (LABEL_TAC "F3"))))
   THEN REWRITE_TAC[canon; IN_ELIM_THM]
   THEN USE_THEN "F1" (fun th-> REWRITE_TAC[MATCH_MP lemma_face_set_via_teams th])
   THEN STRIP_TAC THENL[SET_TAC[]; ALL_TAC]
   THEN GEN_TAC
   THEN REWRITE_TAC[team; IN_ELIM_THM]
   THEN STRIP_TAC
   THEN POP_ASSUM SUBST1_TAC
   THEN USE_THEN "F3" (MP_TAC o SPEC `x:A`)
   THEN POP_ASSUM (fun th-> REWRITE_TAC[th])
   THEN DISCH_THEN (SUBST1_TAC o CONJUNCT2)
   THEN REWRITE_TAC[CARD_SINGLETON]);;


let lemmaSTKBEPH = prove(`!(H:(A)hypermap) (NF:(A)loop->bool). is_normal H NF /\ number_of_faces H <= CARD (canon H NF) ==> NF = face_collection H /\ H iso quotient H NF`,
   REPEAT GEN_TAC
   THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "F1") (LABEL_TAC "F2"))
   THEN SUBGOAL_THEN `?t:(A)loop->((A->bool)->bool).(!L:(A)loop.L IN (NF:(A)loop->bool) /\ team (H:(A)hypermap) L IN canon H NF ==> t L = team H L)` MP_TAC
   THENL[REWRITE_TAC[GSYM SKOLEM_THM] THEN GEN_TAC 
       THEN REWRITE_TAC[GSYM RIGHT_IMP_EXISTS_THM]
       THEN STRIP_TAC THEN EXISTS_TAC `team (H:(A)hypermap) (L:(A)loop)` THEN SIMP_TAC[]; ALL_TAC]
   THEN DISCH_THEN(X_CHOOSE_THEN `t:(A)loop->((A->bool)->bool)` (LABEL_TAC "F3"))
   THEN ABBREV_TAC `S = {L:(A)loop | L IN (NF:(A)loop->bool) /\ team (H:(A)hypermap) L IN canon H NF}`
   THEN SUBGOAL_THEN `IMAGE (t:(A)loop->((A->bool)->bool)) (S:(A)loop->bool) = canon (H:(A)hypermap) (NF:(A)loop->bool)` (LABEL_TAC "F4")
   THENL[REWRITE_TAC[EXTENSION] THEN GEN_TAC
       THEN REWRITE_TAC[IMAGE; IN_ELIM_THM]
       THEN EQ_TAC
       THENL[DISCH_THEN (X_CHOOSE_THEN `L:(A)loop` (CONJUNCTS_THEN2 MP_TAC SUBST1_TAC))
	  THEN EXPAND_TAC "S"
	  THEN REWRITE_TAC[IN_ELIM_THM]
	  THEN DISCH_THEN (fun th-> (USE_THEN "F3"(fun thm-> REWRITE_TAC[MATCH_MP thm th])) THEN REWRITE_TAC[th]); ALL_TAC]
       THEN DISCH_THEN (fun th -> (LABEL_TAC "F4" th THEN MP_TAC th))
       THEN USE_THEN "F1" (fun th -> REWRITE_TAC[MATCH_MP lemma_canonical_function th])
       THEN DISCH_THEN (X_CHOOSE_THEN `L:(A)loop` (CONJUNCTS_THEN2 (ASSUME_TAC) (SUBST_ALL_TAC o CONJUNCT1)))
       THEN EXISTS_TAC `L:(A)loop`
       THEN EXPAND_TAC "S"
       THEN ASM_REWRITE_TAC[IN_ELIM_THM]
       THEN REMOVE_THEN "F3" (MP_TAC o SPEC `L:(A)loop`)
       THEN ASM_REWRITE_TAC[]
       THEN MESON_TAC[]; ALL_TAC]
   THEN SUBGOAL_THEN `(S:(A)loop->bool) = face_collection (H:(A)hypermap)` (LABEL_TAC "F5")
   THENL[SUBGOAL_THEN `(S:(A)loop->bool) SUBSET face_collection (H:(A)hypermap)` (LABEL_TAC "GG")
      THENL[EXPAND_TAC "S"
         THEN REWRITE_TAC[SUBSET; IN_ELIM_THM]
         THEN GEN_TAC
         THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "G1") (MP_TAC))
         THEN USE_THEN "F1" (fun th-> REWRITE_TAC[MATCH_MP lemma_canonical_function th])
         THEN DISCH_THEN (X_CHOOSE_THEN `L:(A)loop` (CONJUNCTS_THEN2 (LABEL_TAC "G2") (CONJUNCTS_THEN2 MP_TAC (LABEL_TAC "G3"))))
         THEN USE_THEN "G2" MP_TAC THEN USE_THEN "G1" MP_TAC THEN USE_THEN "F1" MP_TAC
         THEN REWRITE_TAC[IMP_IMP; GSYM CONJ_ASSOC]
         THEN DISCH_THEN (SUBST_ALL_TAC o MATCH_MP lemma_team_eq)
         THEN USE_THEN "G1" (fun th -> (USE_THEN "F1" (MP_TAC o REWRITE_RULE[th] o  SPEC `L:(A)loop` o  CONJUNCT1 o REWRITE_RULE[is_normal])))
         THEN DISCH_THEN (MP_TAC o CONJUNCT2)
         THEN DISCH_THEN (X_CHOOSE_THEN `x:A` (CONJUNCTS_THEN2 (LABEL_TAC "G4") (LABEL_TAC "G5")))
         THEN REWRITE_TAC[face_collection; IN_ELIM_THM]
         THEN EXISTS_TAC `x:A`
         THEN USE_THEN "G3" (MP_TAC o SPEC `x:A`)
         THEN ASM_MESON_TAC[]; ALL_TAC]
      THEN MP_TAC (SPEC `H:(A)hypermap` lemma_card_face_collection)
      THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "G1") (LABEL_TAC "G2"))
      THEN USE_THEN "G1"(fun th->(USE_THEN "GG"(fun th1->(MP_TAC(MATCH_MP FINITE_SUBSET (CONJ th th1))))))
      THEN DISCH_THEN (MP_TAC o ISPEC `t:(A)loop->((A->bool)->bool)` o  MATCH_MP CARD_IMAGE_LE)
      THEN REMOVE_THEN "F4" SUBST1_TAC
      THEN REMOVE_THEN "F2" (fun th-> (DISCH_THEN (fun th1 -> MP_TAC (MATCH_MP LE_TRANS (CONJ th  th1)))))
      THEN POP_ASSUM (SUBST1_TAC o SYM)
      THEN USE_THEN "GG"(fun th->(USE_THEN "G1"(fun th1->(MP_TAC(MATCH_MP CARD_SUBSET (CONJ th th1))))))
      THEN REWRITE_TAC[IMP_IMP]
      THEN DISCH_THEN (LABEL_TAC "G3" o REWRITE_RULE[LE_ANTISYM])
      THEN MATCH_MP_TAC CARD_SUBSET_EQ
      THEN ASM_REWRITE_TAC[]; ALL_TAC]
   THEN SUBGOAL_THEN `S:(A)loop->bool SUBSET NF:(A)loop->bool` (LABEL_TAC "F6")
   THENL[EXPAND_TAC "S" THEN SET_TAC[]; ALL_TAC]
   THEN SUBGOAL_THEN `S:(A)loop->bool = NF:(A)loop->bool` (LABEL_TAC "F7")
   THENL[MATCH_MP_TAC SUBSET_ANTISYM
     THEN USE_THEN "F6" (fun th-> REWRITE_TAC[th])
     THEN REWRITE_TAC[SUBSET]
     THEN GEN_TAC THEN DISCH_THEN (LABEL_TAC "G7")
     THEN USE_THEN "G7" (fun th -> (USE_THEN "F1" (MP_TAC o REWRITE_RULE[th] o  SPEC `x:(A)loop` o  CONJUNCT1 o REWRITE_RULE[is_normal])))
     THEN DISCH_THEN (MP_TAC o CONJUNCT2)
     THEN DISCH_THEN (X_CHOOSE_THEN `y:A` (CONJUNCTS_THEN2 (LABEL_TAC "G9") (LABEL_TAC "G10"))) 
     THEN SUBGOAL_THEN `face_loop (H:(A)hypermap) (y:A) IN face_collection H` MP_TAC
     THENL[REWRITE_TAC[face_collection;IN_ELIM_THM]
	 THEN EXISTS_TAC `y:A` THEN USE_THEN "G9" (fun th-> REWRITE_TAC[th]); ALL_TAC]
     THEN REMOVE_THEN "F5" (SUBST1_TAC o SYM)
     THEN DISCH_THEN (LABEL_TAC "G11")
     THEN SUBGOAL_THEN `y:A inside face_loop (H:(A)hypermap) y` (LABEL_TAC "G12")
     THENL[REWRITE_TAC[inside; face_loop_rep; face; orbit_reflect]; ALL_TAC]
     THEN ABBREV_TAC `L' = face_loop (H:(A)hypermap) y`
     THEN SUBGOAL_THEN `x:(A)loop = L'` SUBST1_TAC
     THENL[MATCH_MP_TAC disjoint_loops
        THEN EXISTS_TAC `H:(A)hypermap` THEN EXISTS_TAC `NF:(A)loop->bool` THEN EXISTS_TAC `y:A`
        THEN ASM_REWRITE_TAC[]
        THEN USE_THEN "F6"(fun th-> (USE_THEN "G11" (fun th1-> REWRITE_TAC[MATCH_MP lemma_in_subset (CONJ th th1)]))); ALL_TAC]
     THEN USE_THEN "G11" (fun th -> REWRITE_TAC[th]); ALL_TAC]
    THEN STRIP_TAC
    THEN USE_THEN "F7" (SUBST1_TAC o SYM)
    THENL[USE_THEN "F5" (fun th-> REWRITE_TAC[th]); ALL_TAC]
    THEN SUBGOAL_THEN `edge_nondegenerate (H:(A)hypermap)` (LABEL_TAC "F8")
   THENL[REWRITE_TAC[lemma_edge_nondegenerate]
      THEN GEN_TAC
      THEN DISCH_THEN (LABEL_TAC "G1")
      THEN SUBGOAL_THEN `x:A inside  face_loop (H:(A)hypermap) x`  (LABEL_TAC "G2")
      THENL[REWRITE_TAC[inside; face_loop_rep; face; orbit_reflect]; ALL_TAC]
      THEN SUBGOAL_THEN `face_loop (H:(A)hypermap) x IN face_collection H`  MP_TAC
      THENL[REWRITE_TAC[face_collection; IN_ELIM_THM] THEN EXISTS_TAC `x:A` THEN ASM_REWRITE_TAC[]; ALL_TAC]
      THEN ABBREV_TAC `L = face_loop (H:(A)hypermap) x`
      THEN USE_THEN "F5" (SUBST1_TAC o SYM)
      THEN EXPAND_TAC "S"
      THEN REWRITE_TAC[IN_ELIM_THM]
      THEN DISCH_THEN (CONJUNCTS_THEN2 (LABEL_TAC "G3") MP_TAC)
      THEN USE_THEN "F1"(fun th ->REWRITE_TAC[MATCH_MP lemma_canonical_function th])
      THEN DISCH_THEN (X_CHOOSE_THEN `L':(A)loop` (CONJUNCTS_THEN2 (LABEL_TAC "G4") (CONJUNCTS_THEN2 MP_TAC (LABEL_TAC "G5"))))
      THEN REMOVE_THEN "G4" MP_TAC THEN USE_THEN "G3" MP_TAC THEN USE_THEN "F1" MP_TAC
      THEN REWRITE_TAC[IMP_IMP; GSYM CONJ_ASSOC]
      THEN DISCH_THEN (SUBST_ALL_TAC o SYM o MATCH_MP lemma_team_eq)
      THEN POP_ASSUM (MP_TAC o SPEC `x:A`)
      THEN USE_THEN "G2" (fun th -> REWRITE_TAC[th])
      THEN DISCH_THEN (ASSUME_TAC o CONJUNCT2)
      THEN USE_THEN "F1"(fun th->USE_THEN "G3"(fun th1->(USE_THEN "G2" (fun th2 -> MP_TAC(MATCH_MP value_next_of_head (CONJ th (CONJ th1 th2)))))))
      THEN USE_THEN "F1"(fun th->USE_THEN "G3"(fun th1->(USE_THEN "G2" (fun th2 -> MP_TAC(MATCH_MP head_on_loop (CONJ th (CONJ th1 th2)))))))
      THEN POP_ASSUM SUBST1_TAC
      THEN REWRITE_TAC[IN_SING]
      THEN DISCH_THEN (CONJUNCTS_THEN2 (ASSUME_TAC) (MP_TAC))
      THEN POP_ASSUM SUBST1_TAC
      THEN DISCH_TAC
      THEN DISCH_THEN (SUBST1_TAC o SYM)
      THEN POP_ASSUM (fun th-> REWRITE_TAC[th]); ALL_TAC]
    THEN SUBGOAL_THEN `!x:A. x IN dart H ==> (?y:A. y IN dart H /\ y IN face H x /\ ~(node H x = node H y))` MP_TAC
    THENL[ GEN_TAC
      THEN DISCH_THEN (LABEL_TAC "G1")
      THEN SUBGOAL_THEN `x:A inside face_loop (H:(A)hypermap) x` (LABEL_TAC "G2")
      THENL[REWRITE_TAC[inside; face_loop_rep; face; orbit_reflect]; ALL_TAC]
      THEN SUBGOAL_THEN `face_loop (H:(A)hypermap) x IN face_collection (H:(A)hypermap)` MP_TAC
      THENL[REWRITE_TAC[face_collection; IN_ELIM_THM] THEN EXISTS_TAC `x:A` THEN ASM_REWRITE_TAC[]; ALL_TAC]
      THEN USE_THEN "F5" (SUBST1_TAC o SYM)
      THEN USE_THEN "F7" SUBST1_TAC
      THEN DISCH_THEN (LABEL_TAC "G3")
      THEN REWRITE_TAC[GSYM face_loop_rep; GSYM inside]
      THEN ABBREV_TAC `L = face_loop (H:(A)hypermap) x`
      THEN ONCE_REWRITE_TAC[TAUT `A <=> (~A ==> F)`]
      THEN GEN_REWRITE_TAC (LAND_CONV o TOP_DEPTH_CONV) [NOT_EXISTS_THM; DE_MORGAN_THM; TAUT `~ ~A <=> A`]
      THEN STRIP_TAC
      THEN SUBGOAL_THEN `dart_of (L:(A)loop) SUBSET node (H:(A)hypermap) (x:A)` MP_TAC
      THENL[REWRITE_TAC[SUBSET; GSYM inside]
         THEN GEN_TAC
         THEN POP_ASSUM (LABEL_TAC "G20")
         THEN DISCH_THEN (LABEL_TAC "G21")
         THEN REMOVE_THEN "G20" (MP_TAC o SPEC `x':A`)
         THEN USE_THEN "F1"(fun th->(USE_THEN "G3"(fun th2->(USE_THEN "G21"(fun th3-> ASSUME_TAC (MATCH_MP lemma_in_dart (CONJ th (CONJ th2 th3))))))))
         THEN REPLICATE_TAC 2 (POP_ASSUM (fun th -> REWRITE_TAC[th]))
         THEN DISCH_THEN SUBST1_TAC
         THEN REWRITE_TAC[node; orbit_reflect]; ALL_TAC]
      THEN USE_THEN "F1" (fun th -> (USE_THEN "G3" (fun th1-> REWRITE_TAC[MATCH_MP lemma_loop_outside_node (CONJ th th1)]))); ALL_TAC]
    THEN USE_THEN "F5" SUBST1_TAC
    THEN POP_ASSUM MP_TAC
    THEN REWRITE_TAC[IMP_IMP]
    THEN DISCH_THEN (fun th-> REWRITE_TAC[MATCH_MP face_quotient_lemma th]));;



prioritize_real();;