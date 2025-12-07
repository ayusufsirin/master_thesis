$ENV{'TEXINPUTS'}='./StyleFiles//:' . $ENV{'TEXINPUTS'}; 
$ENV{'BSTINPUTS'}='./StyleFiles//:' . $ENV{'BSTINPUTS'};

add_cus_dep('mmd', 'png', 0, 'mmd_to_png');

sub mmd_to_png {
    my ($base) = @_;
    system("mmdc -s 3 -i $base.mmd -o $base.png");
}
