FROM fluxrm/flux-core:el10

USER root

RUN dnf clean all \
	&& rm -rf /var/cache/dnf \
	&& git config --global checkout.workers 1024 \
	&& git config --global feature.manyFiles true \
    && git config --global core.sharedRepository false \
	&& echo "* soft memlock unlimited" >> /etc/security/limits.conf \
    && echo "* hard memlock unlimited" >> /etc/security/limits.conf

USER fluxuser

RUN source /etc/profile.d/modules.sh \
	&& mkdir -p opt \
    && module load mpi \
    && git clone https://github.com/LLNL/mpibind.git \
	&& cd mpibind \
	&& ./bootstrap \
	&& ./configure --prefix=/home/fluxuser/opt/ \
	&& make -j install \
	&& git clone https://github.com/spack/spack.git \
	&& ./spack/bin/spack repo update \
	&& echo 'source ~/spack/share/spack/setup-env.sh' >> ~/.bashrc

COPY --chown=fluxuser:fluxuser . /home/fluxuser/phloem

RUN mkdir -p /home/fluxuser/spack/var/spack/environments/phloem/ \
	&& ln -sf /home/fluxuser/phloem/containerfiles/flux/el10/spack.yaml \
	/home/fluxuser/spack/var/spack/environments/phloem/spack.yaml

ENV FLUX_SHELL_RC_PATH=/home/fluxuser/opt/share/mpibind:${FLUX_SHELL_RC_PATH:-}

ENTRYPOINT ["exec /usr/bin/flux start /bin/bash"]
