(*
 *
 * Copyright (c) 2012-2018,
 *  Wes Weimer          <weimerw@umich.edu>
 *  Stephanie Forrest   <steph@asu.edu>
 *  Claire Le Goues     <clegoues@cs.cmu.edu>
 *  Eric Schulte        <eschulte@cs.unm.edu>
 *  Jeremy Lacomis      <jlacomis@cmu.edu>
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are
 * met:
 *
 * 1. Redistributions of source code must retain the above copyright
 * notice, this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright
 * notice, this list of conditions and the following disclaimer in the
 * documentation and/or other materials provided with the distribution.
 *
 * 3. The names of the contributors may not be used to endorse or promote
 * products derived from this software without specific prior written
 * permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
 * IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
 * TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
 * PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER
 * OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 *)
(* diff processor
 * Take a diff script generated by cdiff describing
 * changes to be made to transform one file to the other.
 * Using the verbose_node_info hashtable from cdiff
 * (presumably this module is being used by repair) and
 * the sourcereader tool, make the line-level edits appropriate
 * to transform the original file into the repaired one. *)
open Global
open Sourcereader
open Cdiff

let whitespace = Str.regexp "[ \t\n]*"

(* Should we include trailing brackets after statements, as the
 * lines after which we do an insert? *)
let enable_bracket_inclusion = false

(* Should we be even smarter, and count the number of opening brackets
 * as a limit to the number of closing ones we include? This is not
 * necessarily always better, as it might not be the intended spot,
 * and if opening brackets are included in the code as something other
 * than block delimiters, they will be counted if they are surrounded
 * by whitespace. *)
let enable_smart_bracket_inclusion = false

