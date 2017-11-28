package SeqWare::Html;

use 5.022001;
use strict;
use warnings;

require Exporter;

our @ISA = qw(Exporter);

use parent 'Exporter';
our @EXPORT_OK =
  qw(document breadcrumbs button headings p panel panelBody panelList table tableHeader tableHeaderNested NAV_BROWSER NAV_STATUS NAV_RUNS NAV_PROJECTS NAV_INSTRUMENTS);

our $VERSION = '0.01';


# Preloaded methods go here.

use Cwd;
use Time::Local;

use constant NAV_BROWSER =>
  { name => "SeqWare Browser", file => "seqwareBrowser.html" };
use constant NAV_STATUS =>
  { name => "Current Status", file => "../seqwareReport/seqwareReport.html" };
use constant NAV_RUNS => { name => "Runs", file => "runReports.html" };
use constant NAV_PROJECTS =>
  { name => "Projects", file => "projects/projects.html" };
use constant NAV_INSTRUMENTS =>
  { name => "Instruments", file => "runs/instruments.html" };

my @navLinks =
  ( NAV_BROWSER, NAV_STATUS, NAV_RUNS, NAV_PROJECTS, NAV_INSTRUMENTS );

# Generate an HTML document for a report as a string.
# 1[Str]: the title of the page
# 2[HashRef{name[Str],file[Str]}]: the currently selected tab for this page, from the provided `nav` strctures
# 3[Str]: path to the root directory on the webserver
# 4[Str<HTML>]: the contents of the page body
sub document {
    my ( $pageTitle, $activeTab, $pathToRoot, $contents, $customHead ) = @_;

    my $dateGenerated = localtime;
    my $cmd_string    = join( " ", @ARGV );
    my $cwd           = Cwd::cwd();

    my $css=populate_css("$pathToRoot/res/css");
    my $js=populate_js("$pathToRoot/res/js");
    my $head="" if (!defined $customHead);
    my $html = <<EOI;
<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="utf-8">
	<meta http-equiv="x-UA-Compatible" content="IE-edge">
	<meta name="viewport" content="width=device-width, initial-scale=1">
	<!-- Executed as: cd $cwd && $0 $cmd_string -->
    $css
    $js
    $customHead
	<link rel="shortcut icon" href="$pathToRoot/res/images/dna_helix.ico" />

	<!-- HTML5 shim and Respond.js for IE8 support of HTML5 elements and media queries -->
	<!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
	<!--[if lt IE 9]>
		<script src="https://oss.maxcdn.com/html5shiv/3.7.2/html5shiv.min.js"></script>
		<script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
	<![endif]-->

	<title>$pageTitle – SeqWare Browser</title>
</head>

<body>
	<nav class="navbar navbar-default">
		<div class="container-fluid">
			<!-- Brand and toggle get grouped for better mobile display -->
			<div class="navbar-header">
				<button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#bs-example-navbar-collapse-1">
					<span class="sr-only">Toggle navigation</span>
					<span class="icon-bar"></span>
					<span class="icon-bar"></span>
					<span class="icon-bar"></span>
				</button>
				<a class="navbar-brand" href="http://www-gsi.hpc.oicr.on.ca/landing/"><img alt="gsi" src="$pathToRoot/res/images/dna_helix.png" width="25px"></a>
			</div>

			<!-- Collect the nav links, forms, and other content for toggling -->
			<div class="collapse navbar-collapse" id="bs-example-navbar-collapse-1">
				<ul class="nav navbar-nav">
EOI

    foreach my $tab (@navLinks) {
        if ( $tab->{name} eq $activeTab->{name} ) {
            $html .=
"<li class=\"active\"><a href=\"$pathToRoot/$tab->{file}\">$tab->{name} <span class=\"sr-only\">(current)</span></a></li>\n";
        }
        else {
            $html .=
"<li><a href=\"$pathToRoot/$tab->{file}\">$tab->{name}</a></li>\n";
        }
    }

    $html .= <<EOI;
				</ul>
			</div>
		</div>
	</nav>

	<div class="content gsi-content">
$contents
	</div>
	<div id="footer">
		<p class="gsi-content">SeqWare Browser generated $dateGenerated.<br>
		Brought to you by <a href="http://www-gsi.hpc.oicr.on.ca/landing/">Genome Sequence Informatics</a>.</p>
	</div>

	<!-- jQuery (necessary for Bootstrap's JavaScript plugins) -->
	<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.2/jquery.min.js"></script>
	<!-- Include all compiled plugins (below), or include individual files as needed -->
	<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.4/js//bootstrap.min.js"></script>
</body>
</html>
EOI
    return $html;
}

sub populate_css {
    my $css_dir  = shift(@_);
    my $css = <<OHAI;
	<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.4/css/bootstrap.min.css">
	<link rel="stylesheet" href="$css_dir/gsi-common.css">
OHAI
    return $css;
}

sub populate_js {
    my $js_dir = shift(@_);
    my $js = <<OHAI;
    <script src="$js_dir/sorttable.js"></script>
OHAI
    return $js;
}


# Create the link hierarchy to this page.
# ...[Str<URL>, Str]: Pairs of URLs and labels for the items in the trail
sub breadcrumbs {
    my $result = "<ol class=\"breadcrumb\">\n";
    while ( scalar @_ >= 2 ) {
        my $linkUrl  = shift(@_);
        my $linkText = shift(@_);
        $result .= "<li><a href=\"$linkUrl\">$linkText</a></li>\n";
    }
    return $result . "</ol>\n";
}

# Create a button-themed link
# 1[Str<URL>]: The place for the button to go
# 2[Str<HTML>]: The text on the button
sub button {
    my ( $url, $title ) = @_;
    return "<a class=\"btn btn-primary btn-large\" href=\"$url\">$title</a>";
}

# Create headings
# 1[Str]: The heading
# 2[Str or Undef]: The subheading
sub headings {
    my ( $heading, $subHeading ) = @_;    #subHeading optional
    my $result = "<div class=\"page-header\">\n<h1>$heading";
    if ( defined $subHeading ) {
        $result .= "<small>$subHeading</small></h1>";
    }
    return $result . "</h1></div>\n";
}

# Create a thumbnail view of an image
# 1[Str]: The URL to the image.
# 2[Int or Undef]: The width of the thumbnail (100px by default).
# 3[Int or Undef]: The height of the thumbnail (100px by default).
sub imgThumb {
    my ( $url, $width, $height ) = @_;
    return
        "<a href=\"$url\"><img src=\"$url\" width=\""
      . ( $width // 100 )
      . "\" height=\""
      . ( $height // 100 )
      . "\"/></a>";
}

# Create a paragraph
# ...[Str<HTML>]: The content of the paragraph.
sub p {
    return "<p>" . join( "", @_ ) . "</p>\n";
}

# Create a panel (content box)
# 1[Str or Undef]: The title or undef to omit
# ...[Str<HTML>]: The content of the panel.
sub panel {
    my $title  = shift(@_);
    my $result = "<div class=\"panel panel-default\">\n";
    if ( defined $title ) {
        $result .=
"<div class=\"panel-heading\"><h3 class=\"panel-title\">$title</h3></div>\n";
    }
    return $result . join( "", @_ ) . "</div>";
}

# Create a panel body, for placing text inside a panel.
# ...[Str<HTML>]: The content of the panel body.
sub panelBody {
    return "<div class=\"panel-body\">" . join( "", @_ ) . "</div>";
}

# Create a panel with a list of items.
# ...[Str<HTML>]: The items in the list
sub panelList {
    return
        "<ul class=\"list-group\">"
      . join( "", map { "<li class=\"list-group-item\">$_</li>" } @_ )
      . "</ul>";
}

# Create a table
# 1[Str<HTML>]: The header of the table.
# 2[ArrayRef[Str<HTML>] or Undef]: The table footer, if any.
# ...[ArrayRef[Str<HTML> or Undef]]: The rows in the table.
sub table {
    my $header = shift(@_);
    my $footer = shift(@_);
    my $result =
        "<table class=\"table sortable\"><thead>\n"
      . $header
      . "</thead><tbody>\n";
    foreach my $row (@_) {
        $result .=
            "<tr>"
          . join( "", map { "<td>" . ( $_ // "" ) . "</td>" } @{$row} )
          . "</tr>\n";
    }
    $result .= "</tbody>\n";
    if ( defined $footer ) {
        $result .=
            "<tfoot><tr>"
          . join( "", map { "<td>" . ( $_ // "" ) . "</td>" } @{$footer} )
          . "</tr></tfoot>\n";
    }
    return $result . "</table>\n";
}

# Create a simple header for a table
# ...[Str<HTML>]: The field names of the table.
sub tableHeader {
    return
      "<tr>"
      . join( "", map { "<th class=\"col-md-1\">$_</th>" } @_ ) . "</tr>";
}

# Create a header with grouped items.
# ...[HashRef{name[Str<HTML>],children[ArrayRef[Str<HTML>]]]: A list of named groups of columns.
sub tableHeaderNested {
    return "<tr>"
      . join( "",
        map { "<th colspan=\"" . $_->{children} . "\">$_->{name}</th>" } @_ )
      . "</tr>\n<tr>"
      . join(
        "",
        map {
            join( "", map { "<th>$_</th>" } @{ $_->{children} } )
        } @_
      ) . "</tr>\n";
}




1;
__END__

=head1 NAME

SeqWare::Html - Perl extension with convenience methods for the GSI website

=head1 SYNOPSIS

  use SeqWare::Html;

=head1 DESCRIPTION

Convenience methods for creating an HTML page in the GSI website.

=head2 EXPORT

document, breadcrumbs, button, headings, p, panel, panelBody, panelList, table, tableHeader, tableHeaderNested, NAV_BROWSER, NAV_STATUS, NAV_RUNS, NAV_PROJECTS, NAV_INSTRUMENTS

=head1 SEE ALSO

Code: https://github.com/oicr-gsi/gsi-website

=head1 AUTHOR

Morgan Taschuk, Genome Sequence Informatics

=head1 COPYRIGHT AND LICENSE

MIT License

Copyright (C) 2017 by Genome Sequence Informatics, Ontario Institute for Cancer Research

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

=cut
