(* ========================================================================== *)
(* FLYSPECK - BOOK FORMALIZATION                                              *)
(*                                                                            *)
(* Chapter: Linear Programs                                         *)
(* Author: Thomas C. Hales                                                    *)
(* Date: 2010-08-01                                                           *)
(* ========================================================================== *)

(* Linear Programs for the hard cases.  Individual case runs *)

flyspeck_needs "nonlinear/parse_ineq.hl";;
flyspeck_needs "nonlinear/temp_ineq.hl";;
flyspeck_needs "../glpk/tame_archive/lpproc.ml";;

module Lp_case_analysis = struct

  open Lpproc;;
  open Hard_lp;;
  open List;;
  open Sphere_math;;
  open Temp_ineq;;  (* needs to be open for referencing in external files to work properly!  *)

(* Experimental section from here to the end of the file to eliminate final cases. *)
  let tmpfile = Filename.temp_file "display_ampl_" ".dat";;

Lpproc.archiveraw := "/Users/thomashales/Desktop/workspace/hanoi_workshop_files/tame_archive_svn1830.txt";;

let display_ampl =
   fun bb -> Glpk_link.display_ampl tmpfile Lpproc.ampl_of_bb bb;;

let display_lp bb = Glpk_link.display_lp 
  Lpproc.model tmpfile Lpproc.glpk_outfile Lpproc.ampl_of_bb bb ;;

let remake_model = 
  let bodyfile =  Filename.temp_file "body_" ".mod" in
  let m = Lpproc.model in
  fun () ->
    let _ = Lpproc.modelbody := bodyfile in
    let _ = Parse_ineq.output_string bodyfile (Parse_ineq.lpstring()) in    
    let _ = Sys.chdir(tame_dir) in
      Sys.command("cp head.mod "^m^"; cat "^bodyfile^" >> "^
                     m^"; cat tail.mod >> "^m);;

remake_model();;

let hardid = Lpproc.hardid;;

let hard_string_rep = 
   List.find_all (fun s -> mem (fst (Glpk_link.convert_to_list s)) hardid) 
   (Glpk_link.strip_archive (!Lpproc.archiveraw));;

let hard_bb =  
  let r = map Lpproc.mk_bb hard_string_rep in
  map (fun t -> let u = Hard_lp.resolve t in (Hard_lp.add_hints_force u; u)) r;;

let hard i = List.nth hard_bb i;;
(* map mk_gif hard_bb;; *)

(* restart Aug 2, 2010 *)

let allpass_hint = Hard_lp.allpass_hint;;
let onepass_hint = Hard_lp.onepass_hint;;

(* this eliminates case 11 *)
let b34970074286() = allpass_hint 500 [hard 11];;

(* this eliminates case 10, about 5000 linear programs *)

let b75641658977() = 
  let b1 = allpass_hint 500 [hard 10] in
  let b2 = allpass_hint 500 b1 in
  let b3 = allpass_hint 500 b2 in
  let b4 = allpass_hint 500 b3 in
  let b5 = allpass_hint 500 b4 in
    b5;;

(* hard 9 88089363170 *)
resetc();;
let b1 = allpass_hint 500 [hard 9];;
let b3 = allpass_hint 20 b1;;
let bx = nth b3 0;;
#print_length 600;;
 (fun t-> (t.hints = [])) b3);;
bx;;
sorted_azim_diff darts_of_std_tri bx;; 
sorted_azim_weighted_diff (fun bb -> rotation (bb.apex_flat))  bx;; 
get_azim_table [0;3;5] bx;;
get_azim_table [4;5;3] bx;;
get_azim_table [0;1;3] bx;;
let iqd = hd(Ineq.getexact "5000076558");;
let fn = Temp_ineq.ocaml_eval iqd;;
fn 2. 2. 2. 2.52 2. 2.;;
let ii = generate_ineq_datum_p "Dihedral2" "{2,2,2.3,2.52,2,2.2}"
 "{2,2,2,2.25,2,2}" "{2.52,2.52,2.52,sqrt8,2.52,2.52}";;
let tempval = ref junkval;;
 fn 

(* OLD experiments *)