(* Should we try to find the nearest good node to a bad one,
 * or just flag it and ignore this repair? (Maybe just completely
 * stop the program in these cases, or report something about it in
 * the script
 * NOTE: Backtracking up to the parent node will still be done with
 * this, but if the parent and all its children are bad, we won't try
 * to find the nearest good one if this is disabled. *)
let enable_nearest_good_node_search = false

(* This global variable will hold the list of scripts, to be passed as
 * the argument to Sourcereader's repair_files (from note_success) *)
let repair_script_list = ref []

(* Insert: lines of text, at line #
 * Delete: Range of lines to delete
 * Move: lines of text to insert, line # to insert them,
 *       line range being moved (deleted)
 * All: string to keep a record of the text being affected *)
type final_action =
  | Insert of string * string list * int * string list
  | Delete of string * (int * int) * string list
  | Move of string * string list * int * (int * int) * string list
  | Nop of int

let final_action_list = ref []

(* Stores a lot of information about the node *)
type cdiff_node = {
  id : int ;
  filename : string ;
  first_line : int ;
  last_line : int ;
  cil_txt : string list ;
  orig_txt : string list ;
}

let node_id_to_cdiff_node = Hashtbl.create 255
let bad_node_id_to_cdiff_node = Hashtbl.create 255

(* Print out the actions in a readable format. *)
let debug_action_list () = begin
  List.iter(fun x ->
      match x with
        Insert(fn,text,line,text_rec) ->
        Printf.printf "~ Insert, in file %s:\n" fn ;
        List.iter (fun x -> Printf.printf "%s\n" x) text;
        Printf.printf "~ at line %d\n" line
      |  Delete(fn,(first,last),text_rec) ->
        Printf.printf "~ Delete lines %d through %d in file %s\n" first last fn
      |  Move(fn,text,line,(first,last),text_rec) ->
        Printf.printf "~ Move lines %d through %d to line %d in file %s\n" first last line fn
      |  Nop(line) -> ()) !final_action_list
end

(* Print out the cdiff nodes *)
let debug_cdiff_nodes () = begin
  Hashtbl.iter (fun x y ->
      Printf.printf "\nNode %d\n------\n" y.id;
      Printf.printf "%s %d %d\n" y.filename y.first_line y.last_line;
      List.iter (fun z -> Printf.printf "%s\n" z) y.orig_txt;
      Printf.printf "--CIL STMT:--\n";
      List.iter (fun q -> Printf.printf "%s\n" q) y.cil_txt) node_id_to_cdiff_node
end

let debug_bad_cdiff_nodes () = begin
  Hashtbl.iter (fun x y ->
      Printf.printf "\nBad Node %d\n------\n" y.id;
      Printf.printf "--CIL STMT:--\n";
      List.iter (fun q -> Printf.printf "%s\n" q) y.cil_txt) bad_node_id_to_cdiff_node
end

(* get_nearest_good_node
 * Gets the closest previous node with a valid line number of
 * a given node and returns it.
 * INPUT: Node ID to Node Hashtbl
 * INPUT: ID of a bad node *)
let get_nearest_good_node ht node_id = begin
  if Hashtbl.mem node_id_to_cdiff_node node_id then
    (Hashtbl.find node_id_to_cdiff_node node_id)
  else begin
    let id_count = ref node_id in
    while not (Hashtbl.mem node_id_to_cdiff_node !id_count) do
      decr id_count;
      (* Extraordinarily unlikely but this could result in infinite loop *)
    done;
    let parent_node = Hashtbl.find ht !id_count in
    let found_flag = ref false in
    let found_id = ref parent_node.nid in
    let the_id =
      (* We have to make sure the children are valid. If not we have to
       * backtrack to the parent. *)
      if (Array.length parent_node.children)>0 then
        (
          for i=((Array.length parent_node.children)-1) downto 0 do
            let possible_val = Array.get parent_node.children i in
            if not (!found_flag) then
              (
                if Hashtbl.mem node_id_to_cdiff_node possible_val then
                  (found_flag := true; found_id := possible_val)
              )
          done;
          !found_id
        )
      else
        !id_count
    in
    (Hashtbl.find node_id_to_cdiff_node the_id)
  end
end

(* NOTE: An alternative to this strategy is to count the number
 * of opening brackets contained already in the statement.
 * Then count the number of closing ones. Take the difference
 * as the number of trailing closing brackets to try to include,
 * or something like that. *)

(* Returns the last line containing only brackets after
 * a given line. Utility function to include extra lines
 * for inserts after a statement which does not include
 * proper closing brackets. NOTE: Needs more thought... *)
let get_last_bracket_line filename starting_line = begin
  (* TODO: Smart bracket inclusion. Count the number of opening and closing
   * brackets. If opening - closing = 0, then don't do any more inclusion.
   * If opening - closing > 0, take the difference as the max number of brackets
   * to include. *)
  (*
    let line_counter = ref starting_line in
    let current_line = ref "" in
    let brackets = ref true in
    begin try
    while (!brackets) do
    current_line := (List.nth !source_code !line_counter);
    let current_line_without_ws = Str.split whitespace !current_line in
    List.iter (fun x -> if x<>"}" then brackets := false) current_line_without_ws;
    if (!brackets) then incr line_counter;
    done;
    ();
    with Failure _ -> ();
    end;
    !line_counter
  *)


  let file_lines = get_lines filename in
  let rec walk current_line =
    (* We have to stop before the end of the file, because an insert after the last line will screw up. *)
    if current_line>=((List.length file_lines)) then begin
      (List.length file_lines)
    end
    else begin
      let this_line = List.nth file_lines current_line in
      if List.for_all (fun x -> x="}") (Str.split whitespace this_line)
      then begin
        walk (current_line+1)
      end
      else begin
        current_line
      end
    end
  in
  walk starting_line

end




let build_action_list fn ht = begin
  (* TODO: Parse the file, and create an action for
   * each line. Action (x,y,z). See cdiff line 834 for
   * a template. This also must include line derivations
   * for "children." Look at notebook for an idea. *)
  let c = open_in fn in
  let the_file = ref "" in
  try
    while true do
      let the_line = input_line c in
      Scanf.sscanf the_line "%s %s %s ( %d , %d , %d )" (fun _ func action x y p ->
          (* bad nodes checking must actually occur here *)
          let xflag = ref true in
          let yflag = ref true in
          let nodeX =
            if Hashtbl.mem node_id_to_cdiff_node x then
              Hashtbl.find node_id_to_cdiff_node x
            else (xflag := false; Hashtbl.find bad_node_id_to_cdiff_node x)
          in
          let nodeY =
            if Hashtbl.mem node_id_to_cdiff_node y then
              Hashtbl.find node_id_to_cdiff_node y
            else (yflag := false; Hashtbl.find bad_node_id_to_cdiff_node y)
          in
          (* Printf.printf "Node %d starts at %d ends at %d\n" nodeX.id nodeX.first_line nodeX.last_line; *)
          let line_to_insert =
            if p=0 then
              let my_node =
                if !yflag then nodeY
                else
                  (
                    if enable_nearest_good_node_search then
                      (get_nearest_good_node ht (nodeY.id))
                    else nodeY
                  )
              in
              the_file := my_node.filename;
              if not (Hashtbl.mem bad_node_id_to_cdiff_node nodeY.id) then
                (
                  let first_bracket_line = ref 0 in
                  let count = ref 0 in
                  List.iter (fun x ->
                      incr count;
                      if (String.contains x '{') then
                        if (!first_bracket_line)=0 then
                          first_bracket_line := !count
                    ) my_node.orig_txt;
                  if (!first_bracket_line)=0 then my_node.first_line
                  else (my_node.first_line + !first_bracket_line)
                ) else my_node.first_line
            else
              (* Get the total number of lines for the next p nodes after node y *)
                    (*
                      let total_lines = ref 0 in
                      for i=1 to p do
                      if (Hashtbl.mem node_id_to_cdiff_node (nodeY.id + i)) then
                      (
                      let theNode = Hashtbl.find node_id_to_cdiff_node (nodeY.id + i) in
                      List.iter (fun aLine ->
                      incr total_lines) theNode.orig_txt
                      )
                      done;
                      (nodeY.first_line + !total_lines)
                    *)

              (* Might want to store thrown out nodes, and if we can't find the parent,
               * consult the nearest x nodes (5 or whatever) to see if the text is the same,
               * and get the line number from that. Or just report that we failed. Boohoo. *)

              (* The parent is good, but the children might not be. *)
            if Hashtbl.mem node_id_to_cdiff_node nodeY.id then begin
              let parent_node = Hashtbl.find ht nodeY.id in
              let counter = ref 1 in
              let child_id = ref 0 in
              let p_temp = ref p in
              let found_flag = ref false in
              while (!p_temp)!=0 do
                counter := 1;
                child_id := 0;
                Array.iter (fun child_ider ->
                    if (!counter)=p then (child_id := child_ider; incr counter) else incr counter;
                  ) parent_node.children ;
                if Hashtbl.mem node_id_to_cdiff_node !child_id then (found_flag := true; p_temp := 0)
                else decr p_temp ;
              done;
              let prev_child =
                if !found_flag then Hashtbl.find node_id_to_cdiff_node !child_id
                else nodeY
              in
              the_file := prev_child.filename;
              if enable_bracket_inclusion then (get_last_bracket_line !the_file prev_child.last_line)
              else (prev_child.last_line)
            end
            (* The parent is no good... Check the children. If everyone is bad, we suck and just
             * get the nearest good one, if that's enabled. Otherwise just get the bad one. *)
            else begin
              let parent_node = Hashtbl.find ht nodeY.id in
              let counter = ref 1 in
              let child_id = ref 0 in
              let p_temp = ref p in
              let found_flag = ref false in
              while (!p_temp)!=0 do
                counter := 1;
                child_id := 0;
                Array.iter (fun child_ider ->
                    if (!counter)=p then (child_id := child_ider; incr counter) else incr counter;
                  ) parent_node.children ;
                if Hashtbl.mem node_id_to_cdiff_node !child_id then (found_flag := true; p_temp := 0)
                else decr p_temp ;
              done;
              let the_node =
                if !found_flag then Hashtbl.find node_id_to_cdiff_node !child_id
                else
                  (
                    if enable_nearest_good_node_search then (get_nearest_good_node ht nodeY.id)
                    else nodeY
                  )
              in
              the_file := the_node.filename;
              if enable_bracket_inclusion then
                (
                  if not (Hashtbl.mem bad_node_id_to_cdiff_node the_node.id) then (get_last_bracket_line !the_file the_node.last_line)
                  else the_node.last_line
                )
              else (the_node.last_line)
            end
          in

          let to_act =
            let header_flag = (String.get (!the_file) 0)='/' in
            if header_flag then debug "Header touched. Repair cannot be automatically applied!\n";
            match String.lowercase action with
            |  "insert" ->
              if not (line_to_insert<1) && not header_flag then Insert(!the_file, nodeX.cil_txt, line_to_insert, nodeX.cil_txt)
              else Nop(line_to_insert)
            |  "delete" ->
              if not (nodeX.first_line<1) && not header_flag then Delete(!the_file, (nodeX.first_line, nodeX.last_line), nodeX.cil_txt)
              else Nop(nodeX.first_line)
            |  "move" ->
              if not (line_to_insert<1) && not header_flag then Move(!the_file, nodeX.cil_txt, line_to_insert, (nodeX.first_line, nodeX.last_line), nodeX.cil_txt)
              else Nop(nodeX.first_line)
            |  _ -> Nop(line_to_insert)
          in
          final_action_list := to_act :: !final_action_list; )
    done;
    close_in c;
  with
    End_of_file -> close_in c;
    final_action_list := List.rev !final_action_list;
    ()
end

(* initialize_node_info
 * This will build up the information relevant to each node. It will
 * include the following:
 *   Node ID
 *   source file
 *   Beginning and ending lines
 *   CIL statement text
 *   Corresponding text from the source file (if applicable...)
 * All of this should either be stored in a node object or returned
 * as a tuple, to be decided. The only thing you need to pass it is
 * the verbose_node_info hashtable, it should be able to do the rest.
 * At this point however the source file(s) will have to be in the same
 * directory, maybe there is a way around this requirement? *)


(* Called by lineRangeVisitor to get the line numbers from the original file. *)
let lineRangeMethod ht id currentLoc = begin
  let lr,_ = (Hashtbl.find ht id) in
  let theLines = ref lr in
  let my_line = (* !currentLoc.line *)
    if (String.length (currentLoc.file))!=0 && (String.get (currentLoc.file) 0)!='/' then last_good_line := currentLoc.line;
    !last_good_line
  in
  theLines := (my_line :: !theLines);
  Hashtbl.replace ht id (!theLines,currentLoc.file)
end

let last_good_line = ref 0

class lineRangeVisitor id ht = object
  inherit nopCilVisitor
  method vexpr e =
    lineRangeMethod ht id !currentLoc;
    DoChildren
  method vinst i =
    lineRangeMethod ht id !currentLoc;
    DoChildren
  method vblock b =
    lineRangeMethod ht id !currentLoc;
    DoChildren
end

let my_line_range_visitor = new lineRangeVisitor

let verbose_node_info = hcreate 10
let node_id_to_line_list_fn = hcreate 10

(* so what I need is to get the node ID info for the functions we're handling,
   and call this on each of those functions.  Next question: how? *)
(* OK, this was all originally in fundec_to_ast, and hten walked the statement node to add the rest *)
let _ =

  (* this adds to verbose_node_info, depending on node_id_to_line_list_fn *)

  let build_node_tuple id =
    if Hashtbl.mem node_id_to_line_list_fn id then begin
      let lr,f = (Hashtbl.find node_id_to_line_list_fn id) in
      if (List.length lr)!=0 then begin
        let lineRange = ref lr in
        lineRange := (List.sort (fun x y -> x - y) !lineRange);
        let min = List.hd !lineRange in
        let max = List.nth !lineRange ((List.length !lineRange)-1) in
        Hashtbl.add verbose_node_info id (f,min,max)
      end
      else
        Hashtbl.add verbose_node_info id (f,0,0)
    end

let initialize_node_info orig_sig rep_sig = begin
  StringMap.iter (fun k_filename v_map ->
      StringMap.iter (fun k_funname v_node ->
          let emptyLineList = ref [] in
          Hashtbl.add node_id_to_line_list_fn v_node.nid (!emptyLineList,"");
          ignore(visitCilStmt (my_line_range_visitor v_node.nid node_id_to_line_list_fn) s) ;
          Hashtbl.add node_id_to_cil_stmt n.nid s; (* this is the problem; I need
                                                      this info to go backwards
                                                      and I don't think we currently have it. *)

          build_node_tuple n.nid; ()

        ) v_map)
    orig_sig
end
let initialize_node_info nid_to_cil_stmt_ht = begin

  let get_lines_from_file filename startline endline =
    let lines = get_lines filename in
    let max = List.length lines in
    if startline<1 || endline>max then []
    else
      Array.to_list
        (Array.sub (Array.of_list lines) (startline-1) (endline-startline+1))
  in
  let nid_to_string_list nid =
    try
      let cil_stmt = Hashtbl.find nid_to_cil_stmt_ht nid in
      let the_doc = Cil.dn_stmt () cil_stmt in
      let as_string = Pretty.sprint ~width:80 the_doc in
      let newline_char = "\n" in
      let newline_regex = Str.regexp newline_char in
      Str.split newline_regex as_string
    with Not_found -> []
  in
  Hashtbl.iter (fun nid (fn,beginline,endline) ->

      (* This hackery sucks, is there another way? *)
      let base,ext = split_ext fn in
      let orig_fn = base^"-original."^ext in

      let orig_text = get_lines_from_file fn beginline endline in
      let is_bad = orig_text=[] || fn="" || beginline<1 in
      let the_last =
        if not (is_bad) then ((get_last_bracket_line orig_fn (endline+1)) - 1)
        else endline
      in
      let new_node =
        {
          id = nid ;
          filename = fn ;
          first_line = beginline ;
          last_line = the_last ;
          cil_txt = nid_to_string_list nid ;
          orig_txt = orig_text ;
        }
      in
      Hashtbl.add (if is_bad then node_id_to_cdiff_node
                   else bad_node_id_to_cdiff_node) nid new_node;
    ) verbose_node_info

(*
  let initialize_node_info ht nid_to_cil_stmt_ht = begin
  let current_line = ref "" in
  let cil_stmt_string_list = ref [] in
  let orig_stmt_string_list = ref [] in
  let count = ref 0 in
  Hashtbl.iter (fun nid (fn,beginline,endline) ->
(* Creation of the object or whatever *)
(* Extraction of text from original file. Do we do proper
  * bracket checking here as well? *)
  cil_stmt_string_list := [];
  orig_stmt_string_list := [];
  count := 0;
  if fn<>"" then begin
(* This needs to be changed, to be the command line argument. *)
  let c = open_in !(Sourcereader.orig_file) in
  if beginline!=(-1) then begin
(* Maybe we can still store these baddies somewhere? *)
  try
  while (!count)<beginline do
  current_line := input_line c;
  incr count
  done;
  if (beginline=endline) then
  (
  orig_stmt_string_list := !current_line :: !orig_stmt_string_list;
  current_line := input_line c
  )
  else (
  while(!count)<(endline+1) do
(*    Printf.printf "Node ID: %d...\n" nid; *)
  orig_stmt_string_list := !current_line :: !orig_stmt_string_list;
  current_line := input_line c;
  incr count
  done;
  let brax = ref true in
  while (!brax) do
  let current_line_without_ws = Str.split whitespace !current_line in
  List.iter (fun x -> if x<>"}" then brax := false) current_line_without_ws;
  if (!brax) then
  orig_stmt_string_list := !current_line :: !orig_stmt_string_list;
  current_line := input_line c
  done;
  ) ;
(*    Printf.printf "Node ID: %d...\n" nid; *)
  if (Hashtbl.mem nid_to_cil_stmt_ht nid) then
  (
  let cil_stmt = Hashtbl.find nid_to_cil_stmt_ht nid in
  let the_doc = Cil.dn_stmt () cil_stmt in
  let as_string = Pretty.sprint ~width:80 the_doc in
  let newline_char = "\n" in
  let newline_regex = Str.regexp newline_char in
  let list_of_strs = Str.split newline_regex as_string in
  cil_stmt_string_list := list_of_strs
  ) ;
(*  Printf.printf "Node ID: %d...\n" nid; *)
  Hashtbl.add node_id_to_cdiff_node nid (
  {
  id = nid ;
  filename = fn ;
  first_line = beginline ;
  last_line = endline ;
  cil_txt = !cil_stmt_string_list ;
  orig_txt = (List.rev !orig_stmt_string_list) ;
  });
  close_in c;
  with End_of_file ->
  if (Hashtbl.mem nid_to_cil_stmt_ht nid) then
  (
  let cil_stmt = Hashtbl.find nid_to_cil_stmt_ht nid in
  let the_doc = Cil.dn_stmt () cil_stmt in
  let as_string = Pretty.sprint ~width:80 the_doc in
  let newline_char = "\n" in
  let newline_regex = Str.regexp newline_char in
  let list_of_strs = Str.split newline_regex as_string in
  cil_stmt_string_list := list_of_strs
  ) ;
  Hashtbl.add node_id_to_cdiff_node nid (
  {
  id = nid ;
  filename = fn ;
  first_line = beginline ;
  last_line = endline ;
  cil_txt = !cil_stmt_string_list ;
  orig_txt = (List.rev !orig_stmt_string_list) ;
  } ) ;
  close_in c;
  end
(* For whatever reason, the first line is messed up, but we have the file.
  * treat as a bad node *)
  else
  (
  if (Hashtbl.mem nid_to_cil_stmt_ht nid) then
  (
  let cil_stmt = Hashtbl.find nid_to_cil_stmt_ht nid in
  let the_doc = Cil.dn_stmt () cil_stmt in
  let as_string = Pretty.sprint ~width:80 the_doc in
  let newline_char = "\n" in
  let newline_regex = Str.regexp newline_char in
  let list_of_strs = Str.split newline_regex as_string in
  cil_stmt_string_list := list_of_strs
  ) ;
  Hashtbl.add bad_node_id_to_cdiff_node nid (
  {
  id = nid ;
  filename = fn ;
  first_line = 0 ;
  last_line = 0 ;
  cil_txt = !cil_stmt_string_list ;
  orig_txt = !orig_stmt_string_list ;
  } )
  );
  end
  else
  (
  if (Hashtbl.mem nid_to_cil_stmt_ht nid) then
  (
  let cil_stmt = Hashtbl.find nid_to_cil_stmt_ht nid in
  let the_doc = Cil.dn_stmt () cil_stmt in
  let as_string = Pretty.sprint ~width:80 the_doc in
  let newline_char = "\n" in
  let newline_regex = Str.regexp newline_char in
  let list_of_strs = Str.split newline_regex as_string in
  cil_stmt_string_list := list_of_strs
  ) ;
  Hashtbl.add bad_node_id_to_cdiff_node nid (
  {
  id = nid ;
  filename = fn ;
  first_line = 0 ;
  last_line = 0 ;
  cil_txt = !cil_stmt_string_list ;
  orig_txt = !orig_stmt_string_list ;
  } )
  ) ;
  ) ht
*)

end


(* Generates the script for sourcereader. That script will probably
 * be called from here as well, so the changes can be immediately
 * applied, but it's nice to have the file somewhere anyway. *)
let generate_sourcereader_script filename = begin
  let base = Filename.chop_extension filename in
  let just_script_name = base^".script" in
  let output_name = "Change_Original/"^just_script_name in
  ensure_directories_exist output_name;
  let oc = open_out output_name in
  List.iter(fun act ->
      match act with
        Insert(fn, to_insert, line, record) ->
        Printf.fprintf oc "Insert\n";
        Printf.fprintf oc "%d\n" line;
        Printf.fprintf oc "0\n";
        List.iter (fun x -> Printf.fprintf oc "%s\n" x) (List.rev to_insert);
        Printf.fprintf oc "//INSERTED %d LINES AFTER LINE %d\n" (List.length to_insert) line;
        Printf.fprintf oc "###\n"
      | Delete(fn, (first,last), record) ->
        Printf.fprintf oc "Insert\n";
        Printf.fprintf oc "%d\n" first;
        Printf.fprintf oc "0\n";
        Printf.fprintf oc "//DELETED %d LINES AT LINE %d\n" ((last-first)+1) first;
        Printf.fprintf oc "###\n";
        Printf.fprintf oc "Delete\n";
        Printf.fprintf oc "%d\n" first;
        Printf.fprintf oc "%d\n" ((last-first)+1);
        Printf.fprintf oc "###\n"
      | Move(fn, to_insert, line, (first,last), record) ->
        Printf.fprintf oc "Insert\n";
        Printf.fprintf oc "%d\n" line;
        Printf.fprintf oc "0\n";
        List.iter (fun x -> Printf.fprintf oc "%s\n" x) (List.rev to_insert);
        Printf.fprintf oc "//INSERTED %d LINES AFTER LINE %d\n" (List.length to_insert) line;
        Printf.fprintf oc "###\n";
        Printf.fprintf oc "Insert\n";
        Printf.fprintf oc "%d\n" first;
        Printf.fprintf oc "0\n";
        Printf.fprintf oc "//DELETED %d LINES AT LINE %d\n" ((last-first)+1) first;
        Printf.fprintf oc "###\n";
        Printf.fprintf oc "Delete\n";
        Printf.fprintf oc "%d\n" first;
        Printf.fprintf oc "%d\n" ((last-first)+1);
        Printf.fprintf oc "###\n"
      | Nop(line) ->
        Printf.fprintf oc "FLAGGED! BAD NODE OPERATION!\n";
        Printf.fprintf oc "Near line %d\n" line;
        Printf.fprintf oc "###\n"
    ) !final_action_list;
  debug_action_list ();
  repair_script_list := just_script_name :: !repair_script_list;
  final_action_list := [];
  close_out oc
end
;;
