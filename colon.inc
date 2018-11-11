%define last_item 0

%macro colon 2
%2:
dq last_item
db %1, 0
%define last_item %2
%endmacro