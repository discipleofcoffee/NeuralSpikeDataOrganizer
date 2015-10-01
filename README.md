%{
Neural Spike Data Organizer collected using in-vivo single cell electrophysiology for experiments in multisensory integration across multiple stimuli conditions. 
Searches for processed data tank files, and extracts and organizes information from
them, for use in analysis using independent scripts.
Authored by Kshitij Chawla for (Barry) Stein Lab, Wake Forest University, Winston Salem, NC, USA. 2014
Tested on MATLAB R2013b.
%}

%{
Electrophysiology system used: Tucker Davis Technologies (TDT)
::Experimental Context::

Experimental overview has not been included. For that you can look-up Stein et al.

The program was writen for experiments with the goal of generating
neuronal response in the brain for a large variety of stimulus conditions. To that end,
stimuli with 1 LED, 3 LEDs, Left to Right and Right to Left Apparent motion
LEDs at different brightness intensities and different SOAs were
implemented.
As the experimental paradigms evolved, more variety of stimuli were added,
so some initial units have fewer conditions than later ones. As much as
possible the program works around the discrepancies, in a manner that will
minimize the effect on analysis.

::Data structure::

The data is stored in a structure of arrays. The basic structure is thus:
    units_data.(fieldname)(index) or {index}(subscript) for cells.

units_data = the structure holding all the data.

Fieldname = the kind of value being stored in them, for example,
    trial_length, visual stimulus onset, etc.

index = different case numbers. This merits some explanation. Index is referred to
as 'Case' or 'Process' in subsequent comments. Using an example:
if we have 2 neurons aka units, with the first neuron exposed to 12
stimulus conditions and the second one exposed to 5 stimulus condition, each field of 
units_data will be an array or cell array of size 17. So the cases are arranged as one big
sequence and not seggregated based on which unit they belong to (to do
that, use the unit_num field and logical subscripting).
 
So to access case 1, use units_data.(fieldname)(1), example
units_data.msi(1) will give msi of case 1.

::Notes::

The place_num field is useful because is assigns a unique number to each case,
which stays the same even a subset of the unit was assigned to another
variable. Due to this reason,instead of directly accessing using array
indices, in most place, place_num is used as an indirect access mechanism.

Initially an object oriented approach was used :
units_data(index).(fieldname) 
This made logical sense and units_data(1) would give all the info of case
1. But it seems Matlab, atleast the version is not very efficient in
handling such constructs (array of structures) and consumed so much RAM
that the computer would just freeze while loading the file. So the new
configuration (structure of arrays) was chosen.

The program is still pretty modular, and it's easy to write new function
and insert them at appropriate location in this script if something new
needs to be included.

Also, to conserve memory, doubles are not used anywhere, instead singles
are used. Some fields could have used ints for further reduced memory
footprint, but I wanted to use NaN for missing values, which only floats
support. Also,It was a big mess trying to typecast some variable on the fly
at multiple places because int didn't support one operation or another.

The commented out code is for several other things that I was calculating
and storing. Eventually some were more useful than others and so I didn't
return the unneeded values. Should be simple enough to reactivate. Or
delete.

There are also a few variables which collect some other data, which was
useful in the initial days for debugging and keeping track of program
execution, such as the error field and file_error_list etc. They are not
saved anymore to minimize memory consumption on reloading. They weren't
being used for any other purpose.

::Variable naming scheme ::

(Generally speaking), variables with _(following)_ in their names indicate:

'key' = logical arrays for subscripting or actual indices within a subset
    of arrays.
'place' = global indices of the relevant value.
'uni' = unimodal condition related.
'av' = multimodal condition related.
'count' = counter for a specific value in for loops.
'rel' = relative
%}
