module TemplatesHelper
  def template_attribute_details(template_attribute)
    type = template_attribute.sample_attribute_type.title

    if !template_attribute.sample_controlled_vocab.blank?
      type += ' - ' + link_to(template_attribute.sample_controlled_vocab.title, template_attribute.sample_controlled_vocab)
    end

    # unit = template_attribute.unit ? "( #{template_attribute.unit.symbol} )" : ''
    req = template_attribute.required? ? required_span : ''
    attribute_css = 'sample-attribute'
    # attribute_css << ' sample-attribute-title' if sample_type_attribute.is_title?
    content_tag :span, class: attribute_css do
      "#{h template_attribute.title} (#{type}) #{req}".html_safe
    end
  end
end
