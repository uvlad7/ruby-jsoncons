require 'jsoncons'
require 'json'
require 'benchmark'

possible_breadcrumbs = [
  'Campaña/Escolares Volvamos con Todo/Barritas y Snack',
  'Campaña/Escolares Volvamos con Todo',
  'Campaña',
  'Panadería y Pastelería/Pastelería/Alfajores',
  'Panadería y Pastelería/Pastelería',
  'Panadería y Pastelería',
  'Desayunos y Dulces/Galletas y Colaciones Dulces/Galletones y Alfajores',
  'Desayunos y Dulces/Galletas y Colaciones Dulces',
  'Desayunos y Dulces',
  'Panadería y Pastelería/Pastelería/Magdalenas y Bizcochos',
  'Panadería y Pastelería/Pastelería',
  'Panadería y Pastelería',
  'Colaciones/Galletas y Snack Colación/Bizcochos',
  'Colaciones/Galletas y Snack Colación',
  'Colaciones',
  'Desayuno y Dulces/Galletas y Colaciones Dulces/Galletones y Alfajores',
  'Desayuno y Dulces/Galletas y Colaciones Dulces',
  'Desayuno y Dulces',
  'Campañas/Solo 1000/Dulces, Snacks Y Bebidas',
  'Campañas/Solo 1000',
  'Campañas',
  'Desayunos y Dulces/Pastelería/Magdalenas y Bizcochos',
  'Desayunos y Dulces/Pastelería',
  'Desayunos y Dulces',
  'Pastelería/Masas Dulces y Hojaldrados/Magdalenas y Bizcochos',
  'Pastelería/Masas Dulces y Hojaldrados',
  'Pastelería',
  'Desayunos y Dulces/Pastelería/Masas Dulces y Otros',
  'Desayunos y Dulces/Pastelería',
  'Desayunos y Dulces',
  'Campañas/Solo 1000/Desayuno',
  'Campañas/Solo 1000',
  'Campañas',
  'Colaciones/Galletas y Snack colación/Bizcochos',
  'Colaciones/Galletas y Snack colación',
  'Colaciones',
  'Desayunos y Dulces/Pastelería/Alfajores',
  'Desayunos y Dulces/Pastelería',
  'Desayunos y Dulces',
].map { |v| v.split('/')[0..2] }.reject { |arr| arr.size < 3 }

page_content = File.read('categories.json')

res1 = nil
res2 = nil
res3 = nil

puts '1: Jsoncons::Json.parse and Jsoncons::Json#query'
puts '1: Jsoncons::Json.parse and Jsoncons::JsonPath::Expression#evaluate'
puts '3: JSON.parse and #find'
puts '-----------------------------------------------------------------------'

Benchmark.bm do |x|
  x.report('1') do
    1000.times do
      categories = Jsoncons::Json.parse(page_content)['categories']
      res1 = possible_breadcrumbs.find do |a, b, c|
        !categories.query(
          %`$[?(@.label=="#{a}" && @.special==false)].categoriesLevel2[?(@.label=="#{b}")].categoriesLevel3[?(@.label=="#{c}")]`
        ).empty?
      end
    end
  end

  x.report('2') do
    expressions = {}
    possible_breadcrumbs.each do |cat|
      expressions[cat] = Jsoncons::JsonPath::Expression.make(%`$[?(@.label=="#{cat[0]}" && @.special==false)].categoriesLevel2[?(@.label=="#{cat[1]}")].categoriesLevel3[?(@.label=="#{cat[2]}")]`)
    end
    1000.times do
      categories = Jsoncons::Json.parse(page_content)['categories']
      res2 = possible_breadcrumbs.find do |cat|
        !expressions[cat].evaluate(categories).empty?
      end
    end
  end

  x.report('3') do
    1000.times do
      categories = JSON.parse(page_content, symbolize_names: true)[:categories]
      res3 = possible_breadcrumbs.find do |a, b, c|
        categories.any? do |cat|
          cat[:label] == a && cat[:special] == false && cat[:categoriesLevel2]&.any? do |cat2|
            cat2[:label] == b && cat2[:categoriesLevel3]&.any? do |cat3|
              cat3[:label] == c
            end
          end
        end
      end
    end
  end
end

puts res1 == ['Panadería y Pastelería', 'Pastelería', 'Alfajores'] ? 'res1 is correct' : 'res1 is incorrect'
puts res2 == ['Panadería y Pastelería', 'Pastelería', 'Alfajores'] ? 'res2 is correct' : 'res2 is incorrect'
puts res3 == ['Panadería y Pastelería', 'Pastelería', 'Alfajores'] ? 'res3 is correct' : 'res3 is incorrect'
