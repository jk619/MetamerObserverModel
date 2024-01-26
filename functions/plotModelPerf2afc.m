function [] = plotModelPerf2afc(sampPerf,famPerf,inParams)

if numel(inParams.o.imScale) == 1
    
    sizeValsDeg     = inParams.o.imSizes/inParams.o.imScale;
    
    if inParams.logPlot
        xValues         = -.5:.5:1;
        sizeValsDeg     = log10(sizeValsDeg);
        textX           = .9;
    else
        xValues         = 0:2:8;
        textX           = 8;
    end
    
    condColors  =   [.2 .2 .2; .8 .2 .2];
    phyplot([],[],'xticks',xValues,'yticks',.4:.2:1,'width',1,'fontsize',12,'fontangle','normal'); hold on;
    
    btwText = .03;
    topText = 1 + btwText;
    topText = topText-btwText; text(textX,topText,     sprintf('Model scaling           = %g',inParams.scale),'fontsize',12,'fontangle','normal');
    topText = topText-btwText; text(textX,topText,   sprintf('Trials per condition   = %g',inParams.nTrials),'fontsize',12,'fontangle','normal');
    topText = topText-btwText; text(textX,topText,    sprintf('Mid noise              = %g',inParams.midN),'fontsize',12,'fontangle','normal');
    topText = topText-btwText; text(textX,topText,   sprintf('Threshold for RFs     = %g',inParams.thresh),'fontsize',12,'fontangle','normal');
    
    trans = 0;
    
    for iD=1:size(famPerf,2)
        tmpSP   = reshape(permute(famPerf(:,iD,:,:),[3 1 4 2]),size(famPerf,3),size(famPerf,1)*size(famPerf,4));
        plotErrorBars(sizeValsDeg,nanmean(tmpSP,2),std(tmpSP,[],2)./sqrt(size(tmpSP,2)),.8*ones(1,3),zeros(1,3),trans,1);
    end
    
    for iD=1:size(sampPerf,2)
        tmpSP   = reshape(permute(sampPerf(:,iD,:,:),[3 1 4 2]),size(famPerf,3),size(famPerf,1)*size(famPerf,4));
        plotErrorBars(sizeValsDeg,nanmean(tmpSP,2),std(tmpSP,[],2)./sqrt(size(tmpSP,2)),.8*ones(1,3),zeros(1,3),trans,1);
    end
    
    
    for iD=1:size(famPerf,2)
        plot(sizeValsDeg,squeeze(nanmean(nanmean(famPerf(:,iD,:,:),1),4)),'color',clip(iD*condColors(2,:),0,1),'linewidth',4);
    end
    
    for iD=1:size(sampPerf,2)
        plot(sizeValsDeg,squeeze(nanmean(nanmean(sampPerf(:,iD,:,:),1),4)),'color',clip(iD*condColors(1,:),0,1),'linewidth',4);
    end
    
    if inParams.logPlot
        plot([-.5 1],[.5 .5],'-k');
    else
        plot([0 8],[.5 .5],'-k');
    end
    
    ylabel('Performance','fontsize',12);
    xlabel('Stimulus diameter (deg)','fontsize',12);
    drawnow;
    
elseif numel(inParams.o.imScale) > 1
    
    %%%%%%%%%%%%
    
    for iS = 1:numel(inParams.o.imScale)
        if numel(inParams.o.imScale) == 1
            sizeValsDeg     = inParams.o.imSizes/inParams.o.imScale;
        elseif numel(inParams.o.imScale) > 1
            sizeValsDeg     = inParams.o.imSizes/inParams.o.imScale(iS);
        end
        
        if inParams.logPlot
            xValues         = -.2:.2:1.4;
            sizeValsDeg     = log10(sizeValsDeg);
            textX           = .9;
        else
            xValues         = 0:2:8;
            textX           = 8;
        end
        
        chanceLevel     = 1/2;
        phyplot([],[],'xticks',xValues,'yticks',.4:.1:1,'width',1,'fontsize',12,'fontangle','normal');
        hold on;
        condColors  =   [.2 .2 .2; .8 .2 .2];
        plot([sizeValsDeg(1) sizeValsDeg(end)],[chanceLevel chanceLevel],'k');

        
        textX   = 8;
        btwText = .03;
        topText = 1 + btwText;
        topText = topText-btwText; text(textX,topText,     sprintf('Model scaling           = %g',inParams.scale),'fontsize',12,'fontangle','normal');
        topText = topText-btwText; text(textX,topText,   sprintf('Trials per condition   = %g',inParams.nTrials),'fontsize',12,'fontangle','normal');
        topText = topText-btwText; text(textX,topText,    sprintf('Mid noise              = %g',inParams.midN),'fontsize',12,'fontangle','normal');
        topText = topText-btwText; text(textX,topText,   sprintf('Threshold for RFs     = %g',inParams.thresh),'fontsize',12,'fontangle','normal');
        
        trans = 0;
        
        for iD=1:size(famPerf,2)
            tmpSP   = reshape(permute(famPerf(:,iD,:,:),[3 1 4 2]),size(famPerf,3),size(famPerf,1)*size(famPerf,4));
            plotErrorBars(sizeValsDeg,nanmean(tmpSP,2),std(tmpSP,[],2)./sqrt(size(tmpSP,2)),.8*ones(1,3),zeros(1,3),trans,1);
        end
        
        for iD=1:size(sampPerf,2)
            tmpSP   = reshape(permute(sampPerf(:,iD,:,:),[3 1 4 2]),size(famPerf,3),size(famPerf,1)*size(famPerf,4));
            plotErrorBars(sizeValsDeg,nanmean(tmpSP,2),std(tmpSP,[],2)./sqrt(size(tmpSP,2)),.8*ones(1,3),zeros(1,3),trans,1);
        end
        
        
        for iD=1:size(famPerf,2)
            plot(sizeValsDeg,squeeze(nanmean(nanmean(famPerf(:,iD,:,:),1),4)),'color',clip(iD*condColors(2,:),0,1),'linewidth',4);
        end
        
        for iD=1:size(sampPerf,2)
            plot(sizeValsDeg,squeeze(nanmean(nanmean(sampPerf(:,iD,:,:),1),4)),'color',clip(iD*condColors(1,:),0,1),'linewidth',4);
        end
        
        ylabel('Performance','fontsize',12);
        xlabel('Stimulus diameter (deg)','fontsize',12);
        drawnow;
    end
end