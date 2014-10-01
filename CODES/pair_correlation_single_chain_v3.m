% This script computes and plots the pair correlation function for a single
% chain in a step of the MD simulation. It also plots the chain in 3D space
%%% Noah Paulson, 9/30/2014


% load total_info_11.mat

close all

color = hsv(20);

% ii: timestep id 
ii = 1;

c = 1;

for jj = [7,19]

    chain = (locations(:,2,ii) == jj);
    x_chain = chain .* locations(:,4,ii);
    y_chain = chain .* locations(:,5,ii);
    z_chain = chain .* locations(:,6,ii);
    x_chain(x_chain==0) = [];
    y_chain(y_chain==0) = [];
    z_chain(z_chain==0) = [];

    chains_int = [x_chain, y_chain, z_chain];
    ch_len = length(chains_int(:));
    
    chains_per = [];
    
    % the following code generates a specified tiling of simulation
    % volumes (according to the periodic boundary conditions)
    for xx = -2:2        
        for yy = -2:2
            for zz = -1:1
                x_chain_per = x_chain + xx*2*bounds(1,2,ii)*ones(size(x_chain));
                y_chain_per = y_chain + yy*2*bounds(2,2,ii)*ones(size(y_chain));
                z_chain_per = z_chain + zz*2*bounds(3,2,ii)*ones(size(z_chain));

                chains_spec = [x_chain_per,y_chain_per,z_chain_per];    
                chains_per = [chains_per ; chains_spec];
            end
        end
    end
    
    % range: maximum distance between particles to be considered
    range = 20;
    % dist: vector of the distances between all monomers
    [idx, dist] = rangesearch(chains_per,chains_int,range);
    
    dist_l = [];
    for rr = 1:length(dist)
        dist_l = [dist_l , cell2mat(dist(rr))];
    end
    dist_l = dist_l';
    dist_l(dist_l == 0) = [];
    
    intv = 0.01; % the interval in the binranges

    % binranges: vector of the starts/ends of the histogram bins
%     binranges = 0 : intv : 200;
    binranges = 0 : intv : range;

    % bincenters: central radius value in each histogram bin
    bincenters = binranges(1:end) + 0.5 * intv;

    % bincounts: number of monomer distances per each bin
    bincounts = histc(dist_l,binranges)';
    
    % vol: the simulation volume
    vol = 8 * bounds(1,2,ii) * bounds(2,2,ii) * bounds(3,2,ii);

    % atom_density: total # atoms divided by the simulation volume
    atom_density = ch_len / vol;

    % vector of the volumes of the shells generated by the inner and outer
    % radii of the histogram bins
    normalization_vec = (4 * pi() * atom_density * intv) .* (bincenters.^2);

    % point density: density of monomer distances for a given radius (vector)
    point_density = bincounts ./ normalization_vec;
    
    
    % initialize pd_all_chains on first loop
    if c == 1
        length(bincenters)
        bincounts_all_chains = zeros(1,length(bincounts));
        length(bincounts_all_chains)
    end
    
    bincounts_all_chains = bincounts_all_chains + bincounts;
    
    
    % bar plot of the pair correlation function
    figure(1)
    
%     bar(binranges,bincounts/ch_len,'histc')
    H = bar(binranges,bincounts,'histc');
    
    title1 = ['Pair correlation, timestep = ', num2str(timestep(ii)), ' , chain ID = ', num2str(jj)];
    title(title1)
    xlabel 'particle distance'
    ylabel 'frequency'
    
    file = ['pair_correlation_chain', int2str(jj),'_aniso11_timestep', int2str(timestep(ii)), '.png'];
    saveas(H, file)
    
    % 3d plot of the specific chain of interest
    figure(2)
    
    clf
    
%     H = plot3(chains_per(:,1), chains_per(:,2), chains_per(:,3));
    H = plot3(chains_int(:,1), chains_int(:,2), chains_int(:,3));
    set(H,'LineStyle','none','Marker','o','MarkerEdgeColor','k','MarkerFaceColor',color(jj,:),'MarkerSize',5)
    axis tight equal
    grid on;    
    
    title2 = ['Chain ',num2str(jj),' Timestep = ', num2str(timestep(ii))];
    title(title2)
    
    file = ['chain', int2str(jj),'_aniso11_timestep', int2str(timestep(ii)), '.png'];
    saveas(H, file)
    
    pause(5)
    c = c + 1;
end

% bar plot of the pair correlation function for all chains
figure(3)
bar(binranges,bincounts_all_chains/(20*ch_len),'histc')

figure(4)
bar(binranges,point_density,'histc')