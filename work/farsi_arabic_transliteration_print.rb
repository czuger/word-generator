require 'i18n'

I18n.load_path = Dir['locale/*.yml']
I18n.backend.load_translations

I18n.config.available_locales = :en

p I18n.transliterate(  'وهناك أختلافات كبيرة في آسيا ما بين داخلها وخارجها في ما يتعلق بالجماعات العرقية، والثقافات، والبيئات، والاقتصاد، والعلاقات التاريخية والنظم الحكومية.' ).downcase
p I18n.transliterate(  'فراوانی به این زبان نوشته می‌شد. تأثیر عربی بر زبان‌های دیگر جهان اسلام مانند اردو، فارسی و زبان‌های گوناگون خانوادهٔ ترکی چشمگیرست.' ).downcase

