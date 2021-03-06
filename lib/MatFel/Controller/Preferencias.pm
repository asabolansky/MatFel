package MatFel::Controller::Preferencias;

use strict;
use warnings;
use parent 'Catalyst::Controller::HTML::FormFu';

=head1 NAME

MatFel::Controller::Preferencias - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->body('Matched MatFel::Controller::Preferencias.');
}


=head1 AUTHOR

soporte,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

=head2 formfu_create


Use HTML::FormFu to create a new book
    
=cut
    
sub create :Chained('base') :PathPart('create') :Args(0) :FormConfig('preferencia/formfu_create.conf')  {
        my ($self, $c) = @_;
    
        # Get the form that the  :FormConfig attribute saved in the stash
        my $form = $c->stash->{form};
  
      #FIXME aca habria que ver que sea ADMIN antes de crear
        if ($form->submitted_and_valid) {
            # Create a new book
            my $preferencia = $c->model('DB::Preferencia')->new_result({});
            # Save the form data for the book
            $form->model->update($preferencia);
            # Set a status message for the prefernecia
            $c->flash->{status_msg} = 'Preferencia creada';
            # Return to the books list
            $c->response->redirect($c->uri_for($self->action_for('lista'))); 
            $c->detach;
        } else {
            # Get the authors from the DB
            
        }
        
        # Set the template
        $c->stash->{template} = 'preferencias/formfu_create.tt2';
    }

=head2 base
    
   Can place common logic to start chained dispatch here
    
=cut
    
sub base :Chained('/') :PathPart('preferencias') :CaptureArgs(0) {
        my ($self, $c) = @_;
    
        # Store the ResultSet in stash so it's available for other methods
        $c->stash->{resultset} = $c->model('DB::Preferencia');
    
        # Print a message to the debug log
        $c->log->debug('*** INSIDE BASE METHOD ***');
    }
    
=head2 edit
    
    Use HTML::FormFu to update an existing Preferencia
    
=cut
    
sub edit :Chained('object') :PathPart('edit') :Args(0) 
            :FormConfig('preferencia/formfu_create.conf') {
        my ($self, $c) = @_;
    
        # Get the specified book already saved by the 'object' method
        my $preferencia = $c->stash->{object};
    
        # Make sure we were able to get a book
        unless ($preferencia) {
            $c->flash->{error_msg} = "Preferencia Inválido -- No se puede editar";
            $c->response->redirect($c->uri_for($self->action_for('list')));
            $c->detach;
        }
    
        # Get the form that the :FormConfig attribute saved in the stash
        my $form = $c->stash->{form};
    
        # Check if the form has been submitted (vs. displaying the initial
        # form) and if the data passed validation.  "submitted_and_valid"
        # is shorthand for "$form->submitted && !$form->has_errors"
        if ($form->submitted_and_valid) {
            # Save the form data for the book
            $form->model->update($preferencia);
            # Set a status message for the preferencia
            $c->flash->{status_msg} = 'Preferencia Actualizado';
            # Return to the books list
            $c->response->redirect($c->uri_for($self->action_for('lista')));
            $c->detach;
        } else {
            $form->model->default_values($preferencia);
        
        }

# Set the template
        $c->stash->{template} = 'preferencias/formfu_create.tt2';
            }    

=head2 object

    Fetch the specified object based on the preferencia ID and store
    it in the stash
    
=cut
    
sub object :Chained('base') :PathPart('id') :CaptureArgs(1) {
        # $id = primary key of book to delete
        my ($self, $c, $id) = @_;
    
        # Find the book object and store it in the stash
        $c->stash(object => $c->stash->{resultset}->find($id));
    
        # Make sure the lookup was successful.  You would probably
        # want to do something like this in a real app:
        #   $c->detach('/error_404') if !$c->stash->{object};
        die "La Preferencia con $id no se encuentra!" if !$c->stash->{object};
    
        # Print a message to the debug log
        $c->log->debug("*** INSIDE OBJECT METHOD for obj id=$id ***");
    }
    
=head2 lista
    
    Fetch all preferencia objects and pass to books/list.tt2 in stash to be displayed
    
=cut
    
sub lista : Local {
        # Retrieve the usual Perl OO '$self' for this object. $c is the Catalyst
        # 'Context' that's used to 'glue together' the various components
        # that make up the application
        my ($self, $c) = @_;
    
        # Retrieve all of the book records as book model objects and store in the
        # stash where they can be accessed by the TT template
        # $c->stash->{books} = [$c->model('DB::Book')->all];
        # But, for now, use this code until we create the model later
        $c->stash->{preferencias} = [$c->model('DB::Preferencia')->all];
    
        # Set the TT template to use.  You will almost always want to do this
        # in your action methods (action methods respond to preferencia input in
        # your controllers).
        $c->stash->{template} = 'preferencias/lista.tt2';
}

=head2 borrar
    
    Borrar un Preferencia
    
=cut
    
sub borrar :Chained('object') :PathPart('borrar') :Args(0) {
        my ($self, $c) = @_;
    
        # Use the book object saved by 'object' and delete it along
        # with related 'book_author' entries
        $c->stash->{object}->delete;
    
        # Set a status message to be displayed at the top of the view
        $c->stash->{status_msg} = "Preferencia Borrado.";
    
        # Forward to the list action/method in this controller
        $c->forward('lista');
    }
    
1;