#print_length 600;;;
let bx = hd b2;;
bx;; (* 12.001 *)
sorted_azim_diff darts_of_std_tri bx;; 
get_azim_table [2;0;1] bx;;
get_azim_table [2;3;0] bx;;
get_azim_table [2;1;4] bx;;
let ii = hd(Ineq.getexact "7409690040");;
ocaml_fun_of_ineq  ii.ineq;;
let fxx = (fun y1 y2 y3 y4 y5 y6 -> ( dih2_y y1 y2 y3 y4 y5 y6  +. 0.0042) -. (0.952682 +. (((-. 0.268837) *. ((-. 2.36) +. y1)) +. ((0.130607 *. ((-. 2.) +. y2)) +. (((-. 0.168729) *. ((-. 2.) +. y3)) +. (((-. 0.0831764) *. ((-. 2.52) +. y4)) +. ((0.580152 *. ((-. 2.) +. y5)) +. (0.0656612 *. ((-. 2.25) +. y6)))))))));;
testval fxx [2;0;1] bx;;
remake_model();;
resolve amx2;;  (* 2.063 *)
add_hints_force amx2;;


(* <= Jul 31 2010 *)

let tests = ref [];;

(* std4_diag3 disappears: *)
length hard_bb;;  (* 12 *)


let testsuper _ = 
  let allhardpassA_bb = allpass 3 hard_bb in 
  let allhardpassS_bb =  (filter (fun t -> length t.std4_diag3 >0) allhardpassA_bb) in
  let allhardpassF_bb =  filter (fun t -> ( length t.std4_diag3 = 0) && (length t.apex_sup_flat > 0))  allhardpassA_bb in 
    allhardpassS_bb = [] && allhardpassF_bb = [];; 

tests := testsuper :: !tests;;

(* July 29 , 2010  "161847242261" starts out 12.06... *)
let b1 = onepass_hint [hard 0];;
let b2 = allpass_prune_hint 15 [hard 0];;
let b3 = allpass_prune_hint 15 b2;;
let b4 = allpass_prune_hint 15 b3;;
let b5 = allpass_prune_hint 15 b4;;
map (fun bb -> bb.hints) b5;;
let c1 = find_max b5;;  (* runs out of hints at this stage, length of b5 is only 8 *)

(* 223336279535, starts out at 12.130 *)
let a1 = onepass_hint [hard 1];;
let a2 = allpass_prune_hint 5 15 [hard 1];;
let a3 = allpass_prune_hint 5 15 a2;;
find_max (!onepass_backup);;

(* see where this goes....  July 29, 2010, stack started at 145 *)
let a_test_july29 = allpass_prune_hint 40 80 hard_bb;;
let a0 = a_test_july29;;
map (fun bb -> bb.hints) a0;; (* no hints left *)
let amx = find_max (a0);;
map (fun bb -> bb.hypermap_id) a0;;
get_azim_table [4;5;3] amx;;
get_azim_table [0;3;5] amx;;
 (fun bb -> (bb.node_200_218,bb.node_218_236,bb.node_236_252)) amx;;
fst(chop_list 15 (sorted_azim_diff darts_of_std_tri amx));;


darts_of_std_tri;;
find_max (!onepass_backup);;

#print_length 600;;
amx;;
let amx2 =   {hypermap_id = "154005963125"; lpvalue = None; hints = [];
   diagnostic = No_data;
   string_rep =
    "154005963125 20 4 0 1 2 3 4 0 3 4 5 3 4 3 2 3 4 2 6 3 6 2 7 3 7 2 1 3 7 1 8 3 8 1 9 3 9 1 0 3 9 0 5 3 9 5 10 3 10 5 11 3 11 5 4 3 11 4 6 3 11 6 12 3 12 6 7 3 12 7 8 3 12 8 10 3 8 9 10 3 10 11 12 ";
   std_faces_not_super =
    [[4; 3; 2]; [4; 2; 6]; [6; 2; 7]; [7; 2; 1]; [7; 1; 8]; [8; 1; 9];
     [9; 1; 0]; [9; 0; 5]; [9; 5; 10]; [10; 5; 11]; [11; 5; 4]; [11; 4; 6];
     [11; 6; 12]; [12; 6; 7]; [12; 7; 8]; [12; 8; 10]; [8; 9; 10];
     [10; 11; 12]];
   std56_flat_free = []; std4_diag3 = [];
   std3_big = [[7; 1; 8]; [9; 1; 0]; [9; 0; 5]; [8; 1; 9]; [9; 5; 10]];
   std3_small =
    [[11; 4; 6]; [6; 2; 7]; [10; 11; 12]; [11; 6; 12]; [12; 6; 7];
     [12; 7; 8]; [7; 2; 1]; [4; 2; 6]; [11; 5; 4]; [12; 8; 10]; [10; 5; 11];
     [8; 9; 10]; [4; 3; 2]];
   apex_sup_flat = [];
   apex_flat = [[4; 5; 3]; [0; 3; 5]; [2; 3; 1]; [0; 1; 3]]; apex_A = [];
   apex5 = []; apex4 = [];
   d_edge_225_252 = [[5; 9; 0]; [9; 1; 0]; [9; 5; 10]; [1; 9; 8]];
   d_edge_200_225 =
    [[11; 4; 6]; [4; 6; 11]; [6; 11; 4]; [6; 2; 7]; [2; 7; 6]; [7; 6; 2];
     [10; 11; 12]; [11; 12; 10]; [12; 10; 11]; [11; 6; 12]; [6; 12; 11];
     [12; 11; 6]; [12; 6; 7]; [6; 7; 12]; [7; 12; 6]; [12; 7; 8]; [7; 8; 12];
     [8; 12; 7]; [7; 2; 1]; [2; 1; 7]; [1; 7; 2]; [4; 2; 6]; [2; 6; 4];
     [6; 4; 2]; [11; 5; 4]; [5; 4; 11]; [4; 11; 5]; [7; 1; 8]; [8; 7; 1];
     [1; 8; 7]; [12; 8; 10]; [8; 10; 12]; [10; 12; 8]; [0; 5; 9]; [9; 0; 5];
     [10; 5; 11]; [5; 11; 10]; [11; 10; 5]; [8; 9; 10]; [9; 10; 8];
     [10; 8; 9]; [0; 9; 1]; [1; 0; 9]; [10; 9; 5]; [8; 1; 9]; [9; 8; 1];
     [5; 10; 9]; [4; 3; 2]; [3; 2; 4]; [2; 4; 3]];
   node_218_252 = [3]; node_236_252 = [3]; node_218_236 = [];
   node_200_218 = [6; 11; 12; 7; 2; 0; 4; 10; 5; 9; 1; 8]};;

