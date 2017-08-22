defmodule Scatchers.MisterSendo do
  use Bamboo.Phoenix, view: Scatchers.EmailView
  alias Scatchers.Mailer

  def send_email(item) do
    ext = extract_data(item)
    new_email
    |> to("brightbreath@gmail.com")
    |> cc("firefocs@gmail.com")
    |> from("no-reply@busanmaninseoul.com")
    |> subject("[#{ext.price}] #{ext.subject}")
    |> put_html_layout({Scatchers.LayoutView, "email.html"})
    |> render("new_item.html", ext: ext)
    |> Mailer.deliver_now
  end

  def extract_data(item) do
    link = extract_link(item)
    image = extract_image(item)
    subject = extract_subject(item)
    price = extract_price(item)

    %{
      link: link,
      img_src: image,
      subject: subject,
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
