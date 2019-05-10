from django import forms


class RawInsertModifyBookForm(forms.Form):
    ISBN = forms.CharField()
    title = forms.CharField()
    publisher = forms.TypedChoiceField(coerce=int)
    publication_year = forms.DateField()
    price = forms.DecimalField()
    quantity = forms.IntegerField()
    threshold = forms.IntegerField()
    category = forms.TypedChoiceField(coerce=int)

    def __init__(self, *args, **kwargs):
        super(RawInsertModifyBookForm, self).__init__(*args, **kwargs)

    def set_choices(self, publishers, categories):
        self.fields['publisher'].choices = publishers
        self.fields['category'].choices = categories

    def set_form_data(self, args):
        if args:
            i = 0
            for field in self.fields.values():
                field.initial = args[i]
                i += 1
