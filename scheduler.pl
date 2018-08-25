:- dynamic running/2.
:- dynamic jobid/1.

jobid(0).

resource(node1, 1, linux).
resource(node2, 4, linux).
resource(node3, 1, macos).

current_jobs(Node, Jobs) :-
  findall(J, running(Node, J), Jobs).

current_capacity(Node, Capacity) :-
  resource(Node, Max_C, _),
  current_jobs(Node, Jobs),
  length(Jobs, Num_J),
  Capacity is Max_C - Num_J.

find_available(Tag, Node) :-
  resource(Node, _, Tag),
  current_capacity(Node, C),
  C >= 1.

next_id(Id) :-
  jobid(OldId),
  retract(jobid(OldId)),
  Id is OldId + 1,
  assert(jobid(Id)).

schedule(Tag, Handle) :-
  find_available(Tag, Node), !,
  next_id(Id),
  Handle = running(Node, Id),
  assert(Handle).

shutdown :-
  retractall(running(_, _)),
  retractall(jobid(_)),
  assert(jobid(0)).
