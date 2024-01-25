# Use the official Debian Bullseye Slim base image
FROM debian:bullseye-slim

# Install sudo and clean up the package manager cache
RUN apt-get update && apt-get install -y sudo && rm -rf /var/lib/apt/lists/*

# Create a non-root user and add it to the sudo group
RUN useradd -m user && echo "user ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/user

# Switch to the non-root user
USER user

# Set the working directory to the user's home directory
WORKDIR /home/user

# Install Curl
RUN sudo apt-get update && sudo apt-get install -y curl && sudo rm -rf /var/lib/apt/lists/*

# Download the latest version of Ninja from GitHub
RUN version=$(basename $(curl -sL -o /dev/null -w %{url_effective} https://github.com/gngpp/ninja/releases/latest)) \
    && base_url="https://github.com/gngpp/ninja/releases/expanded_assets/$version" \
    && latest_url=https://github.com/$(curl -sL $base_url | grep -oP 'href=".*x86_64.*musl\.tar\.gz(?=")' | sed 's/href="//') \
    && curl -Lo ninja.tar.gz $latest_url \
    && tar -xzf ninja.tar.gz \
    && sudo cp ninja /bin/ninja \
    && rm -f ninja.tar.gz ninja

# Set the Chinese language environment and do not interact with APT
ENV LANG=C.UTF-8 DEBIAN_FRONTEND=noninteractive LANG=en-US.UTF-8 LANGUAGE=en-US.UTF-8 LC_ALL=C

# Create necessary folders and set access rights
RUN sudo mkdir -p /.gpt3 /.gpt4 /.auth /.platform && sudo chmod 777 /.gpt3 /.gpt4 /.auth /.platform

# By default when running an image, it will run ninja
CMD ["/bin/sh", "-c", "/bin/ninja run >> /dev/null 2>&1"]
