
import jinja2

def render_config(template_path, output_path, variables):
    with open(template_path) as file:
        template = jinja2.Template(file.read())

    rendered_config = template.render(variables)

    with open(output_path, "w") as file:
        file.write(rendered_config)

if __name__ == "__main__":
    variables = {
        "app_name": "MyApp",
        "environment": "production",
        "db_host": "db.example.com",
        "db_port": 5432,
        "db_user": "admin",
        "db_password": "securepassword"
    }
    render_config("app_config.j2", "app_config.json", variables)