(* amx2;; 2.1878 *)
resolve amx2;;
add_hints_force amx2;;
sorted_azim_diff darts_of_std_tri amx2;; 
sorted_azim_weighted_diff (fun bb -> rotation (bb.apex_flat))  amx2;; 
(* [(0.17937279505957382, [3; 4; 5]); (0.129169044058939808, [5; 3; 4]);
   (0.115889948342437377, [5; 0; 3]); (0.101279767307688728, [1; 3; 0]);
   (0.101279767307671298, [1; 2; 3]); (0.081429255816779289, [0; 3; 5]);];; *)
(* added new ineq 4750199435 *)
resolve amx2;;  (* 2.1718 *)
add_hints_force amx2;;
sorted_azim_diff darts_of_std_tri amx2;; 
sorted_azim_weighted_diff (fun bb -> rotation (bb.apex_flat))  amx2;; 
amx2;;
get_azim_table [4;5;3] amx2;;
get_azim_table [0;3;5] amx2;;
get_azim_table [0;1;3] amx2;;
get_azim_table [2;3;1] amx2;;
let f00 = (fun y1 y2 y3 y4 y5 y6 -> (( Sphere_math.dih2_y y1 y2 y3 y4 y5 y6  -.  1.083) +. (((0.6365 *. (y1 -.  2.)) -.  (0.198 *. (y2 -.  2.))) +. ((0.352 *. (y3 -.  2.)) +. (((0.416 *. (y4 -.  2.52)) -.  (0.66 *. (y5 -.  2.))) +. (0.071 *. (y6 -.  2.)))))) -. 0.);;

let dih2_y = Sphere_math.dih2_y;;

ocaml_fun_of_ineq i8384511215.ineq;;
let fxx = (fun y1 y2 y3 y4 y5 y6 -> ( dih2_y y1 y2 y3 y4 y5 y6  +. 0.0015) -. (0.913186 +. (((-. 0.390288) *. ((-. 2.) +. y1)) +. ((0.115895 *. ((-. 2.) +. y2)) +. ((0.164805 *. ((-. 2.52) +. y3)) +. (((-. 0.271329) *. ((-. 2.82843) +. y4)) +. ((0.584817 *. ((-. 2.) +. y5)) +. ((-. 0.170218) *. ((-. 2.) +. y6)))))))));;

testval f00 [4;5;3] amx2;;

