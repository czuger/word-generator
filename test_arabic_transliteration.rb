require 'i18n'

I18n.load_path = Dir['locale/*.yml']
I18n.backend.load_translations

p I18n.transliterate(  'وهناك أختلافات كبيرة في آسيا ما بين داخلها وخارجها في ما يتعلق بالجماعات العرقية، والثقافات، والبيئات، والاقتصاد، والعلاقات التاريخية والنظم الحكومية.' ).downcase