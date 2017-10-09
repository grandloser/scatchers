defmodule Scatchers.MisterSendo do
  use Bamboo.Phoenix, view: Scatchers.EmailView
  alias Scatchers.{Mailer, APICaller}

  def send_email(item) do
    ext = extract_data(item)
    new_email
    # |> to("firefocs@gmail.com")
    |> to("brightbreath@gmail.com")
    |> cc("firefocs@gmail.com")
    |> from("no-reply@busanmaninseoul.com")
    |> subject("[#{ext.price}] #{ext.translated_subject}")
    |> put_html_layout({Scatchers.LayoutView, "email.html"})
    |> render("new_item.html", ext: ext)
    |> Mailer.deliver_now
  end

  def thumbnail_host, do: "https://static-mercari-jp-imgtr2.akamaized.net"
  def link_host, do: "https://item.mercari.com/jp/"
  def extract_data(item) do
    # link = extract_link(item)
    # link = "https://www.mercari.com/jp/search/?keyword=%E3%83%99%E3%82%A2%E3%83%96%E3%83%AA%E3%83%83%E3%82%AF"
    image = extract_image(item)
    full_image_link = "#{thumbnail_host()}#{image}"
    regex_list = Regex.run(~r/(?=\/photos\/).*(?=_1\.jpg)/, "#{image}")
    link = regex_list |> List.first() |> String.split("/") |> Enum.at(2)
    full_link = "#{link_host()}#{link}"
    subject = extract_subject(item)
    price = extract_price(item)

    # IO.puts "#{link}\n #{image}\n #{subject}\n #{price}"
    translated_subject = APICaller.translate_to_korean(subject)
    # IO.puts "translate #{translated_subject}"

    %{
      link: full_link,
      img_src: full_image_link,
      subject: subject,
      translated_subject: translated_subject,
      price: price
    }
  end

  def extract_link(item) do
    href = Floki.find(item, "a")
    |> Floki.attribute("href")
    href
  end

  def extract_image(item) do
    src = Floki.find(item, "a")
    |> Floki.find("figure")
    |> Floki.find("img")
    |> Floki.attribute("data-src")
    src
  end

  def extract_subject(item) do
    [{dom, child, subject}] = Floki.find(item, ".items-box-name")
    Enum.join(subject, "\n")
  end

  def extract_price(item) do
    [{dom, child, price}] = Floki.find(item, ".items-box-price")
    Enum.join(price, "\n")
  end
end