remake_model();;
resolve amx2;;  (* 2.063 *)
add_hints_force amx2;;
sorted_azim_diff darts_of_std_tri amx2;; 
sorted_azim_weighted_diff (fun bb -> rotation (bb.apex_flat))  amx2;; 
get_azim_table[8;1;9] amx2;;
get_azim_table[0;5;9] amx2;;
get_azim_table[0;9;1] amx2;;
ocaml_fun_of_ineq  i7819193535.ineq;;
let fxx = (fun y1 y2 y3 y4 y5 y6 -> ( dih2_y y1 y2 y3 y4 y5 y6  +. 0.0011) -. (1.16613 +. (((-. 0.296776) *. ((-. 2.) +. y1)) +. ((0.208935 *. ((-. 2.) +. y2)) +. (((-. 0.243302) *. ((-. 2.) +. y3)) +. (((-. 0.360575) *. ((-. 2.25) +. y4)) +. ((0.636205 *. ((-. 2.) +. y5)) +. ((-. 0.295156) *. ((-. 2.) +. y6)))))))));;
testval fxx [8;1;9] amx2;;

remake_model();;
resolve amx2;;  (* 2.056 *)
add_hints_force amx2;;
sorted_azim_diff darts_of_std_tri amx2;; 
sorted_azim_weighted_diff (fun bb -> rotation (bb.apex_flat))  amx2;; 
get_azim_table[0;3;5] amx2;;
get_azim_table[0;5;9] amx2;;
get_azim_table[0;9;1] amx2;;
ocaml_fun_of_ineq i2621779878.ineq;;
let fxx = (fun y1 y2 y3 y4 y5 y6 -> ( dih2_y y1 y2 y3 y4 y5 y6  +. 0.0011) -. (1.16613 +. (((-. 0.296776) *. ((-. 2.) +. y1)) +. ((0.208935 *. ((-. 2.) +. y2)) +. (((-. 0.243302) *. ((-. 2.) +. y3)) +. (((-. 0.360575) *. ((-. 2.25) +. y4)) +. ((0.636205 *. ((-. 2.) +. y5)) +. ((-. 0.295156) *. ((-. 2.) +. y6)))))))));;
testval fxx [8;1;9] amx2;;

(* material from 2009 *)
(* case 86506100695 *)
let h86 _ =
  let h86 = [findid "86506100695" hard_bb] in
  let h86a = allpass 10 h86 in
  let h86b = allpass 10  h86a in
    allvpass h86b = [];;
tests := h86 :: !tests;;


(* the 2 pressed icosahedra remain *)

let hard2_bb = filter (fun t -> mem t.hypermap_id ["161847242261";"223336279535"]) hard_bb;;


length hard2_bb;;
let h16 = allvpass (findall "161847242261" hard_bb);;
let h16max = find_max h16;;  (* 12.0627 *)
let b16 = h16;;
let b16a = all_highvpass b16;;
length b16a;;
let b16Amax = find_max b16a;; (* 12.0627 *)
let b16b =   (one_epass b16a);;
let b16c  = one_epass (one_epass b16b);;
let b16d = one_epass b16c;;
length b16d;;
let b16e = find_max b16d;;   (* 12.051 *)
0;; (* -- *)
let c16a= allpass 10 b16d;;
let c16Amax = find_max c16a;; (* 12.048 *)  (* was 12.059 *)
length c16a;;  (* 997 *)
let c16b = allpass 15 c16a;;
let c16Bmax = find_max c16b;;  (* 12.026 *) (* was 12.037 *)
length c16b;;  (* 657 *) (* was 636 *)


(*

(* this one is a dodecahedron modified with node 2 pressed
    into an edge *)
  let h  = findid (nth hardid 3);;  (* 12223336279535  *)
  let h1 = allpass [h];;
  length h1;;   (* length 1885 *)
  let k1 = find_max h1;;  (* 12.0416 *)
  let h2 = onevpassi h1 2;; (* length h2 : 2637 *)
(* unfinished... *)

(* this one is triangles only, types {6,0}, {4,0}, {6,0}. *)
  let r  = findid (nth hardid 5);;  (* 12161847242261  *)
  length r1;;   (* length  *)
  let r1 = allvpass [r];;
  let r2 = allpass r1;;
(* unfinished *)

*)




(*
let allhardpassB_bb = allpass 8 hard2_bb;;
*)

(*
let hard2_bb = [nth  hard_bb 0;nth hard_bb 1];;
(* to here *)

length (allhardpassB_bb);;  (* 288 *)
let h16 = find_max allhardpassB_bb;;
(* unfinished *)
*)

(*
let h0 = nth hard_bb 0;;
let h1 = 
  let s i l= flatten((map (fun t -> switch_node t i)) l) in
  let branches =   s 4(  s 3(  s 2(  s 1 (s 0 [h0])) ) )  in
   filter_feas branches;;
length h1;;
find_max h1;;
let all16_bb = allpass 6 h1;;
(* unfinished *)
*)


end;;